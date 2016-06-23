--Partitioning a table online with DBMS_REDEFINITION

--If there is a requirement to change the structure of a table that is already in use productively, it may be impossible to get a maintenance downtime for that table, because it is constantly in use. That can be the case for all kind of structural changes of a table, particularly for the change from an ordinary heap table into a partitioned table, which I am going to take here as an example, because I am getting asked frequently in my courses how to achieve it. In order to demonstrate that, I will create a demonstration user with a non-partitioned table with privileges and additional dependent objects on it:

SQL> grant dba to adam identified by adam;

Grant succeeded.

SQL> connect adam/adam
Connected.

SQL> create table original as select
rownum as id,
mod(rownum,5) as channel_id,
5000 as amount_sold,
mod (rownum,1000) as cust_id,
sysdate as time_id
from dual connect by level<=1e6;  

Table created.

SQL> create index original_id_idx on original(id) nologging;

Index created.
SQL> grant select on original to hr;

Grant succeeded.
--The challenge is now to change this table into a partitioned one while it is used with DML & queries by end users. For this purpose, we introduced already in 9i (if I recall it right) the package DBMS_REDEFINITION. First step would be to ask, whether it can be used in this case:

SQL> select * from v$version;

BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - Production
PL/SQL Release 11.2.0.1.0 - Production
CORE    11.2.0.1.0      Production
TNS for Linux: Version 11.2.0.1.0 - Production
NLSRTL Version 11.2.0.1.0 - Production
SQL> begin
dbms_redefinition.can_redef_table
 (uname=>'ADAM',
 tname=>'ORIGINAL',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/
PL/SQL procedure successfully completed.
--Because there is no Primary Key on the original table, I have to use CONS_USE_ROWID, else I could use CONS_USE_PK. There are no objections against the online redefinition of the table here – else an error message would appear. Next step is to create an interim table of the structure, desired for the original table. In my case, I create it interval partitioned (an 11g New Feature). I could also change storage attributes and add or remove columns during that process.

SQL> create table interim
(id number,
channel_id number(1),
amount_sold number(4),
cust_id number(4),
time_id date)
partition by range (cust_id)
interval (10)
(partition p1 values less than (10));

Table created.
--My original table has 1000 distinct cust_ids, so this will lead to 100 partitions – each partion will contain 10 distinct cust_ids. One benefit of that would be the possibility of partition pruning, should there be statements, specifying the cust_id in the where-condition. These statements will be about 100 times faster as a full table scan. The next step will basically insert all the rows from the original table into the interim table (thereby automatically generating 99 partitions), while DML during that period is recorded:

SQL> set timing on
SQL>
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE
 (uname=>'ADAM',
 orig_table=>'ORIGINAL',
 int_table=>'INTERIM',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/

PL/SQL procedure successfully completed.
Elapsed: 00:00:22.76
--If this step takes a long time to run it might be beneficial to use the SYNC_INTERIM_TABLE procedure occasionally from another session. That prevents a longer locking time for the last step, the calling of FINISH_REDEF_TABLE. Next step is now to add the dependent objects/privileges to the interim table:

SQL> set timing off
SQL> vari num_errors number
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS
 (uname=>'ADAM',
 orig_table=>'ORIGINAL',
 int_table=>'INTERIM',
 num_errors=>:num_errors);
END;
/
PL/SQL procedure successfully completed.
SQL> print num_errors
NUM_ERRORS
----------
 0
--There was no problem with this step. Until now the original table is still an ordinary heap table – only the interim table is partitioned:

SQL> select table_name from user_part_tables;

TABLE_NAME
------------------------------
INTERIM
--In the last step, the two tables change their names and the recorded DML that occured in the meantime gets used for actualization:

SQL> begin
dbms_redefinition.finish_redef_table
 (uname=>'ADAM',
 orig_table=>'ORIGINAL',
 int_table=>'INTERIM');
end;
/  

PL/SQL procedure successfully completed.
--We will now determine that the original table is partitioned and the dependencies are still there:

SQL> select table_name,partitioning_type from user_part_tables;
TABLE_NAME                     PARTITION
------------------------------ ---------
ORIGINAL                       RANGE
SQL> select count(*) from user_tab_partitions;
 COUNT(*)
----------
 100
SQL> select grantee,privilege from  user_tab_privs_made where table_name='ORIGINAL';
GRANTEE                        PRIVILEGE
------------------------------ ----------------------------------------
HR                             SELECT
SQL> select index_name,table_name from user_indexes;
INDEX_NAME                     TABLE_NAME
------------------------------ ------------------------------
ORIGINAL_ID_IDX                ORIGINAL
TMP$$_ORIGINAL_ID_IDX0         INTERIM
--The interim table can now be dropped. We changed the table into a partitioned table without any end user noticing it!
