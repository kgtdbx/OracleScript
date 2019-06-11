declare
v_counter number:=1;
begin

 while v_counter<=3
 loop
 dbms_output.put_line('welcome');
  v_counter:=v_counter+1;
 end loop;

end;
--------

--print the employees first name for employee 100,101,102 
--using while loop
declare
v_empno number:=100;
v_first_name employees.first_name%type ;
begin
  while v_empno<=102
  loop
  select first_name into v_first_name
  from employees
  where employee_id = v_empno;
  
  dbms_output.put_line(v_empno ||' '|| v_first_name);
  
    v_empno:=v_empno+1; 
  
  end loop;
end;