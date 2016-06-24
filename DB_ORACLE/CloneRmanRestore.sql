SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool D:\Install\WORK\DB_ORACLE\CloneRmanRestore.log append
startup mount pfile="D:\Install\WORK\DB_ORACLE\initORA12CTempOMF.ora";
execute dbms_backup_restore.resetCfileSection(dbms_backup_restore.RTYP_DFILE_COPY);
execute dbms_backup_restore.resetCfileSection(13);
host C:\app\product\12.1.0\dbhome_1\bin\rman @D:\Install\WORK\DB_ORACLE\rmanRestoreDatafiles.sql &&sysPassword;
column file0 NEW_VALUE file0;
select NAME file0 FROM V$DATAFILE_COPY where file# = 3;
column file1 NEW_VALUE file1;
select NAME file1 FROM V$DATAFILE_COPY where file# = 1;
column file2 NEW_VALUE file2;
select NAME file2 FROM V$DATAFILE_COPY where file# = 5;
column file3 NEW_VALUE file3;
select NAME file3 FROM V$DATAFILE_COPY where file# = 6;
spool off
