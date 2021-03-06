
--drop table ddl_log; 

CREATE TABLE ddl_log (
operation   VARCHAR2(30),
obj_owner   VARCHAR2(30),
object_name VARCHAR2(30),
sql_text    VARCHAR2(64),
attempt_by  VARCHAR2(30),
os_user     VARCHAR2(30),
attempt_dt  DATE);


CREATE OR REPLACE TRIGGER bco_trigger
BEFORE CREATE
ON SCHEMA

DECLARE
 oper ddl_log.operation%TYPE;
BEGIN
  INSERT INTO ddl_log
  SELECT ora_sysevent, ora_dict_obj_owner,
  ora_dict_obj_name, NULL, USER, SYS_CONTEXT ( 'userenv', 'OS_USER' ), SYSDATE
  FROM DUAL;
END bco_trigger;
/

col object_name format a20

SELECT object_name, object_type
FROM user_objects;


col triggering_event format a20
SELECT trigger_name, trigger_type, 
triggering_event, base_object_type
FROM user_triggers;

SELECT * FROM ddl_log;

--truncate table ddl_log;

CREATE OR REPLACE TRIGGER bdd_trigger
BEFORE DROP
ON DATABASE

DECLARE
 oper ddl_log.operation%TYPE; 
BEGIN
  INSERT INTO ddl_log
  SELECT ora_sysevent, ora_dict_obj_owner, 
  ora_dict_obj_name, NULL, USER, SYS_CONTEXT ( 'userenv', 'OS_USER' ), SYSDATE
  FROM DUAL;
END bdd_trigger;
/


 --DROP VIEW V_PRODUCT_FEATURE;

/*
  CREATE OR REPLACE FORCE VIEW "DEPOSITS"."V_PRODUCT_FEATURE" ("PRODUCT_ID", "FEATURE_ID", "FEATURE_TYPE_CD", "FEATURE_SUBTYPE_CD", "FEATURE_GROUP_ID", "FEATURE_CD") AS 
  select
    p.PRODUCT_ID,
    p.FEATURE_ID,
    FEATURE_TYPE_CD,
    FEATURE_SUBTYPE_CD,
    p.feature_group_id,
    p.FEATURE_CD
from products.v_product_feature p
;
*/




CREATE OR REPLACE TRIGGER no_xtabs
BEFORE CREATE
ON SCHEMA

DECLARE
 x user_tables.table_name%TYPE; 
BEGIN
  SELECT ora_dict_obj_name
  INTO x
  FROM DUAL;

  IF SUBSTR(x, 1, 1) = 'X' THEN
    RAISE_APPLICATION_ERROR(-20099, 'Table Names Can Not Start With The Letter X');
  END IF;
END no_xtabs;
/


------------http://psoug.org/reference/ddl_trigger.html------------

--General
--Dependant Objects	 
trigger$	dba_triggers	all_triggers	user_triggers

--System Privileges	
create trigger
create any trigger
administer database trigger -- required for ON DATABASE
alter any trigger
drop any trigger

--DDL Trigger - Triggering Operations	BEFORE / AFTER ALTER
BEFORE / AFTER ANALYZE
BEFORE / AFTER ASSOCIATE STATISTICS
BEFORE / AFTER AUDIT
BEFORE / AFTER COMMENT
BEFORE / AFTER CREATE
BEFORE / AFTER DDL
BEFORE / AFTER DISASSOCIATE STATISTICS
BEFORE / AFTER DROP
BEFORE / AFTER GRANT
BEFORE / AFTER NOAUDIT
BEFORE / AFTER RENAME
BEFORE / AFTER REVOKE
BEFORE / AFTER TRUNCATE
AFTER SUSPEND

--Database Level Event Triggers	

SELECT a.obj#, a.sys_evts, b.name
FROM trigger$ a,obj$ b
WHERE a.sys_evts > 0
AND a.obj#=b.obj#
AND baseobject = 0;
Schema Level Event Triggers	SELECT a.obj#, a.sys_evts, b.name
FROM trigger$ a,obj$ b
WHERE a.sys_evts > 0
AND a.obj#=b.obj#
AND baseobject = 88;
 
