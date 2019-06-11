select * from employees
where employee_id=1;
----------------------

declare
v_employee_id number:=1;

begin
update employees
set salary=20000
where employee_id=v_employee_id;

dbms_output.put_line(sql%rowcount);

end;
--------------------------------------


declare
v_employee_id number:=1;
e_invalid_no exception;
begin

update employees
set salary=20000
where employee_id=v_employee_id;
 
 dbms_output.put_line(sqlcode);
 dbms_output.put_line(sqlerrm);
 
 if sql%notfound then
 raise e_invalid_no;
 end if;
 
 commit;

 exception 
 when e_invalid_no then
 dbms_output.put_line('invalid emp ID');
 dbms_output.put_line(sqlcode);
 dbms_output.put_line(sqlerrm);
end;
------------------------


declare
v_employee_id number:=1;
---e_invalid_no exception;
begin

update employees
set salary=20000
where employee_id=v_employee_id;
 

 if sql%notfound then
 ---raise e_invalid_no;
 raise_application_error(-20000, 'invalid emp ID');
 end if;
 
 commit;

end;

