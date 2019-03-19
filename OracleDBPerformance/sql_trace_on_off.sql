alter pluggable database all open;
alter session set container=ORCLPDB1;

sho con_name

alter session set container=PDB$SEED;
alter session set container=CDB$ROOT;
------------------------------------------

Where is my Trace?

V$DIAG_INFO (11.1+)
USER_DUMP_DEST (deprecated 12c)

--turns sql trace on using event 10046 level 12(include binds and waits)
ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL 12';


--turns sql trace off
ALTER SESSION SET STATISTICS_LEVEL = 'TYPICAL';
ALTER SESSION SET SQL_TRACE = FALSE;

--find trace and procedure tkprof sorted by elapsed time descending
COL trace NEW_V trace;
SELECT value trace FROM v$diag_info WHERE name = 'Default Trace File';
HOS tkprof &&trace. &&_user._tkprof.txt sort=prsela exeela fchela
HOS more &&_user.tkprof.txt


--- diag_info
-- quick check of the new v$diag_info view that came in with 11
col inst_id form 9999 head inst
col name form a25
col value form a60 wrap
spool diag_info.lst
set lines 120
select * from v$diag_info
order by name
/
spool off
--

-------------------
--Run cmd as ADMIN
--set needed var
set ORACLE_HOME=C:\app\product\12.2.0\dbhome_1
SET ORACLE_SID=ORCLPDB1

--check it
echo %ORACLE_HOME%
echo %ORACLE_SID%


--connect to DB
sqlplus /nolog
conn system/xxxxxxxx@ORCL as sysdba
--or
sqlplus / as sysdba

--open database and set needed container
alter pluggable database all open;
alter session set container=orclpdb1;
--cheack it
sho con_name

disconn

conn hr/hr@ORCLPDB1

--turns sql trace on using event 10046 level 12(include binds and waits)
    ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
    ALTER SESSION SET TRACEFILE_IDENTIFIER = 'SERG_TRACE';
    ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL 12';


--do needed action from db user(sql query, etc.)

select count(*) from emp_copy;

select count(*) from jobs;

select count(*) from regions;


--turns sql trace off
ALTER SESSION SET STATISTICS_LEVEL = 'TYPICAL';
ALTER SESSION SET SQL_TRACE = FALSE;


--cheack trc file destination 
--To find the trace file for your current session:
    --Submit the following query:
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';

--find trace and procedure tkprof sorted by elapsed time descending
COL trace NEW_V trace;
COL trace_dir NEW_V trace_dir;
SELECT value trace FROM v$diag_info WHERE name = 'Default Trace File';
SELECT VALUE trace_dir FROM V$DIAG_INFO WHERE NAME = 'Diag Trace';
HOS tkprof &&trace. &&trace_dir.\&&_user._tkprof.txt sort=prsela exeela fchela
HOS more &&trace_dir.\&&_user._tkprof.txt


--if error Cannot access file and could not open trace file, then do it manualy

--go to trc file destination 
--To find the trace file for your current session:
    --Submit the following query:
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';

--To find all trace files for the current instance:
    --Submit the following query:
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Diag Trace';
    --The path to the ADR trace directory for the current instance is returned.  
    
--and run tkprof

cd C:\APP\diag\rdbms\orcl\orcl\trace
tkprof C:\APP\diag\rdbms\orcl\orcl\trace\orcl_ora_8180_SERG_TRACE.trc C:\APP\diag\rdbms\orcl\orcl\trace\hr_tkprof.txt sort=prsela exeela fchela

--to change destination
ALTER SYSTEM SET user_dump_dest = "C:\app\product\12.2.0\dbhome_1\bin";

---####################################################--
--another way to trace session which is not yours
--select necessary information about session
SELECT sid, serial#, username
FROM V$SESSION;

--and put the values into stmt
EXECUTE DBMS_MONITOR.SESSION_TRACE_ENABLE(391,32824, TRUE, FALSE);

--wait for a while and disable trace
EXECUTE DBMS_MONITOR.SESSION_TRACE_DISABLE(391,32824);