--Demo Table
--Demo User	
GRANT create session TO uwclass;
GRANT create procedure TO uwclass;
GRANT create sequence TO uwclass;
GRANT create table TO uwclass;
GRANT create trigger TO uwclass;
GRANT create view TO uwclass;

GRANT select ON gv_$open_cursor TO uwclass;

CONN uwclass/uwclass
Table To Capture DDL Trigger Output	CREATE TABLE ddl_log (
operation   VARCHAR2(30),
obj_owner   VARCHAR2(30),
object_name VARCHAR2(30),
sql_text    VARCHAR2(64),
attempt_by  VARCHAR2(30),
attempt_dt  DATE);
 
--DDL Triggers

--Trigger To Log A Single DDL Activity On A Schema	

CREATE OR REPLACE TRIGGER <trigger_name>
<BEFORE | AFTER> <triggering_action>
ON <SCHEMA | DATABASE>

DECLARE
 -- variable declarations
BEGIN
  -- trigger code
EXCEPTION
  -- exception handler
END <trigger_name>;
/
CREATE OR REPLACE TRIGGER bcs_trigger
BEFORE CREATE
ON SCHEMA

DECLARE
 oper ddl_log.operation%TYPE;
BEGIN
  INSERT INTO ddl_log
  SELECT ora_sysevent, ora_dict_obj_owner,
  ora_dict_obj_name, NULL, USER, SYSDATE
  FROM DUAL;
END bcs_trigger;
/

col object_name format a20

SELECT object_name, object_type
FROM user_objects;

col triggering_event format a20
SELECT trigger_name, trigger_type, 
triggering_event, base_object_type
FROM user_triggers;

SELECT * FROM ddl_log;

CREATE SEQUENCE s1_test;

CREATE TABLE t1_test (
testcol VARCHAR2(20));

CREATE OR REPLACE VIEW v_test AS
SELECT * FROM t_test;

set linesize 150

SELECT operation, obj_owner, object_name
FROM ddl_log;

TRUNCATE TABLE ddl_log;

conn system/manager

CREATE TABLE uwclass.xyz (
testcol VARCHAR2(20));

conn uwclass/uwclass

SELECT operation, obj_owner, object_name
FROM ddl_log;

TRUNCATE TABLE ddl_log;
 

--Trigger To Log A Single DDL Activity On The Database	
CREATE OR REPLACE TRIGGER <trigger_name>
<BEFORE | AFTER> <triggering_action>
ON <SCHEMA | DATABASE>

DECLARE
 -- variable declarations
BEGIN
  -- trigger code
EXCEPTION
  -- exception handler
END <trigger_name>;
/
conn system/manager

GRANT administer database trigger TO uwclass;

conn uwclass/uwclass

CREATE OR REPLACE TRIGGER bcd_trigger
BEFORE CREATE
ON DATABASE

DECLARE
 oper ddl_log.operation%TYPE; 
BEGIN
  INSERT INTO ddl_log
  SELECT ora_sysevent, ora_dict_obj_owner, 
  ora_dict_obj_name, NULL, USER, SYSDATE
  FROM DUAL;
END bcd_trigger;
/

col object_name format a20
SELECT object_name, object_type
FROM user_objects;

col triggering_event format a20
SELECT trigger_name, trigger_type, 
triggering_event, base_object_type
FROM user_triggers;

SELECT * FROM ddl_log;

CREATE SEQUENCE s2_test;

CREATE TABLE t2_test (
testcol VARCHAR2(20));

CREATE OR REPLACE VIEW v_test AS
SELECT * FROM t_test;

set linesize 150

SELECT operation, obj_owner, object_name
FROM ddl_log;

TRUNCATE TABLE ddl_log;

conn system/manager

CREATE TABLE uwclass.xyz (
testcol VARCHAR2(20));

conn uwclass/uwclass

SELECT operation, obj_owner, object_name
FROM ddl_log;

DROP TRIGGER bcd_trigger;

TRUNCATE TABLE ddl_log;
 

--Trigger To Log Multiple DDL Activities	
CREATE OR REPLACE TRIGGER <trigger_name>
<BEFORE | AFTER> <triggering_action> OR <trigger_action>
ON SCHEMA

DECLARE
 -- variable declarations
BEGIN
  -- trigger code
EXCEPTION
  -- exception handlers
END <trigger_name>;
/
desc ddl_log

