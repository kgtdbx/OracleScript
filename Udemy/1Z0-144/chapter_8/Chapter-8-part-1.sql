select * from employees
where department_id=30;
----------------------
--create cursor to print employee_id, first_name  for department_id =30 
--method 1
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
      dbms_output.put_line(v_empno||' '||v_first_name); -- the exit should before output
  end loop;
close c_emp_dept30;
END;
----------------------------------------------------

--method 2
DECLARE
  CURSOR c_emp_dept30 is
  SELECT  employee_id, first_name FROM employees
  where department_id=30;
  
   v_emp_rec employees%rowtype;
  
BEGIN
OPEN c_emp_dept30;

  loop
      fetch c_emp_dept30 into v_emp_rec.employee_id,v_emp_rec.first_name ;
      exit when c_emp_dept30%notfound;
      dbms_output.put_line(v_emp_rec.employee_id||' '||v_emp_rec.first_name);
  end loop; 
  close c_emp_dept30;
END;
----------------------------------------------------

--method 3
--pl/sql records based on cursor, this is the 3rd method for creating pl/sql records
-- 1 is programmer, 2 is %rowtype, 3 is cursor records
DECLARE
  CURSOR c_emp_dept30 is
  SELECT  employee_id, first_name FROM employees
  where department_id=30;
  
   v_emp_rec c_emp_dept30%rowtype;   
BEGIN
OPEN c_emp_dept30;

  loop
      fetch c_emp_dept30 into v_emp_rec;
      exit when c_emp_dept30%notfound;
      dbms_output.put_line(v_emp_rec.employee_id||' '||v_emp_rec.first_name);
  end loop;
close c_emp_dept30;
END;

------------------------------------------------------
--update the salaries for employees in  dept30 using cursor ( +100 for each one )

DECLARE
  CURSOR c_emp_dept30 is
  SELECT employee_id, first_name,salary FROM employees
  where department_id=30;
  
  v_empno employees.employee_id%type;
  v_first_name employees.first_name%type;
  v_salary employees.salary%type;
BEGIN
OPEN c_emp_dept30;
 loop
      fetch c_emp_dept30 into v_empno, v_first_name,v_salary;
      exit when c_emp_dept30%notfound;
      update employees
      set salary=salary+100
      where employee_id=v_empno;
  end loop; 
  close c_emp_dept30;
  commit;
END;
---------
select * from employees
where department_id=30;


