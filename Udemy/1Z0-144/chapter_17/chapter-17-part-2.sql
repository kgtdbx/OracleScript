DROP TABLE EMP_COPY;

CREATE TABLE EMP_COPY
AS SELECT * FROM employees;

SELECT * FROM EMP_COPY;

create or replace trigger check_sal
before
insert or update of salary
on
EMP_COPY
for each row
begin
  if :new.salary<500 then
  raise_application_error(-20030, 'min sal is 500');
  end if;
end;
-------------------
update EMP_COPY
set salary=200
where employee_id=100;

UPDATE EMP_COPY
set salary=200;

SELECT COUNT(1) FROM EMP_COPY;

select * from user_triggers
where trigger_name='CHECK_SAL';

--------------------------------------------------------------------------------
create or replace trigger check_sal
before
insert or update of salary
on
EMP_COPY
REFERENCING NEW AS NEW OLD AS OLD
for each row
begin
  if :new.salary<500 then
    dbms_output.put_line('s');
end if;
end;

update EMP_COPY
set salary=200
where employee_id=100;

update EMP_COPY
set salary=200;
----

create or replace trigger check_sal
before
insert or update of salary
on
EMP_COPY
REFERENCING NEW AS N OLD AS O
for each row
begin
  if :n.salary<500 then
    dbms_output.put_line('s');
end if;
end;
--------
  
update EMP_COPY
set salary=200
where employee_id=100;

update EMP_COPY
set salary=200;

