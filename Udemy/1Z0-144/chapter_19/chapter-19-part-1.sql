SELECT name, value
FROM v$parameter
WHERE name ='plsql_code_type' ;


drop procedure p1;

create or replace procedure p1 
is
begin
dbms_output.put_line('P1');
end;

select * from user_plsql_object_settings
where name ='P1';

ALTER SESSION SET plsql_code_type=native; --you can do alter system, but this for DBA

--still the P1  =INTERPRETED
select * from user_plsql_object_settings
where name ='P1'

--so we should compile again 

create or replace procedure p1 
is
begin
dbms_output.put_line('P1');
end;

select * from user_plsql_object_settings
where name ='P1'
---------------------------------------------------------------
--now let us see the perf.

ALTER SESSION SET plsql_code_type=INTERPRETED;

create or replace procedure p1
is
n number:=0;
begin
for i in 1..500000000
loop
n:=n+1;
end loop;
end;

exec p1

alter procedure p1 compile  plsql_code_type=native;

exec p1

