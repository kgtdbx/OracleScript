drop table emp_copy;

create table emp_copy
as select * from employees;

select * from emp_copy;

drop table EMP_SAL_AUDIT;

CREATE TABLE EMP_SAL_AUDIT
(	EMP_ID NUMBER, 
	OPERATION VARCHAR2(20), 
	OLD_SAL NUMBER, 
	NEW_SAL NUMBER, 
	OP_DATE DATE, 
	BY_USER VARCHAR2(100)
);

--now we need to create trigger for audit
create or replace trigger emp_copy_sal_audit
after insert or update of salary or delete
on emp_copy
for each row
begin
  if inserting then
  insert into EMP_SAL_AUDIT(EMP_ID,OPERATION,OLD_SAL,NEW_SAL,OP_DATE,BY_USER)
  values               (:new.employee_id,'Inserting',null,:new.salary,sysdate,user);
  end if;
  
  if updating then
  insert into EMP_SAL_AUDIT(EMP_ID,OPERATION,OLD_SAL,NEW_SAL,OP_DATE,BY_USER)
  values               (:old.employee_id,'updating',:old.salary,:new.salary,sysdate,user);
  end if;

  if deleting then
  insert into EMP_SAL_AUDIT(EMP_ID,OPERATION,OLD_SAL,NEW_SAL,OP_DATE,BY_USER)
  values               (:old.employee_id,'deleting',:old.salary,null,sysdate,user);
  end if;

end;

--note1: we dont use commit or rollback in triggers
--the commit or rollback should be in the main transaction(DML)

--1 testing the insert operation

insert into emp_copy (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,salary,hire_date,job_id)
values               (1,'ahmed','naser','ahmed.n@hotmail.com',900,sysdate,'AD_PRES');

select * from emp_copy
where EMPLOYEE_ID=1;

select EMP_ID,OPERATION,OLD_SAL,NEW_SAL,
to_char(OP_DATE,'dd-mm-yyyy hh24:mi:ss')OP_DATE ,BY_USER 
from EMP_SAL_AUDIT
order by OP_DATE;

--2 testing the update operation

update emp_copy
set salary=salary +10
where department_id=20;

select EMP_ID,OPERATION,OLD_SAL,NEW_SAL,
to_char(OP_DATE,'dd-mm-yyyy hh24:mi:ss')OP_DATE ,BY_USER 
from EMP_SAL_AUDIT
order by OP_DATE;

--3 Testing the delete

delete from emp_copy
where EMPLOYEE_ID=1;

select EMP_ID,OPERATION,OLD_SAL,NEW_SAL,
to_char(OP_DATE,'dd-mm-yyyy hh24:mi:ss')OP_DATE ,BY_USER 
from EMP_SAL_AUDIT
order by OP_DATE;






