/* 1-  create a procedure that take emp_id as parameter and return the 
firat_name and salary
note: use bind variable to print the firat_name and salary
*/

create or replace procedure query_emp
(p_emp_id employees.employee_id%type, 
 p_f_name out employees.first_name%type, 
 p_sal out employees.salary%type
 )
is

begin
   select first_name,salary
   into p_f_name,p_sal
   from
   employees
   where employee_id=p_emp_id;

exception
when others then 
dbms_output.put_line(sqlcode);
dbms_output.put_line(sqlerrm);

end;
-----------------------------------------------------------------------
--you should declare 2 bind variables
variable b_first_name varchar2(100)
variable b_sal number

execute query_emp(105,:b_first_name,:b_sal )

print b_first_name b_sal ;
-----------------------------------------------------------------------

--2 the other way to print the out parameter

declare
v_first_name employees.first_name%type;
v_sal employees.salary%type;
begin
 query_emp(105,v_first_name,v_sal );
 dbms_output.put_line(v_first_name);
  dbms_output.put_line(v_sal);
end;


