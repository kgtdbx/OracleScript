drop table customers;

create table customers
( cust_id number,
  cust_name varchar2(100)
);

select max(cust_id) from  customers;
select nvl(max(cust_id),0) from  customers;

create or replace trigger customers_seq
before insert 
on
customers
for each row
declare --use declare when you want define variables
v_max_id number;
begin
  select nvl(max(cust_id),0) +1 
  into v_max_id
  from customers;

  :new.cust_id:= v_max_id;
end;
------------
--now let us try to insert a record
insert into customers (cust_name) values ('oracle');

select * from customers;

insert into customers (cust_name) values ('Khaled');

select * from customers

insert into customers (cust_name) 
select first_name 
from employees;
--ORA-04091: table HR.CUSTOMERS is mutating
--THE TRIGGER CODE QUERY SAME RECORD inserted 


-------------------------------------

select * from employees
where job_id='IT_PROG'
order by salary;

--i want to create trigger that prevent insert/update any employee with job=IT_PROG
--and his salary out of ranges of IT_PROG

create or replace trigger IT_PROG_range
before 
insert OR UPDATE
on employees
for each row
when (new.job_id='IT_PROG')
declare
v_min_IT_PROG number;
v_max_IT_PROG number;
begin
   select min(salary), max(salary)
   into v_min_IT_PROG,v_max_IT_PROG
   from employees
   where job_id=:new.job_id;
   
   if :new.salary not between v_min_IT_PROG and v_max_IT_PROG then
   raise_application_error (-20300,'invalid range');
   end if;
end;
------
insert into employees
(EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,
SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID
)
VALUES
(900,'NADIA','AHMED','TEST@GMAIL.COM',null,sysdate,'IT_PROG',
1500,0,null,90
);

--NOW THIS WILL GIVE ERROR able HR.EMPLOYEES is mutating
--THE TRIGGER CODE QUERY SAME RECORD UPDATED 
UPDATE employees
SET SALARY=6000
WHERE employee_ID=107;

--the solution is


create or replace trigger IT_PROG_range
for 
insert OR UPDATE
on employees
when (new.job_id='IT_PROG')
compound trigger
v_min_IT_PROG number;
v_max_IT_PROG number;
   before statement is
   begin
     select min(salary), max(salary)
     into v_min_IT_PROG,v_max_IT_PROG
     from employees
     where job_id='IT_PROG';
   end before statement;
   
   before each row is
   begin
     if :new.salary not between v_min_IT_PROG and v_max_IT_PROG then
     raise_application_error (-20300,'invalid range');
     end if;
   end before each row;
end;


UPDATE employees
SET SALARY=200
WHERE employee_ID=107;









