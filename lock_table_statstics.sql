How to lock table statstics in Oracle
Use dbms_stats.lock_table_stats

conn scott
exec dbms_stats.lock_table_stats('SCOTT','DEPT');

Verify the setting:

select table_name,object_type,stattype_locked 
from user_tab_statistics;

TABLE_NAME                     OBJECT_TYPE                          STATTYPE_LOCKED
------------------------------ ------------------------------------ ---------------
DEPT                           TABLE                                ALL
EMP                            TABLE
BONUS                          TABLE
SALGRADE                       TABLE
RECEIVED_DOCUMENTS             TABLE

Lock stats on a specific partition:
exec dbms_stats.lock_partition_stats('SCOTT','RECEIVED_DOCUMENTS','SETTELM');
Verify the setting:
select table_name,partition_name,subpartition_name,object_type,stattype_locked 
from user_tab_statistics 
where table_name='RECEIVED_DOCUMENTS';

TABLE_NAME                     PARTITION_NAME  SUBPARTITION_NAME OBJECT_TYPE          STATTYPE_LOCKED
------------------------------ --------------- ----------------- -------------------- ---------------
RECEIVED_DOCUMENTS                                               TABLE
RECEIVED_DOCUMENTS             APPLICANT                         PARTITION
RECEIVED_DOCUMENTS             APPLICATIONS                      PARTITION
RECEIVED_DOCUMENTS             SETTELM                           PARTITION            ALL

To reverse the process:
exec dbms_stats.unlock_table_stats('SCOTT','DEPT);
exec dbms_stats.unlock_partition_stats('SCOTT','RECEIVED_DOCUMENTS','SETTELM');