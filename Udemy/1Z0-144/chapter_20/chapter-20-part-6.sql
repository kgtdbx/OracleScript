--1 take the code between /* */ and save in script test.sql in f: for example
drop table table_1;
drop procedure insert_table_1;

/*
create table table_1
( id number,
  name varchar2(100)
);

insert into table_1 values (1,'nader ali');
insert into table_1 values (2,'khaled rami');
insert into table_1 values (3,'naser hassan');
insert into table_1 values (4,'ameen hadi');

create or replace procedure insert_table_1
(p_id number, p_name varchar2)
is
begin
insert into table_1 values (p_id,p_name);
commit;
end;
*/


--2
--now open cmd command
--go to f:
--and do this   wrap iname=test.sql

--3 now you can do this

@f:\test.plb

select * from table_1;

exec insert_table_1 (5,'ahmed alali');

select line,text from user_source
where name=upper('insert_table_1');





