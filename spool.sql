set linesize 1000
set trimspool on
set echo off
set feedback off
set timing off
set termout off
set pagesize 0
set heading off
spool c:\Users\sbovkush\Desktop\1.txt
select * from HIS t;
spool off
quit