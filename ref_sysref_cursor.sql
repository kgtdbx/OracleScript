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
