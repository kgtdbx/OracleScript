
alter pluggable database all open;
alter session set container=orclpdb1;
sho con_name


Pluggable Database not open automatically
From 12.1.0.2 you can save the state of a PDB once it’s open: next time the database starts, it will automatically start the pdbs opened previously

— 1 pdb save
alter pluggable database pdb_name save state;

— All pdbs
alter pluggable database all save state;

— All except
alter pluggable database all except pdb1, pdb2 save state;


CREATE USER SMARTEAM
    IDENTIFIED BY "stepx2020"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE TEMP
    PROFILE DWH_USER;
	--ACCOUNT UNLOCK ;


---------------------------------------------------------------------
sho parameter _allow_insert_with_update_check

alter system set "_allow_insert_with_update_check" = true scope=both;


--some errors with EM instalation
--C:\APP\ORADATA\ORCL\TEMP01.DBF
select FILE_NAME,TABLESPACE_NAME from dba_temp_files;

CREATE TEMPORARY TABLESPACE TEMP_NEW TEMPFILE 'C:\APP\ORADATA\ORCL\TEMP_01.DBF' SIZE 100m autoextend on next 10m maxsize unlimited;

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_NEW;


SELECT b.tablespace,b.segfile#,b.segblk#,b.blocks,a.sid,a.serial#,
a.username,a.osuser, a.status
FROM v$session a,v$sort_usage b
WHERE a.saddr = b.session_addr;

--alter system kill session 'SID_NUMBER, SERIAL#NUMBER';
alter system kill session '59,57391';

DROP TABLESPACE temp INCLUDING CONTENTS AND DATAFILES;

-----------------------------------------------------------


exec dbms_stats.gather_system_stats('INTERVAL', 15);

SELECT * FROM sys.aux_stats$;
select pname, pval1 from sys.aux_stats$;


BEGIN
   DBMS_STATS.GATHER_SYSTEM_STATS (
      interval => 720,
      stattab  => 'mystats',
      statid   => 'OLTP');
END;

BEGIN
   DBMS_STATS.GATHER_SYSTEM_STATS (
      interval => 720,
      stattab  => 'mystats',
      statid   => 'OLAP');
END;


VARIABLE   jobno   number;
BEGIN
   DBMS_JOB.SUBMIT (:jobno, 'DBMS_STATS.IMPORT_SYSTEM_STATS(''mystats'',''OLTP'');', sysdate, 'sysdate + 1');
   COMMIT;
END;

BEGIN
   DBMS_JOB.SUBMIT (:jobno, 'DBMS_STATS.IMPORT_SYSTEM_STATS(''mystats'',''OLAP'');', sysdate + 0.5, 'sysdate + 1');
   COMMIT;
END;


---------------------
/* e.g. activate the DAY statistics each day at 7:00 am */

DECLARE
    I NUMBER;
BEGIN
   DBMS_JOB.SUBMIT (I, 
                    'DBMS_STATS.IMPORT_SYSTEM_STATS(stattab => ''mystats'', statown => ''SYSTEM'', statid => ''DAY'');', 
                    trunc(sysdate) + 1 + 7/24, 'sysdate + 1');
      COMMIT;                 
END;
/


 

/* e.g. activate the NIGHT statistics each day at 9:00 pm */

DECLARE
    I NUMBER;

BEGIN
   DBMS_JOB.SUBMIT (I, 'DBMS_STATS.IMPORT_SYSTEM_STATS(stattab => ''mystats'', statown => ''SYSTEM'', statid => ''NIGHT'');', 
                    trunc(sysdate) + 1 + 21/24, 
                    'sysdate + 1');
      COMMIT;
END;
/


 

*** ********************************************************

*** Initialize the OLTP System Statistics for the CBO

*** ********************************************************

 

1. Delete any existing system statistics from dictionary:

   

   SQL> execute DBMS_STATS.DELETE_SYSTEM_STATS;

   PL/SQL procedure successfully completed.

 

2. Transfer the OLTP statistics from OLTP_STATS table to the dictionary tables:

 

   SQL> execute DBMS_STATS.IMPORT_SYSTEM_STATS(stattab => 'OLTP_stats', statid => 'OLTP', statown => 'SYS');

 

   PL/SQL procedure successfully completed.

 

3. All system statistics are now visible in the data dictionary table:

 

   SQL> select * from sys.aux_stats$;

 

   SQL> select * from aux_stats$;

 

   SNAME                PNAME                   PVAL1 PVAL2

   -------------------- ------------------ ---------- --------------

   SYSSTATS_INFO        STATUS                        COMPLETED

   SYSSTATS_INFO        DSTART                        08-09-2001 16:40

   SYSSTATS_INFO        DSTOP                         08-09-2001 16:42

   SYSSTATS_INFO        FLAGS                       0

   SYSSTATS_MAIN        SREADTIM                7.581

   SYSSTATS_MAIN        MREADTIM               56.842

   SYSSTATS_MAIN        CPUSPEED                  117

   SYSSTATS_MAIN        MBRC                        9

 

   where 

   => sreadtim : wait time to read single block, in milliseconds

   => mreadtim : wait time to read a multiblock, in milliseconds

   => cpuspeed : cycles per second, in millions 

 

*** ********************************************************

*** CPU_COST and IO_COST in PLAN_TABLE table

*** ********************************************************

 

   SQL> explain plan for select * from oltp.test where c='AAAHxGAABAAAJS1AEZ';

   Explained.

 

   SQL> select operation, options, object_name, cpu_cost, io_cost

     2  from plan_table;

 

   OPERATION          OPTIONS              OBJECT_NAME    CPU_COST    IO_COST

   ------------------ -------------------- ------------ ---------- -

   SELECT STATEMENT                                          10500          1

   INDEX              UNIQUE SCAN          SYS_C002218       10500          1

 

   SQL> truncate table plan_table;

 

   SQL> explain plan for select * from oltp.test;

   Explained.

 

   SQL> select operation, options, object_name, cpu_cost, io_cost

     2  from plan_table;

 

   OPERATION          OPTIONS              OBJECT_NAME    CPU_COST    IO_COST

   ------------------ -------------------- ------------ ---------- ----------

   SELECT STATEMENT                                        2677480         27

   INDEX              FAST FULL SCAN       SYS_C002218     2677480         27

