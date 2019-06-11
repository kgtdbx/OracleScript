alter session set container=orclpdb --only for 12c

create user hr2 identified by hr2;
grant create session to hr2;
grant create table,create view to hr2; 
grant  create procedure to hr2;
grant create synonym, create trigger to hr2;
grant unlimited tablespace to hr2;