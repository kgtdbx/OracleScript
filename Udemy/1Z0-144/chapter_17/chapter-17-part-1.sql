delete from departments;
-- let us do statment level trigger

create or replace trigger dept_check_time
before
insert or update or delete
on DEPARTMENTS
begin

  if  to_number (to_char(sysdate,'hh24') ) not between 8 and 16 then
  raise_application_error(-20010, 'DML operations not allowed now ');
  end if;

end;

--try to test the trigger
delete from departments;

delete from departments
where department_id=-4;

select * from user_objects
where object_name='DEPT_CHECK_TIME';

select * from user_triggers
where trigger_name='DEPT_CHECK_TIME';

-------------------------------


create or replace trigger dept_check_time
before
insert or update or delete
on DEPARTMENTS
begin

  if  to_number (to_char(sysdate,'hh24') ) not between 8 and 16 then
     if inserting then
     raise_application_error(-20010, 'Insert operations not allowed now ');
     elsif deleting then
     raise_application_error(-20011, 'Delete operations not allowed now ');
     elsif updating then
     raise_application_error(-20012, 'Update operations not allowed now ');
     end if;
  end if;

end;

delete from departments;

update departments
set department_name='x'
where department_id = -5;

