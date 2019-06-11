--example 1
drop table emp_copy;

create table emp_copy
as 
select * from employees;

select * from emp_copy;

create or replace view v_emp_copy
as
select * from emp_copy;

select object_name,object_type, status 
from user_objects
where object_name='V_EMP_COPY';

drop table emp_copy;


select object_name,object_type, status 
from user_objects
where object_name='V_EMP_COPY';

select * from v_emp_copy
-----------------

--example 2
drop table dept_copy;

create table dept_copy
as
select * from departments;

select * from dept_copy;

create or replace view v_dept_copy
as
select department_id, department_name
from dept_copy;

select object_name,object_type, status 
from user_objects
where object_name='V_DEPT_COPY';

ALTER TABLE dept_copy
ADD ( DSIZE NUMBER);


select object_name,object_type, status 
from user_objects
where object_name='V_DEPT_COPY';

alter table dept_copy
drop column department_name;

select object_name,object_type, status 
from user_objects
where object_name='V_DEPT_COPY';









