--this a normal select 
select * from employees
where employee_id in (100,200)
order by 1;

/*when you put for update, then no one can do any DML(I,U,D)
for theses records, untill you finish your trans ( commit, update ) 
after you execute the next statement try to open another session 
and do like 
  update
  employees
  set salary = salary+100;
*/

select * from employees
where employee_id in (100,200)
order by 1
for update;

commit;


DECLARE
  CURSOR c_emp_dept30 is
  SELECT employee_id, first_name,salary FROM employees
  where department_id=30
  for update;
  
BEGIN

 for i in c_emp_dept30
 loop
      update employees
      set salary=salary+1
      where employee_id=i.employee_id;
      
  end loop; 
  commit;
END;
---
select * from employees
where department_id=30;

-----------
---current of  ------
DECLARE
  CURSOR c_emp_dept30 is
  SELECT employee_id, first_name,salary FROM employees
  where department_id=30
  for update;
  
BEGIN

 for i in c_emp_dept30
 loop
      update employees
      set salary=salary-1
      where current of  c_emp_dept30;   
  end loop; 
  commit;
END;
---
select * from employees
where department_id=30;




