declare
v_empno number:=10;
v_ename varchar2(100):='khaled';
v_salary employees.salary%TYPE;
V_HIRE_PERIOD  interval YEAR TO MONTH;
v_empno1 v_empno%type; --it will not be initilized like v_empno
begin
dbms_output.put_line(v_empno);
dbms_output.put_line(v_ename);
v_salary :=5000;
dbms_output.put_line(v_salary);
V_HIRE_PERIOD:= '1-3';
dbms_output.put_line(V_HIRE_PERIOD);
dbms_output.put_line(v_empno1);
end;
-------------------------------------------------

--write a pl/sql block to print the first name and the last name for employee=100
select first_name,last_name 
from
employees
where employee_id=100;

declare
v_fname employees.first_name%type;
v_lname employees.last_name%type;
begin
-- The select should retrieve 1 record, otherwise it will be exception
  select first_name,last_name 
  into v_fname, v_lname
  from
  employees
  where employee_id=100;

dbms_output.put_line('first name: '||v_fname );
dbms_output.put_line('last name: '||v_lname );
end;
------------


--example of exception

declare
v_fname employees.first_name%type;
v_lname employees.last_name%type;
begin
-- The query will not retrieve any record, it will be exception
select first_name,last_name 
into v_fname, v_lname
from
employees
where employee_id=9000;

dbms_output.put_line('first name: '||v_fname );
dbms_output.put_line('last name: '||v_lname );
end;









