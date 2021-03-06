/*
DECLARE
  TYPE DeptCurTyp IS REF CURSOR RETURN departments%ROWTYPE;
REF CURSOR types can be strong (with a return type) or weak (with no return type). Strong REF CURSOR types are less error prone because the PL/SQL compiler lets you associate a strongly typed cursor variable only with queries that return the right set of columns. Weak REF CURSOR types are more flexible because the compiler lets you associate a weakly typed cursor variable with any query. Because there is no type checking with a weak REF CURSOR, all such types are interchangeable. Instead of creating a new type, you can use the predefined type SYS_REFCURSOR.

Once you define a REF CURSOR type, you can declare cursor variables of that type in any PL/SQL block or subprogram.

DECLARE
   TYPE empcurtyp IS REF CURSOR RETURN employees%ROWTYPE;  -- strong
   TYPE genericcurtyp IS REF CURSOR;  -- weak
   cursor1 empcurtyp;
   cursor2 genericcurtyp;
   my_cursor SYS_REFCURSOR; -- didn't need to declare a new type
   TYPE deptcurtyp IS REF CURSOR RETURN departments%ROWTYPE;
   dept_cv deptcurtyp;  -- declare cursor variable
   
 To avoid declaring the same REF CURSOR type in each subprogram that uses it, you can put the REF CURSOR declaration in a package spec. 
 You can declare cursor variables of that type in the corresponding package body, or within your own procedure or function.
 
 */

function is_source_ready(ip_object_name varchar2, ip_owner varchar2 default 'DEPOSITS')
    return varchar2
    is
        cur_data sys_refcursor;
        --TYPE is_empty_tt IS TABLE OF VARCHAR2(1 CHAR);
        --l_is_empty is_empty_tt;
        l_is_empty varchar2(1 CHAR);
      begin
        open cur_data for 'select /*+ FIRST_ROWS(1) */ ''T''
                              from  '||ip_object_name||
                           ' where  1=1
                               AND  ROWNUM < 2';
        --loop 
            fetch cur_data into l_is_empty;
            --EXIT WHEN cur_data%NOTFOUND;
        --end loop;
        close cur_data;
        return nvl(l_is_empty,'F');
   end;


Another possibility is to declare and define a Record Type object to be a container for your query results. This could be useful if the query is a JOIN query, returning columns from several joined tables.

SQL> create or replace procedure p1 is
     /* Declare you destination data structure row container */
     TYPE TestRecTyp IS RECORD (
        deptno varchar(50),
        ename  varchar(50),
        job    varchar(50)
     );
     /* Define an instance of the record type */
     testrec TestRecTyp;

     type dept_rc is ref cursor; /*return dept%rowtype;*/
     my_ref_cursor dept_rc;
     begin
         open my_ref_cursor for 'select deptno,ename,job from emp';
         LOOP
             FETCH my_ref_cursor INTO testrec;
         EXIT WHEN my_ref_cursor%NOTFOUND;

             /* Do some operations with testrec*/

         END LOOP;
     end;
NOTE: You could use the above technique on a dynamically constructed SQL query statement by substituting 'select deptno,ename,job from emp' with a variable such as v_sql and update this variable with the SQL statement within the body of the procedure.




--*****************************************
SQL> create or replace procedure p1 is
  2      type dept_rc is ref cursor return dept%rowtype;
  3      my_ref_cursor dept_rc;
  4  begin
  5      open my_ref_cursor for
  6          select deptno, ename, job from emp;
  7  end;
  8  /

Procedure created.

SQL>

--********************************************
DECLARE
  TYPE cursor_ref IS REF CURSOR;
  c1 cursor_ref;
  TYPE emp_tab IS TABLE OF employees%ROWTYPE;
  rec_tab emp_tab;
  rows_fetched NUMBER;
BEGIN
  OPEN c1 FOR 'SELECT * FROM employees';
  FETCH c1 BULK COLLECT INTO rec_tab;
  rows_fetched := c1%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Number of employees fetched: ' || TO_CHAR(rows_fetched));
END;
/
--************************************************
--The cursor_variable.%ROWCOUNT is the solution. But its value will be 0 if you check it after opening. You need to loop through all the records, to get the total row count. Example below:

DECLARE 
  cur sys_refcursor;
  cur_rec YOUR_TABLE%rowtype;
BEGIN
  OPEN cur FOR
  SELECT * FROM YOUR_TABLE;

  dbms_output.put_line(cur%rowcount);--returning 0

  LOOP
    FETCH cur INTO cur_rec;  
    EXIT WHEN cur%notfound;
    dbms_output.put_line(cur%rowcount);--will return row number beginning with 1
    dbms_output.put_line(cur_rec.SOME_COLUMN);
  END LOOP;

  dbms_output.put_line('Total Rows: ' || cur%rowcount);--here you will get total row count
END;
/
--************************************************
--You can also use BULK COLLECT so that a LOOP is not needed,

DECLARE
    CURSOR c 
    IS   SELECT *
           FROM employee;
    TYPE emp_tab IS TABLE OF employee%ROWTYPE INDEX BY BINARY_INTEGER;
    v_emp_tab emp_tab;
BEGIN
    OPEN c;
    FETCH c BULK COLLECT INTO v_emp_tab;
    DBMS_OUTPUT.PUT_LINE(v_emp_tab.COUNT);
    CLOSE c;
END;
/
--************************************************

DECLARE
  TYPE emp_name_rec is RECORD (
    firstname    employees.first_name%TYPE,
    lastname     employees.last_name%TYPE,
    hiredate     employees.hire_date%TYPE
    );
    
-- Table type that can hold information about employees
   TYPE EmpList_tab IS TABLE OF emp_name_rec;
   SeniorSalespeople EmpList_tab;   
   
-- Declare a cursor to select a subset of columns.
   CURSOR c1 IS SELECT first_name, last_name, hire_date
     FROM employees;
   EndCounter NUMBER := 10;
   TYPE EmpCurTyp IS REF CURSOR;
   emp_cv EmpCurTyp; 
   
BEGIN
  OPEN emp_cv FOR SELECT first_name, last_name, hire_date
   FROM employees 
   WHERE job_id = 'SA_REP' ORDER BY hire_date;

  FETCH emp_cv BULK COLLECT INTO SeniorSalespeople;
  CLOSE emp_cv;

-- for this example, display a maximum of ten employees
  IF SeniorSalespeople.LAST > 0 THEN
    IF SeniorSalespeople.LAST < 10 THEN
      EndCounter := SeniorSalespeople.LAST; 
    END IF;
    FOR i in 1..EndCounter LOOP
      DBMS_OUTPUT.PUT_LINE
        (SeniorSalespeople(i).lastname || ', ' 
         || SeniorSalespeople(i).firstname || ', ' || SeniorSalespeople(i).hiredate);
    END LOOP;
  END IF;
END;
/
