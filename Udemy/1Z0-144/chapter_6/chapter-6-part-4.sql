
--basic loop
--write a basic loop to print welcome 3 times

declare
v_counter number:=0;
begin
 loop
 v_counter:=v_counter+1;
 dbms_output.put_line('welcome ' ||v_counter);
 
 exit when v_counter=3;
 end loop;

end;
--------------------------------------

--another method

 declare
v_counter number:=0;
begin
 loop
 v_counter:=v_counter+1;
 dbms_output.put_line('welcome ' ||v_counter);
 
       if v_counter=3 then
       exit;
       end if;
 
 end loop;
end;
-------------------------------------------

--print the employees first name for employee 100,101,102 
--using basic loop
declare
v_empno number:=100;
v_first_name employees.first_name%type ;
begin
  loop
    
  exit when v_empno>102;
    
  select first_name into v_first_name
  from employees
  where employee_id = v_empno;
  
  dbms_output.put_line(v_empno ||' '|| v_first_name);
  
    v_empno:=v_empno+1;

  
  end loop;
end;



