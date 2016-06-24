SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool D:\Install\WORK\DB_ORACLE\cloneDBCreation.log append
shutdown abort;
startup nomount pfile="D:\Install\WORK\DB_ORACLE\init.ora";
Create controlfile reuse set database "ORA12C"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'&&file0',
'&&file1',
'&&file2',
'&&file3'
LOGFILE GROUP 1 ('C:\app\oradata\ORA12C\redo01.log') SIZE 50M,
GROUP 2 ('C:\app\oradata\ORA12C\redo02.log') SIZE 50M,
GROUP 3 ('C:\app\oradata\ORA12C\redo03.log') SIZE 50M RESETLOGS;
exec dbms_backup_restore.zerodbid(0);
shutdown immediate;
startup nomount pfile="D:\Install\WORK\DB_ORACLE\initORA12CTemp.ora";
Create controlfile reuse set database "ORA12C"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
Datafile 
'&&file0',
'&&file1',
'&&file2',
'&&file3'
LOGFILE GROUP 1 ('C:\app\oradata\ORA12C\redo01.log') SIZE 50M,
GROUP 2 ('C:\app\oradata\ORA12C\redo02.log') SIZE 50M,
GROUP 3 ('C:\app\oradata\ORA12C\redo03.log') SIZE 50M RESETLOGS;
alter system enable restricted session;
alter database "ORA12C" open resetlogs;
exec dbms_service.delete_service('seeddata');
exec dbms_service.delete_service('seeddataXDB');
DROP PUBLIC DATABASE LINK DBMS_CLRDBLINK;
alter database rename global_name to "ORA12C";
ALTER TABLESPACE TEMP ADD TEMPFILE 'C:\app\oradata\ORA12C\TEMP01.DBF' SIZE 61440K REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED;
select tablespace_name from dba_tablespaces where tablespace_name='USERS';
alter user sys account unlock identified by "&&sysPassword";
connect "SYS"/"&&sysPassword" as SYSDBA
alter user system account unlock identified by "&&systemPassword";
alter system disable restricted session;
connect "SYS"/"&&sysPassword" as SYSDBA
@C:\app\product\12.1.0\dbhome_1\demo\schema\mkplug.sql &&sysPassword change_on_install change_on_install change_on_install change_on_install change_on_install change_on_install example.dmp example01.dfb C:\app\oradata\ORA12C\example01.dbf D:\Install\WORK\DB_ORACLE\ C:\app\product\12.1.0\dbhome_1\assistants\dbca\templates\ C:\app\product\12.1.0\dbhome_1\demo\schema\order_entry\;
execute dbms_backup_restore.resetCfileSection(dbms_backup_restore.RTYP_DFILE_COPY);
connect "SYS"/"&&sysPassword" as SYSDBA
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup restrict pfile="D:\Install\WORK\DB_ORACLE\initORA12CTemp.ora";
select sid, program, serial#, username from v$session;
alter database character set INTERNAL_CONVERT AL32UTF8;
alter database national character set INTERNAL_CONVERT UTF8;
alter system disable restricted session;
