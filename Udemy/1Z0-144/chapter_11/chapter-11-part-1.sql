--create a function to return the salary for an employee
-- so we need one parameter (in )  number  ( employee_id )
--the return value should be also number  because it is the salary

create or replace function get_sal
(p_emp_id number)
return number
is
v_sal number;
begin 
  select salary into v_sal
  from employees
  where employee_id=p_emp_id;
  
  return v_sal;
  
end;
------------------------------------------
--now we have many methods to invoke the function

--1 as part of expression 
declare
v_sal number;
begin
v_sal:=get_sal(100);
dbms_output.put_line (v_sal);
end;
--------------

--2 as parameter value
begin
dbms_output.put_line (get_sal(100));
end;
----------------
--also we do this
execute dbms_output.put_line (get_sal(100) );

--3 using host variable
variable b_salary number;

execute :b_salary:=get_sal(100)

print b_salary
----------------------------------

--4 as part of select 

select get_sal(100) from dual;

select employee_id,first_name, get_sal(employee_id)
from employees
where department_id=20;
----------------

select * from user_objects
where object_name='GET_SAL';

SELECT LINE, TEXT 
FROM USER_SOURCE
WHERE NAME='GET_SAL';

--NOW LET TRY THIS 
begin
dbms_output.put_line(get_sal(9999))  ;
end;


select get_sal(9999) from dual;
--no data found not raised in select query :) because the function not have exp

create or replace function get_sal
(p_emp_id number)
return number
is
v_sal number;
begin 
  select salary into v_sal
  from employees
  where employee_id=p_emp_id;
  
  return v_sal;
  exception 
  when no_data_found then
  return -1;
  
end;


select get_sal(9999) from dual;