CREATE OR REPLACE TRIGGER ddl_trigger
BEFORE CREATE OR ALTER OR DROP
ON SCHEMA

DECLARE
 oper ddl_log.operation%TYPE;
 sql_text ora_name_list_t;
 i        PLS_INTEGER; 
BEGIN
  SELECT ora_sysevent
  INTO oper
  FROM DUAL;

  i := sql_txt(sql_text);

  IF oper IN ('CREATE', 'DROP') THEN
    INSERT INTO ddl_log
    SELECT ora_sysevent, ora_dict_obj_owner, 
    ora_dict_obj_name, sql_text(1), USER, SYSDATE
    FROM DUAL;
  ELSIF oper = 'ALTER' THEN
    INSERT INTO ddl_log
    SELECT ora_sysevent, ora_dict_obj_owner, 
    ora_dict_obj_name, sql_text(1), USER, SYSDATE
    FROM sys.gv_$sqltext
    WHERE UPPER(sql_text) LIKE 'ALTER%'
    AND UPPER(sql_text) LIKE '%NEW_TABLE%';
  END IF;
END ddl_trigger;
/

col operation format a20
col obj_owner format a10

SELECT * FROM ddl_log;

conn / as sysdba

alter system flush shared_pool;
alter system flush shared_pool;

conn uwclass/uwclass

CREATE TABLE new_table (
charcol VARCHAR(20));

SELECT * FROM ddl_log;

ALTER TABLE new_table
ADD (numbcol NUMBER(10));

SELECT * FROM ddl_log;

DROP TABLE new_table PURGE;

SELECT * FROM ddl_log;

TRUNCATE TABLE ddl_log;
 

--DDL Trigger To Stop And Log Attempts To Drop Or Truncate

--Requires the stored procedure below is created first	
-- NOTE: Be sure to build the log_proc procedure (below)
-- before trying to create this trigger

CREATE OR REPLACE TRIGGER save_our_db
BEFORE DROP OR TRUNCATE
ON SCHEMA

DECLARE
 oper ddl_log.operation%TYPE; 
