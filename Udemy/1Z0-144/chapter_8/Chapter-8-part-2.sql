--using c_emp%notfound, c_emp%isopen,c_emp%rowcount
DECLARE
  CURSOR c_emp is
  SELECT employee_id,first_name FROM employees;
  v_empno employees.employee_id%type;
  v_first_name employees.first_name%type;

BEGIN
 if c_emp%isopen then
 null;
 else
 open c_emp;
 end if;
    dbms_output.put_line('the counter for cursor now is '||c_emp%rowcount);
  loop
      fetch c_emp into v_empno, v_first_name;
      exit when c_emp%notfound or  c_emp%rowcount>10 ;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
    dbms_output.put_line('the counter for cursor now is '||c_emp%rowcount);
  close c_emp;
END;
---------------------------

--basic loop cursor 
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
--------------------------
--we will use same example above but using for loop cursor
DECLARE
  CURSOR c_emp_dept30 is
  SELECT employee_id, first_name FROM employees
  where department_id=30;


BEGIN

  for i in c_emp_dept30
  loop
    dbms_output.put_line(i.employee_id||' '||i.first_name);
  end loop;

END;
-----------------------

--another way is use the select inside the for 
DECLARE

BEGIN

  for i in (  SELECT employee_id, first_name FROM employees
  where department_id=30)
  
  loop
    dbms_output.put_line(i.employee_id||' '||i.first_name);
  end loop;

END;