-- run tkprof
cd C:\APP\diag\rdbms\orcl\orcl\trace
tkprof C:\APP\diag\rdbms\orcl\orcl\trace\orcl_ora_8180.trc hr_tkprof.txt sort=prsela exeela fchela

--see the result

---####################################################--
--if you do not have access to server just retrive info from V$DIAG_TRACE_FILE_CONTENTS

--BUT This view is available starting with Oracle Database 12c Release 2 (12.2.0.1).

select fc.adr_home, fc.trace_filename, payload 
from V$DIAG_TRACE_FILE_CONTENTS fc
where fc.trace_filename = 'orcl_ora_8180_SERG_TRACE.trc';


set heading off
set feedback off
set trimspool on
set linesize 255
set embedded on
SET TERMOUT OFF
spool C:\Temp\my_trace.trc

select payload 
from V$DIAG_TRACE_FILE_CONTENTS fc
where fc.trace_filename = 'orcl_ora_8180_SERG_TRACE.trc';

spool off
cd C:\Temp
tkprof C:\Temp\my_trace.trc C:\Temp\tkprof_my_trace.txt sort=prsela exeela fchela



-------------
--trace with CTX_OUTPUT Package
http://www.dba86.com/docs/oracle/12.2/CCREF/CTX_OUTPUT-package.htm


---------------one more ------------
--https://static.rainfocus.com/oracle/oow18/sess/1523654077988001mEdJ/PF/TIP4094%20-%20fast%20lane_1540795887172001PZh2.pdf
explain plan for
select count(*)
from VEHICLE
where MAKE = 'HONDA' and MODEL = 'CIVIC';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_PLAN);

--
--actual versus estimate
select /*+ GATHER_PLAN_STATISTICS */ count(*)
from VEHICLE
where MAKE = 'HONDA' and MODEL = 'CIVIC';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

--
set linesize 250 pagesize 0 trims on tab off long 1000000
set timing on
select plan_table_output
from v$sql s,
table(dbms_xplan.display_cursor(s.sql_id,
                               s.child_number, 'ADVANCED +peeked_binds +projection')) t
where upper(s.sql_text) like 'SELECT /*+ GATHER_PLAN_STATISTICS */%';
----------------------------------------------------


--tracing

alter session set sql_trace = true
alter session set tracefile_identifier = SERG_TRACE;
Session altered.
SQL> host ls *.trc


alter session set events 'immediate trace name trace_buffer_on level 1048576';
Session altered.
SQL> host ls –l *.trc
drw------- oracle dba Jun17 15:10 1048576 db10r2_ora_3248.trc

--

SQL> select name, value from v$diag_info;
NAME VALUE
------------------------ ------------------------------------------
Diag Enabled TRUE
ADR Base C:\ORACLE
ADR Home C:\ORACLE\diag\rdbms\db122\db122
Diag Trace C:\ORACLE\diag\rdbms\db122\db122\trace
Diag Alert C:\ORACLE\diag\rdbms\db122\db122\alert
Diag Incident C:\ORACLE\diag\rdbms\db122\db122\incident
Diag Cdump c:\oracle\diag\rdbms\db122\db122\cdump
Health Monitor C:\ORACLE\diag\rdbms\db122\db122\hm
Default Trace File C:\ORACLE\...\trace\db122_ora_17296.trc

--


select PAYLOAD
from V$DIAG_TRACE_FILE_CONTENTS
where TRACE_FILENAME = 'db122_ora_12484.trc';

PAYLOAD
----------------------------------------------------------------------------
Trace file C:\ORACLE\diag\rdbms\db122\db122\trace\db122_ora_12484.trc
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
Build label: RDBMS_12.2.0.1.0WINDBBP_WINDOWS.X64_180202
Windows NT Version V6.2
ORACLE_HOME = c:\oracle\product\12.2.0.1
Node name : XPS13
CPU : 4 - type 8664, 2 Physical Cores
Process Affinity : 0x0x0000000000000000
Memory (Avail/Total): Ph:9411M/16235M, Ph+Pg


