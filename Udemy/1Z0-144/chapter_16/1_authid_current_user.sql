drop table hr_table;

create table hr_table
( id number,
  name varchar2(100)
);

---------
create or replace procedure add_hr_table
( p_id number, p_name varchar2 )
is
begin
insert into hr_table values (p_id,p_name);
end;

--now conn as sys as sysdba and create user called jake (orclpdb)
--alter session set container=orclpdb
--create user ford identified by ford;
-- grant create session, connect to ford;

--user hr will give jake execute to add_hr_table
grant execute on add_hr_table to ford;

--now connect as ford
-- execute hr.add_hr_table(1,'khaled');
--he can execute even if he doesnt access to table hr_table


select * from hr_table;
-------------------------------------------------------------

--now user hr will create the proc again but adding authid current_user
create or replace procedure add_hr_table
( p_id number, p_name varchar2 ) authid current_user
is
begin
insert into hr.hr_table values (p_id,p_name);
end;
--now connect as ford
-- execute hr.add_hr_table(1,'khaled');
--now he can not insert, he should priv insert to hr_table




