--dynamic sql with multi row query
--first we need to know what is REF cursor

--1 let us review the normal cursor
DECLARE
  CURSOR c_emp_dept30 is
  SELECT employee_id, first_name FROM employees
  where department_id=30;
  
  v_empno employees.employee_id%type;
  v_first_name employees.first_name%type;

BEGIN
OPEN c_emp_dept30;

  loop
      fetch c_emp_dept30 into v_empno, v_first_name;
      exit when c_emp_dept30%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
close c_emp_dept30;
END;

-----------------------------------
-- the ref cursor can be opend many times with dif query
DECLARE
type  c_emp_dept is ref cursor;
d_cursor c_emp_dept;
  
  v_empno employees.employee_id%type;
  v_first_name employees.first_name%type;

BEGIN
OPEN d_cursor for select employee_id,first_name 
                   from employees
                   where department_id=10;
   loop
      fetch d_cursor into v_empno, v_first_name;
      exit when d_cursor%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
close d_cursor;

OPEN d_cursor for select employee_id,first_name 
                   from employees
                   where department_id=30;
   loop
      fetch d_cursor into v_empno, v_first_name;
      exit when d_cursor%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
close d_cursor;

END;
--------------------------------

--dynamic sql with multi row query
create or replace procedure emp_list ( p_dept_id number default null )
is
type  c_emp_dept is ref cursor;
d_cursor c_emp_dept;
v_empno employees.employee_id%type;
v_first_name employees.first_name%type;
v_sql varchar2(1000):='select employee_id, first_name from employees';
begin
   if p_dept_id is null then
   open d_cursor for v_sql;
   else
   v_sql:=v_sql||'  where department_id=:id';
   open d_cursor for v_sql using p_dept_id;
   end if;
     
     loop
      fetch d_cursor into v_empno, v_first_name;
      exit when d_cursor%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
    end loop;
close d_cursor; 
end;

--to get all the employees
execute emp_list;

--to get all the employees in specific dept
execute emp_list (30);