BEGIN
  SELECT ora_sysevent
  INTO oper
  FROM DUAL;

  log_proc(ora_sysevent, ora_dict_obj_owner, ora_dict_obj_name);

  IF oper = 'DROP' THEN
    RAISE_APPLICATION_ERROR(-20998, 'Attempt To Drop
    In Production Has Been Logged');
  ELSIF oper = 'TRUNCATE' THEN
    RAISE_APPLICATION_ERROR(-20999, 'Attempt To Truncate A 
    Production Table Has Been Logged');
  END IF;
END save_our_db;
/

SELECT * FROM ddl_log;

DROP TRIGGER ddl_trigger;

SELECT * FROM ddl_log;

ALTER TRIGGER save_our_db DISABLE;

DROP TRIGGER ddl_trigger;

SELECT * FROM ddl_log;

TRUNCATE TABLE ddl_log;

SELECT * FROM ddl_log;

ALTER TRIGGER save_our_db ENABLE;

DROP VIEW v_test;

SELECT * FROM ddl_log;

SELECT object_name FROM user_objects;

DROP SEQUENCE v1_test;

SELECT * FROM ddl_log;

SELECT object_name FROM user_objects;

DROP TRIGGER save_our_db;

TRUNCATE TABLE ddl_log;

--Logging Procedure	
CREATE OR REPLACE PROCEDURE log_proc (
ose  ddl_log.operation%TYPE,
odoo ddl_log.obj_owner%TYPE,
odon ddl_log.object_name%TYPE)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  INSERT INTO ddl_log
  SELECT ora_sysevent, ora_dict_obj_owner, 
  ora_dict_obj_name, 'Not Allowed', USER, SYSDATE
  FROM DUAL;
  COMMIT;
END log_proc;
/
 

--DDL Trigger To Prevent Creating Objects That Whose Names Begin With The Letter 'X'	
CREATE OR REPLACE TRIGGER no_xtabs
BEFORE CREATE
ON SCHEMA

DECLARE
 x user_tables.table_name%TYPE; 
BEGIN
  SELECT ora_dict_obj_name
  INTO x
  FROM DUAL;

  IF SUBSTR(x, 1, 1) = 'X' THEN
    RAISE_APPLICATION_ERROR(-20099, 'Table Names Can Not
    Start With The Letter X');
  END IF;
END no_xtabs;
/

CREATE TABLE ztest (
testcol VARCHAR2(20));

CREATE TABLE xtest (
testcol VARCHAR2(20));
 

--Demo of an application that identifies and logs all DDL	conn / as sysdba

CREATE TABLESPACE logging
DATAFILE 'c:	emp\logtsp01.dbf' SIZE 100M
EXTENT MANAGEMENT LOCAL
UNIFORM SIZE 64K;

CREATE USER loguser
IDENTIFIED BY loguser
DEFAULT TABLESPACE logging
TEMPORARY TABLESPACE temp
QUOTA 0 ON SYSTEM
QUOTA UNLIMITED ON logging;

-- Note that no system privileges have been granted
-- the table is being built by SYS

CREATE TABLE loguser.ddl_log (
user_name     VARCHAR2(30),
ddl_date      DATE,
ddl_type      VARCHAR2(30),
object_type   VARCHAR2(18),
owner         VARCHAR2(30),
object_name   VARCHAR2(128))
TABLESPACE logging;

CREATE OR REPLACE TRIGGER ddl_trig
AFTER DDL
ON DATABASE

BEGIN
  INSERT INTO loguser.ddl_log
  (user_name, ddl_date, ddl_type,
   object_type, owner, 
   object_name)
  VALUES
  (ora_login_user, SYSDATE, ora_sysevent,
   ora_dict_obj_type, ora_dict_obj_owner,
   ora_dict_obj_name);
END ddl_trig;
/

conn uwclass/uwclass

CREATE TABLE t3_test (
testcol DATE);

conn / as sysdba

SELECT * FROM loguser.ddl_log;
 

--Disable granting privileges to PUBLIC	
GRANT ALL ON servers TO SCOTT; 
GRANT ALL ON servers TO PUBLIC;
REVOKE ALL ON servers FROM SCOTT;
REVOKE ALL ON servers FROM PUBLIC;

CREATE OR REPLACE TRIGGER ddl_trig
BEFORE GRANT
ON DATABASE
DECLARE
 g_list dbms_standard.ora_name_list_t;
 n      PLS_INTEGER;
BEGIN
  n := ora_grantee(g_list);
  FOR i IN 1..n LOOP
    IF g_list(i) = 'PUBLIC' THEN
      RAISE_APPLICATION_ERROR(-20997,'Public Grants Not Allowed');
    END IF;
  END LOOP;
END; 
/

set serveroutput on

GRANT ALL ON servers TO SCOTT; 
GRANT ALL ON servers TO PUBLIC;
REVOKE ALL ON servers FROM SCOTT;
REVOKE ALL ON servers FROM PUBLIC;

------------------------------------------
--http://www.dba-oracle.com/art_builder_sec_audit.htm
--https://www.morganslibrary.org/reference/sys_context.html

--TRUNCATE TABLE stats$user_log;
--DROP TABLE stats$user_log PURGE;
create table stats$user_log
(
   user_id              varchar2(30),
   session_id              number(8),
   host                 varchar2(40),
   authnt_type          varchar2(30),
   curr_schema          varchar2(30),
   curr_user            varchar2(30),
   db_name              varchar2(15),
   ip_address           varchar2(30),
   os_user              varchar2(50),
   client_program_name  varchar2(50),
   network_protocol     varchar2(10),
   last_program         varchar2(48),
   last_action          varchar2(32),
   last_module          varchar2(32),
   logon_day                    date,
   logon_time           varchar2(10),
   logoff_day                   date,
   logoff_time          varchar2(10),
   elapsed_minutes         number(8)
);

--DROP TRIGGER logon_audit_trigger;
--ALTER TRIGGER logon_audit_trigger DISABLE;
create or replace trigger
   logon_audit_trigger
AFTER LOGON ON DATABASE
BEGIN
insert into stats$user_log values(
   user,
   sys_context ( 'USERENV', 'SESSIONID' ),
   sys_context ( 'USERENV', 'HOST' ),
   sys_context ( 'USERENV', 'AUTHENTICATION_TYPE' ),
   sys_context ( 'USERENV', 'CURRENT_SCHEMA' ),
   sys_context ( 'USERENV', 'CURRENT_USER' ),
   sys_context ( 'USERENV', 'DB_NAME' ),
   sys_context ( 'USERENV', 'IP_ADDRESS' ),
   sys_context ( 'USERENV', 'OS_USER' ),
   sys_context ( 'USERENV', 'CLIENT_PROGRAM_NAME' ),
   sys_context ( 'USERENV', 'NETWORK_PROTOCOL' ),
   null,
   null,
   null,
   sysdate,
   to_char(sysdate, 'hh24:mi:ss'),
   null,
   null,
   null
);
END;
/

--Here is a script to track the activity of a specific user:
create or replace trigger logon_audit_trigger
AFTER LOGON ON DATABASE
DECLARE
sess number(10);
prog varchar2(70);
BEGIN
IF sys_context('USERENV','BG_JOB_ID') is null and user = 'SMARTEAM' THEN
   sess := sys_context('USERENV','SESSIONID');
   SELECT program INTO prog FROM v$session WHERE audsid = sess
   and rownum<=1;
   insert into stats$user_log values(
   user,
   sys_context ( 'USERENV', 'SESSIONID' ),
   sys_context ( 'USERENV', 'HOST' ),
   sys_context ( 'USERENV', 'AUTHENTICATION_TYPE' ),
   sys_context ( 'USERENV', 'CURRENT_SCHEMA' ),
   sys_context ( 'USERENV', 'CURRENT_USER' ),
   sys_context ( 'USERENV', 'DB_NAME' ),
   sys_context ( 'USERENV', 'IP_ADDRESS' ),
   sys_context ( 'USERENV', 'OS_USER' ),
   sys_context ( 'USERENV', 'CLIENT_PROGRAM_NAME' ),
   sys_context ( 'USERENV', 'NETWORK_PROTOCOL' ),
   prog,
   sysdate, 
   sys_context('USERENV','OS_USER'),
   sysdate,
   to_char(sysdate, 'hh24:mi:ss'),
   null,
   null,
   null
);  
END IF;
END;
/




--DROP TRIGGER logoff_audit_trigger;
--ALTER TRIGGER logoff_audit_trigger DISABLE;
create or replace trigger logoff_audit_trigger
BEFORE LOGOFF ON DATABASE
BEGIN
update
    stats$user_log
set
    last_action = SYS_CONTEXT('USERENV','action'),
    last_module = SYS_CONTEXT('USERENV','module'),
    logoff_day = sysdate,
    logoff_time = to_char(sysdate, 'hh24:mi:ss'),
    elapsed_minutes = round((logoff_day - logon_day)*1440, 2),
    last_program =
    (
        select program
        from v$session
        where
                sys_context('USERENV','SESSIONID') = audsid
            and status = 'ACTIVE'
            and type <> 'BACKGROUND'
    )
where
    sys_context('USERENV','SESSIONID') = session_id;
END;
/


---------------

SET PAGESIZE  50000
SET LINESIZE  500
SET FEEDBACK OFF
COLUMN user_id FORMAT A10
COLUMN session_id FORMAT 999999999999
COLUMN host FORMAT A20
COLUMN authnt_type FORMAT A10
--COLUMN curr_schema FORMAT A15
--COLUMN curr_user FORMAT A15
COLUMN db_name FORMAT A10
COLUMN ip_address FORMAT A15
COLUMN os_user FORMAT A30
COLUMN client_program_name FORMAT A15
COLUMN network_protocol FORMAT A16
COLUMN last_program FORMAT A30
COLUMN last_action FORMAT A10
COLUMN last_module FORMAT A10
COLUMN logon_day FORMAT A10
COLUMN logon_time FORMAT A10
COLUMN logoff_day FORMAT A10
COLUMN logoff_time FORMAT A10
COLUMN elapsed_minutes FORMAT 999999999

select
network_protocol
,user_id
,session_id
,host
,authnt_type
--,curr_schema
--,curr_user
,db_name
,ip_address
,os_user
,client_program_name
--,network_protocol
,last_program
,last_action
,last_module
,logon_day
,logon_time
,logoff_day
,logoff_time
,elapsed_minutes
from stats$user_log
where 
1=1
--and user_id = 'SMARTEAM'
and network_protocol = 'tcp'
;
