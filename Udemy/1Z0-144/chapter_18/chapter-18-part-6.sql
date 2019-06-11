CREATE OR REPLACE TRIGGER before_create_trigger
BEFORE CREATE
 ON SCHEMA
BEGIN
if  to_number(to_char(sysdate,'hh24')) not between 8 and 16 then
raise_application_error(-20001, 'Create not Allowed now');
end if;
END;

create table  t2 (value1 number );

create or replace view x_y as select * from employees;

drop trigger before_create_trigger
-------------------------------------------------------

drop table ddl_log;

CREATE TABLE ddl_log (
 operation   VARCHAR2(30),
 obj_owner   VARCHAR2(30),
 object_name VARCHAR2(30),
 attempt_by  VARCHAR2(30),
 attempt_dt  DATE); 

CREATE OR REPLACE TRIGGER before_create_trigger
after DDL
 ON SCHEMA
BEGIN
   INSERT INTO ddl_log
   SELECT ora_sysevent, ora_dict_obj_owner,
   ora_dict_obj_name, USER, SYSDATE
   FROM DUAL;
END;


select * from ddl_log;

create table tabl1( n number );

select * from ddl_log;

alter table tabl1 
add x number;

select * from ddl_log;

drop table tabl1;

select * from ddl_log;

