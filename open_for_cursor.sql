CREATE OR REPLACE PROCEDURE dept_query (
    p_deptno        emp.deptno%TYPE,
    p_sal           emp.sal%TYPE
)
IS
    emp_refcur      SYS_REFCURSOR;
    v_empno         emp.empno%TYPE;
    v_ename         emp.ename%TYPE;
    p_query_string  VARCHAR2(100);
BEGIN
    p_query_string := 'SELECT empno, ename FROM emp WHERE ' ||
        'deptno = :dept AND sal >= :sal';
    OPEN emp_refcur FOR p_query_string USING p_deptno, p_sal;
    DBMS_OUTPUT.PUT_LINE('EMPNO    ENAME');
    DBMS_OUTPUT.PUT_LINE('-----    -------');
    LOOP
        FETCH emp_refcur INTO v_empno, v_ename;
        EXIT WHEN emp_refcur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_empno || '     ' || v_ename);
    END LOOP;
    CLOSE emp_refcur;
END;

----------------
CREATE OR REPLACE FUNCTION names_for (
       name_type_in IN VARCHAR2)
    RETURN SYS_REFCURSOR
 IS
    l_return   SYS_REFCURSOR;
 BEGIN
    CASE name_type_in
       WHEN 'EMP'
       THEN
          OPEN l_return FOR
               SELECT last_name
                 FROM employees
             ORDER BY employee_id;
       WHEN 'DEPT'
       THEN
          OPEN l_return FOR
               SELECT department_name
                 FROM departments
             ORDER BY department_id;
    END CASE;

    RETURN l_return;
 END names_for;
--
 DECLARE
   l_names   SYS_REFCURSOR;
   l_name    VARCHAR2 (32767);
BEGIN
   l_names := names_for ('DEPT');
   LOOP
      FETCH l_names INTO l_name;
      EXIT WHEN l_names%NOTFOUND;
      DBMS_OUTPUT.put_line (l_name);
   END LOOP;
   CLOSE l_names;
END;
---------------------------
The OPEN-FOR statement is unique to cursor variables and enables me to specify at runtime, without having to switch to dynamic SQL, which data set will be fetched through the cursor variable.

Nevertheless, you can use OPEN-FOR with a dynamic SELECT statement. Here is a very simple example:

CREATE OR REPLACE FUNCTION 
numbers_from (
      query_in IN VARCHAR2)
   RETURN SYS_REFCURSOR
IS
   l_return   SYS_REFCURSOR;
BEGIN
   OPEN l_return FOR query_in;
   RETURN l_return;
END numbers_from;
And here is a block—virtually identical to the one that calls names_for, above—that displays all the salaries for employees in department 10:

DECLARE
  l_salaries   SYS_REFCURSOR;
  l_salary     NUMBER;
BEGIN
  l_salaries :=
    numbers_from (
      'select salary 
        from employees 
       where department_id = 10');
  LOOP
    FETCH l_salaries INTO l_salary;
    EXIT WHEN l_salaries%NOTFOUND;
    DBMS_OUTPUT.put_line (l_salary);
  END LOOP;
  CLOSE l_salaries;
END;
-----------
  function is_source_ready(ip_object_name varchar2, ip_owner varchar2 default 'TEST')
    return varchar2
    is
        cur_data        sys_refcursor;
        l_is_empty      varchar2(1 char);
        l_owner         varchar2(30 char);
        l_object_name   varchar2(30 char);
        
      begin
        l_owner:=upper(ip_owner);
        l_object_name:=upper(ip_object_name);
        
        open cur_data for 'select /*+ FIRST_ROWS(1) */ ''T''
                              from  '||l_owner||'.'||l_object_name||
                           ' where  1=1
                               AND  ROWNUM < 2';
            fetch cur_data into l_is_empty;
        close cur_data;
        return nvl(l_is_empty,'F');
   end;
-----------   