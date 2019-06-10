--execute immediate with dynamic string
drop table emp1;
create table emp1 ( emp_id number );

drop table emp2;
create table emp2 ( emp_id number );

begin
insert into emp1 values (1);
insert into emp1 values (2);
insert into emp1 values (3);
insert into emp2 values (1);
insert into emp2 values (2);
insert into emp2 values (3);
commit;
end;

select * from emp1;
select * from emp2;

create or replace procedure delete_any_table
( p_table_name varchar2)
is
v_no_rec number;
begin
execute immediate 'delete from '||p_table_name;
v_no_rec:=sql%rowcount;
commit; --same rules for commit and rollback
dbms_output.put_line(v_no_rec ||' record(s) deleted form '||p_table_name );
end;

execute delete_any_table('emp1');
select * from emp1;

--try to give dummy table which not exists
--so the parsing will be on runtime :)
execute delete_any_table('dfd');
-----------------------------------------------------------

--DDL and DCL not allowed in PLSQL block
--we also use execute immediate
drop table emp3;

begin
create table emp3 ( emp_id number );
end;

begin
--no need for ; at end of the statement
execute immediate 'create table emp3 ( emp_id number )' ;
end;

select * from emp3;
-------------------------------------------------------------

create or replace procedure create_any_table
(p_table_name varchar2,p_details varchar2)
is
v_details varchar2(30000);

begin
v_details:='create table '||p_table_name||' ('||p_details||')' ;
dbms_output.put_line(v_details);
execute immediate v_details;
end;


execute create_any_table ('emp4','emp_id number, name varchar2(100)' );
select * from emp4;

--it could give you this ORA-01031: insufficient privileges

select * from USER_SYS_PRIVS
--the create table PRIVS should be direct, not using a role
--conn sys as sysdba, grant create table to hr


execute create_any_table ('emp4','emp_id number, name varchar2(100)' );

select * from emp4;




