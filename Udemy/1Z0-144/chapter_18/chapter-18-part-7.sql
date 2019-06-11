alter session set container=orclpdb;
show con_name

drop table log_table;

create table log_table
(user_id varchar2(100),
 log_date date,
 action varchar2(100)
 );
 
create or replace trigger logon_t
after 
logon
on database
begin
insert into log_table values (user,sysdate,'logon');
end;

create or replace trigger logoff_t
before 
logoff
on database
begin
insert into log_table values (user,sysdate,'logoff');
end;

--use sqlplus and logon by hr
--hr/hr@orclpdb
select user_id,to_char(log_date,'dd-mm-yyyy hh:mi:ss'), action
from log_table;

drop trigger logon_t;
drop trigger logoff_t;


