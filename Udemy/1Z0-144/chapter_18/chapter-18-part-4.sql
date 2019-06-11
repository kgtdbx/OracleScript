select * from employees
where job_id='IT_PROG'
order by salary;


drop trigger IT_PROG_range;

select job_id, min(salary),max(salary)
from employees
group by job_id
order by 1;


create or replace trigger salary_range
before 
insert OR UPDATE
on employees
for each row
declare
v_min_sal number;
v_max_sal number;
begin
   select min(salary), max(salary)
   into v_min_sal,v_max_sal
   from employees
   where job_id=:new.job_id;
   
   if :new.salary not between v_min_sal and v_max_sal then
   raise_application_error (-20300,'invalid range');
   end if;
end;

select * from employees
where Job_id='IT_PROG'
order by salary;

UPDATE employees
SET SALARY=6000
WHERE employee_ID=107;
-----------------------------------------
/* we should save the result of query
select job_id, min(salary),max(salary)
from employees
group by job_id
order by 1
into array 
*/



create or replace trigger salary_range
for 
insert OR UPDATE
on employees
compound trigger
  type job_t is record( minsal number,maxsal number);
  type emp_t is table of job_t index by varchar2(100);
  emp emp_t;
 before statement is
   begin
         for i in(
              select job_id, min(salary) min_sal ,max(salary) max_sal
              from employees
              group by job_id order by 1
              )
              loop
              emp(i.job_id).minsal:=i.min_sal;
              emp(i.job_id).maxsal:=i.max_sal;
             end loop;
   end before statement;
   
   before each row is
   begin
   if :new.salary not between emp(:new.job_id).minsal and emp(:new.job_id).maxsal then
   raise_application_error (-20300,'invalid range');
   end if;
   end before each row;
   
end;
----------

select * from employees
where Job_id='IT_PROG'
order by salary;

UPDATE employees
SET SALARY=100
WHERE employee_ID=107;










