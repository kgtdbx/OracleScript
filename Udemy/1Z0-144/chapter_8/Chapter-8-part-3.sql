DECLARE
  CURSOR c_emp_dept(v_dept number) --here we defined the parameter without size
  is
  SELECT employee_id, first_name FROM employees
  where department_id=v_dept;
  
  v_empno employees.employee_id%type;
  v_first_name employees.first_name%type;

BEGIN
OPEN c_emp_dept(10);
  dbms_output.put_line('dept 10 contains:');
  loop
      fetch c_emp_dept into v_empno, v_first_name;
      exit when c_emp_dept%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
close c_emp_dept;

OPEN c_emp_dept(20);
  dbms_output.put_line('dept 20 contains:');
  loop
      fetch c_emp_dept into v_empno, v_first_name;
      exit when c_emp_dept%notfound;
      dbms_output.put_line(v_empno||' '||v_first_name);
  end loop;
close c_emp_dept;
END;
-------------------------------------------------------
-- we will do the same exmple using the for loop cursor

DECLARE
  CURSOR c_emp_dept(v_dept number) --here we defined the parameter without size
  is
  SELECT employee_id id , first_name FROM employees
  where department_id=v_dept;

BEGIN

  dbms_output.put_line('dept 10 contains:');
  for i in c_emp_dept (10)
  loop
      dbms_output.put_line(i.id||' '||i.first_name);
  end loop;


  dbms_output.put_line('dept 20 contains:');
  for j in c_emp_dept (20)
  loop

    dbms_output.put_line(j.id||' '||j.first_name);
  end loop;
END;




