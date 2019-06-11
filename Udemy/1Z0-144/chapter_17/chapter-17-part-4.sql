--we will create 4 triggers for same table
--1  before statment
--2  before for each row
--3 after each row
--4  after statment
-- we want to know the sequence for firing the triggers
drop table test_emp;

create table test_emp
( emp_id number,
  first_name varchar2(100) 
);

drop table test_emp_sequence;

create table test_emp_sequence
( seq number,
 trigger_type varchar2(100)
 );
 
drop sequence s;

create sequence s;

--1  before statment

create or replace trigger before_insert_stat
before 
insert
on test_emp
begin
insert into test_emp_sequence values (s.nextval,'before_insert_stat');
end;

--2  before  each row

create or replace trigger before_insert_each_row
before 
insert
on test_emp
for each row
begin
insert into test_emp_sequence values (s.nextval,'before_insert_each_row');
end;



--3 after each row
create or replace trigger after_insert_each_row
after 
insert
on test_emp
for each row
begin
insert into test_emp_sequence values (s.nextval,'after_insert_each_row');
end;
 
--4  after statment
create or replace trigger after_insert_stat
after 
insert
on test_emp
begin
insert into test_emp_sequence values (s.nextval,'after_insert_stat');
end;
--------------- 
insert into  test_emp
values (1,'mazen');

select * from test_emp_sequence
order by seq;

insert into  test_emp
select employee_id, first_name
from
employees
where department_id = 20;

select * from test_emp_sequence
order by seq;

--to compile trigger
alter trigger after_insert_each_row compile;

--to disable all triggers on a table
alter table test_emp disable all triggers;

--to enbale all triggers on a table
alter table test_emp enable all triggers;

--to disable or enable specific trigger
alter trigger after_insert_stat enable;
alter trigger after_insert_stat disable;

--to drop trigger

drop trigger after_insert_stat;





 
