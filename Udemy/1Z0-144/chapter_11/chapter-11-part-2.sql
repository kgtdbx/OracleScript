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

begin
dbms_output.put_line (get_sal(100));
end;

--NOW LET TRY THIS 
begin
dbms_output.put_line(get_sal(9999))  ;
end;


select get_sal(9999) from dual;
--no data found not raised in select query :) 

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





