SELECT 
  SYS_CONTEXT ( 'userenv', 'AUTHENTICATION_TYPE' ) authent
, SYS_CONTEXT ( 'userenv', 'CURRENT_SCHEMA' )      curr_schema
, SYS_CONTEXT ( 'userenv', 'CURRENT_USER' )        curr_user
, SYS_CONTEXT ( 'userenv', 'DB_NAME' )             db_name
, SYS_CONTEXT ( 'userenv', 'DB_DOMAIN' )           db_domain
, SYS_CONTEXT ( 'userenv', 'HOST' )                host
, SYS_CONTEXT ( 'userenv', 'IP_ADDRESS' )          ip_address
, SYS_CONTEXT ( 'userenv', 'OS_USER' )             os_user
FROM dual
;

begin
 dbms_output.put_line(sys_context('USERENV', 'TERMINAL'));
 dbms_output.put_line(sys_context('USERENV', 'SID')); 
end;

/* 
FUNCTION f_get_spid
  RETURN VARCHAR2 AS
  v_spid VARCHAR2(255);

  BEGIN
    SELECT SUBSTR(tracefile,INSTR(tracefile,'/',-1)+1)
      INTO v_spid
      FROM v$process
     WHERE addr=(SELECT paddr FROM v$session WHERE sid=(SELECT sys_context('userenv','SID') FROM DUAL));
     RETURN v_spid;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_get_spid;
  */

  
CREATE OR REPLACE TRIGGER SYS.TRIG_LOGON_BLK_DDL
after LOGON ON DATABASE
DECLARE
--- declaration of local variables
select module into cmodule from v$session where audsid=(select sys_context('USERENV','SESSIONID') from dual) and rownum<=1; 
---- the above line will show if it is TOAD/SQL Developer or any other tool.
select sys_context('USERENV','SESSION_USER') into usr from dual;
select sys_context('USERENV','HOST') into chost from dual;
select sys_context('USERENV','IP_ADDRESS') into cip from dual;
select SYSDATE into clogin from dual;
  select sys_context('USERENV','OS_USER') into cosuser from dual;
 
---- then your logic to check whom to restrict.
-- and finally message to the user.
 
if blk then
  insert into ddl_block_audit                       -- this table tracks all access to the database.
  values
  (usr, chost,cip, cmodule, cosuser, clogin,'','','','','Blocked from Logon Trigger');
  commit;
    raise_application_error(-20001,usr||' - Blocked - please contact Admin');
end if;
/


-----------
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
create or replace trigger logon_audit_trigger
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
--and user_id = 'TEST'
and network_protocol = 'tcp'
;


--------------------------------


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
--and user_id = 'TEST'
and network_protocol = 'tcp'
;



--------
I would do it with SQL*Net. Configure your listener with tcp.validnode_checking to reject all connections that do not come from your Forms server.

--------