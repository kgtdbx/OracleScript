delete from employees
where employee_id=10;

DROP VIEW emp_all_v;

create or replace view emp_all_v
as select * from employees;

select * from emp_all_v;

INSERT INTO emp_all_v
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,
SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID
)
VALUES
(10,'OMAR','AHMED','TEST@GMAIL.COM',null,sysdate,'AD_PRES',
1500,0,null,90
);

select * from employees
where employee_id=10;

rollback;
--------------------------------------------

create or replace trigger TEST_INSTEAD
instead of
insert 
on emp_all_v
begin
 
DBMS_OUTPUT.PUT_LINE('TEST');

end;


INSERT INTO emp_all_v
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,
SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID
)
VALUES
(10,'OMAR','AHMED','TEST@GMAIL.COM',null,sysdate,'AD_PRES',
1500,0,null,90
);

select * from employees
where employee_id=10;

rollback;

------------------------------------------------
create or replace trigger TEST_INSTEAD
instead of
insert 
on emp_all_v
begin
 
 INSERT INTO employees
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,
SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID
)
VALUES
(:new.EMPLOYEE_ID,:new.FIRST_NAME,:new.LAST_NAME,:new.EMAIL,:new.PHONE_NUMBER,:new.HIRE_DATE,:new.JOB_ID,
:new.SALARY,:new.COMMISSION_PCT,:new.MANAGER_ID,:new.DEPARTMENT_ID
);
 
DBMS_OUTPUT.PUT_LINE('TEST');

end;


INSERT INTO emp_all_v
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,
SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID
)
VALUES
(10,'OMAR','AHMED','TEST@GMAIL.COM',null,sysdate,'AD_PRES',
1500,0,null,90
);



select * from employees
where employee_id=10;












