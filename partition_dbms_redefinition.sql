This process allows the following operations to be performed with no impact on DML operations:

Converting a non-partitioned table to a partitioned table and vice versa.
Switching a heap organized table to an index organized table and vice versa.
Dropping non-primary key columns.
Adding new columns.
Adding or removing parallel support.
Modifying storage parameters.
Online table redefinition has a number of restrictions including:

There must be enough space to hold two copies of the table.
Primary key columns cannot be modified.
Tables must have primary keys.
Redefinition must be done within the same schema.
New columns added cannot be made NOT NULL until after the redefinition operation.
Tables cannot contain LONGs, BFILEs or User Defined Types.
Clustered tables cannot be redefined.
Tables in the SYS or SYSTEM schema cannot be redefined.
Tables with materialized view logs or materialized views defined on them cannot be redefined.
Horizontal subsetting of data cannot be performed during the redefinition.	

--###################   MY    Exemple       #######################
-- Create new table

 CREATE TABLE customerw_prt (rnk   NUMBER(38),
                                               tag   CHAR(5),
                                               value VARCHAR2(500),
                                               isp   NUMBER(38),
                                               constraint pk_customerw_prt PRIMARY KEY (tag, rnk))
   PARTITION BY HASH (tag)
   PARTITIONS 8 
   STORE IN (BRSBIGD, BRSBIGI);
 --or
 CREATE TABLE customerw_iot(rnk   NUMBER(38),
                                              tag   CHAR(5),
                                              value VARCHAR2(500),
                                              isp   NUMBER(38),
                                              constraint pk_customerw_iot PRIMARY KEY (tag, rnk)) 
     ORGANIZATION INDEX COMPRESS 1
             INCLUDING rnk
     OVERFLOW
          PARTITION BY HASH (tag)
             PARTITIONS 8
             STORE IN (BRSDYNI, BRSBIGI)
             OVERFLOW STORE IN (BRSBIGI);
 
 --DROP MATERIALIZED VIEW LOG ON customerw; 
 
 --##########################################
 -- Check table can be redefined
 begin
dbms_redefinition.can_redef_table
 (uname=>'BARS',
 tname=>'CUSTOMERW',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/

 --##########################################
-- Alter parallelism to desired level for large tables.
--ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
--ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

-- Start Redefinition
BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE
 (uname=>'BARS',
 orig_table=>'CUSTOMERW',
 int_table=>'CUSTOMERW_IOT',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/

 --##########################################
-- Optionally synchronize new table with interim data before index creation
BEGIN
  dbms_redefinition.sync_interim_table(
    uname      => USER,        
 orig_table=>'CUSTOMERW',
 int_table=>'CUSTOMERW_IOT');
END;
/

 --##########################################
--SET SERVEROUTPUT ON
DECLARE
  l_errors  NUMBER;
BEGIN
  DBMS_REDEFINITION.copy_table_dependents(
    uname            => USER,
    orig_table       => 'CUSTOMERW',
    int_table        => 'CUSTOMERW_IOT',
    copy_indexes     => DBMS_REDEFINITION.cons_orig_params,
    copy_triggers    => TRUE,
    copy_constraints => TRUE,
    copy_privileges  => TRUE,
    ignore_errors    => FALSE,
    num_errors       => l_errors,
    copy_statistics  => FALSE,
    copy_mvlog       => FALSE);
    
  DBMS_OUTPUT.put_line('Errors=' || l_errors);
END;
/
--если получаем ORA-01442: column to be modified to NOT NULL is already NOT NULL, нужно удалить констрейнты

for i in (select owner,table_name,constraint_name, search_condition
           from dba_constraints
           where owner= user
           and table_name = 'CUSTOMERW'
           and constraint_type = 'C')
loop
   if i.search_condition like '%IS NOT NULL%' then
      execute immediate 'alter table '||i.owner||'.'||i.table_name||' drop constraint '||i.constraint_name;
   end if;
end loop;
--or
select * from dba_constraints where table_name ='CUSTOMERW' and owner='BARS';

alter table CUSTOMERW drop constraint SYS_C00112973;
alter table CUSTOMERW drop constraint SYS_C00112972;
alter table CUSTOMERW drop constraint SYS_C00112974;

--или --ora - 28667  USING INDEX option not allowed for the primary key of an IOT
--поэтому лучше использовать

DECLARE
  num_errors PLS_INTEGER;
BEGIN
  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS ('BARS',  'CUSTOMERW', 'CUSTOMERW_IOT',
    DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/

--проверяем что вылетело в ощибки
select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS;

--или попробовать, но не добавлять его в начале

-- Add new PK.
--ALTER TABLE customerw_prt ADD (CONSTRAINT pk_customerw_t PRIMARY KEY (tag, rnk));

--#################################
-- Complete redefinition
BEGIN
  dbms_redefinition.finish_redef_table(
    uname      => USER,        
    orig_table       => 'CUSTOMERW',
    int_table        => 'CUSTOMERW_IOT');
END;
/

--#########################
--удаляем виртуальный уже не нужный виртуальный столбец, если  использовал CONS_USE_ROWID
alter table CUSTOMERW drop unused columns;

--################################
begin
 DBMS_STATS.gather_table_stats(USER, 'CUSTOMERW', cascade => TRUE); 
 end;
--#########################
-- Remove original table which now has the name of the new table
drop table bars.CUSTOMERW_IOT cascade constraints purge; 

--#################################
-- Rename the primary key constraint.
ALTER TABLE customerw RENAME CONSTRAINT pk_customerw_iot TO pk_customerw;
--#################################
declare
 l_tab        varchar2(4000) :='CUSTOMERW';
 l_stmt      varchar2(4000);
    begin
        --
         for cur in (select rownum as num,
                            owner, constraint_name, constraint_type,
                             table_name, r_owner, r_constraint_name, delete_rule, status,
                             deferrable, deferred, validated, generated, bad, rely,
                             last_change, index_owner, index_name, invalid, view_related
                        from user_constraints c
                       where status = 'ENABLED'
                         and validated <> 'VALIDATED'
                         and table_name= l_tab
                       order by 1
                       )
      loop
             l_stmt := 'alter table '||cur.table_name||' modify constraint '||cur.constraint_name||' validate';
            --
            execute immediate l_stmt;
      end loop;
    end;
--#################################
--по необходимости ребилд зависимых объектов или схемы
--ALTER TRIGGER redef_tab_bir COMPILE;
--ALTER VIEW redef_tab_v COMPILE;
begin
dbms_utility.compile_schema(schema=>user, compile_all=>false);
end;

	
--###########################################
	dbms_redefinition example

Oracle Tips by Burleson Consulting

July 3, 2015


Also see concepts of dbms_redefinition.
 
No database is 100% self-reliant or self-maintaining, which is a good thing for DBA job security. However, the last few major versions of Oracle have greatly increased its self-diagnostic and self-monitoring capabilities. Only database structural reorganization remains one of those tasks best left to the DBA to decide when it is appropriate to perform and when to schedule its execution. That is because data is the life blood of any modern organization, and while doing various database reorganizations, the following possibilities exist:
n  The process could blow-up mid-stream, so data may be left offline
n  The process is resource-intensive and takes significant time to execute
n  Data could be momentarily inconsistent between key steps
n  Probably advisable to consider doing a backup operation just prior to
The key point is that structural reorganizations are generally important events in any database?s life cycle. Even when a reorganization activity can theoretically be performed entirely online with little or no downtime, it is often a safer bet to perform any such activities in a controlled environment. Because the one time something that can not go wrong does, the DBA will be in a better situation to resume or recover if there are not frantic customers breathing down his neck. So schedule any reorganization event with extreme caution and over- compensation.
 
Now with all that said, Oracle provides a robust and reliable package for performing many common online table level reorganizations ? dbms_redefinition. Much like the dbms_metadata  package, dbms_redefinition provides an almost limitless set of use cases or scenarios that it can address. Many people will probably just use the OEM graphical interface, but here is a very common example that should fulfill this key need as well as serve as a foundation for one?s own modifications. The following are the key basic steps:
1.      Verify that the table is a candidate for online redefinition
2.      Create an interim table
3.      Enable parallel DML operations
4.      Start the redefinition process (and do not stop until step 9 is done)
5.      Copy dependent objects
6.      Check for any errors
7.      Synchronize the interim table (optional)
8.      Complete the redefinition
9.      Drop the interim table
A common question is what is happening behind the scenes here? In other words, how and what is Oracle doing? Essentially, the redefinition package is merely an API to an intelligent materialized view with a materialized view log. So a local replication of the object shows while the reorganization occurs. Then it refreshes to get up-to-date for any transaction that occurred during reorganization.
Partition a Table

One of the most common table reorganization tasks is to partition a table that is currently not partitioned but that could benefit in manageability and/or performance by becoming partitioned. It may be that this table is a throwback from an earlier Oracle database version like those that were created long ago before partitioning was available or that it simply has grown over time to the point where partitioning makes sense. Another example might be that it is partitioned, but it is so by an older partitioning method or scheme. So if one wants to rebuild a hash partitioned table using Oracle 11g?s new interval partitioning, there are many other partitioning scenarios, but the basic idea is this: the table is currently not partitioned or partitioned incorrectly, and this needs to be remedied.
 
Return once again to the MOVIES demo schema and partition the CUSTOMER table. And like any real world database, the rest of the database design depends on the customer, such as there are foreign keys to it. Not only that, but CUSTOMER has additional indexes and triggers. Here is the complete DDL for CUSTOMER. So as can be seen, it is much more than just a simple standalone table since there are also indexes and triggers that go with this table.
 
<  .Complete CUSTOMER table DDL
 
  CREATE TABLE "MOVIES"."CUSTOMER"
  ( "CUSTOMERID" NUMBER(10,0) NOT NULL ENABLE,
    "FIRSTNAME" VARCHAR2(20) NOT NULL ENABLE,
    "LASTNAME" VARCHAR2(30) NOT NULL ENABLE,
    "PHONE" CHAR(10) NOT NULL ENABLE,
    "ADDRESS" VARCHAR2(40) NOT NULL ENABLE,
    "CITY" VARCHAR2(30) NOT NULL ENABLE,
    "STATE" CHAR(2) NOT NULL ENABLE,
    "ZIP" CHAR(5) NOT NULL ENABLE,
    "BIRTHDATE" DATE,
    "GENDER" CHAR(1),
     CHECK (Gender in ('M','F')) ENABLE,
     CHECK (CustomerId > 0) ENABLE,
     CONSTRAINT "CUSTOMER_PK" PRIMARY KEY ("CUSTOMERID")
     CONSTRAINT "CUSTOMER_UK" UNIQUE ("FIRSTNAME", "LASTNAME", "PHONE")
  );
 
  CREATE INDEX "MOVIES"."CUSTOMER_IE1" ON "MOVIES"."CUSTOMER" ("LASTNAME");
  CREATE INDEX "MOVIES"."CUSTOMER_IE2" ON "MOVIES"."CUSTOMER" ("PHONE");
  CREATE INDEX "MOVIES"."CUSTOMER_IE3" ON "MOVIES"."CUSTOMER" ("ZIP");
  CREATE OR REPLACE TRIGGER "MOVIES"."CUSTOMER_CHECKS"
  BEFORE INSERT OR UPDATE
  ON customer
  FOR EACH ROW
  declare
  -- Declare User Defined Exception
  bad_length  exception;
  pragma exception_init(bad_length,-20001);
  bad_date    exception;
  pragma exception_init(bad_date,-20002);
begin
  -- Check Values for Correct Length
  if (length(rtrim(:new.phone)) < 10 or
      length(rtrim(:new.state)) <  2 or
      length(rtrim(:new.zip))   <  5) then
    raise bad_length;
  end if;
  -- Check Dates for Reasonableness
  if (:new.birthdate > sysdate-18*365) then
    raise bad_date;
  end if;
  -- Force Values to All Upper Case
  :new.state  := upper(:new.state);
  :new.gender := upper(:new.gender);
exception
  when bad_length then
    raise_application_error(-20001, 'Illegal length: value shorter than required');
  when bad_date then
    raise_application_error(-20002, 'Illegal date: value fails reasonableness test');
end;
/
Step 1: Verify that the table is a candidate for online redefinition

This is a very easy step, but it is also a very critical step. If this step fails, then do not attempt to use dbms_redefinition  to rebuild or redefine the table. Since it is known that customer has a primary key from reviewing the prior DD, then it can be verified that it can be used as the redefinition driver. Otherwise, redefinition must function utilizing the data?s ROWID. Remember, dbms_redefinition is simply using materialized views behind the scenes.
 
BEGIN
  DBMS_REDEFINITION.CAN_REDEF_TABLE ('MOVIES', 'CUSTOMER', DBMS_REDEFINITION.CONS_USE_PK);
END;
/
Step 2: Create an interim table

Assuming that the table is a valid candidate, the interim table can then be created. This will be the partitioned table for the demonstration scenario. Note that the CREATE TABLE AS SELECT (CTAS) method is being used to save time here. The rows are not actually being copied because the SELECT WHERE clause evaluates to false. This is just a relatively easy shorthand method for the copy and, of course, adding the partitioning clause.
 
create table movies.customer_interim
partition by hash(zip) partitions 8
as
select * from movies.customer
where 1=0;
Step 3: Enable parallel DML operations

Now for those on multi-processor database servers, parallel operations can be enabled for the session to speed up the redefinition process. This is an optional step, but generally worth considering. Just make sure not to overdo using parallelization. If there is a very fast I/O subsystem and nothing else is really running, then consider up to two or four times of the actual CPU core count. It would also be good to check the db_writers  init.ora  parameter as well because it should be more than one if the choice is to force massive parallel operations that require extensive I/O.  Here are the commands for this.
 
alter session force parallel dml parallel 4;
alter session force parallel query parallel 4;
Step 4: Start the redefinition process

From this step forward, watch the time between steps. This means that the following steps need to happen in sequence and without major delays between them. This is pointed out because some DBAs are hesitant to put these reorganization steps in a script as they want to manually monitor each step of the process. That is fine, just do not go to lunch or home between them. If everything is ready to proceed to completion, then start the redefinition process.
 
BEGIN
  DBMS_REDEFINITION.START_REDEF_TABLE('MOVIES','CUSTOMER','CUSTOMER_INTERIM');
END;
/
Step 5: Copy dependent objects

This step performs one of the most critical and easily forgotten steps if this process was done without dbms_redefinition  ? to automatically create any required triggers, indexes, materialized view logs, grants, and/or constraints on the table. If one refers back to the section about DDL extraction via dbms_metadata , it is easy to guess that Oracle is eating their own cooking internally here. Now it makes a little more sense as to why dbms_metadata was designed as it is. Look how easy it is to copy all dependent objects with just a single call to dbms_redefinition.
 
DECLARE
  num_errors PLS_INTEGER;
BEGIN
  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS ('MOVIES',  'CUSTOMER', 'CUSTOMER_INTERIM',
    DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/
Step 6: Check for any errors

It is advisable now to check that this last operation completed successfully. This is stated because remember that it is doing quite a few things in the background here. It is quite possible for some things to need reviewing and possibly fixed manually. In most cases there should be no rows returned, so proceed.
 
select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS;
Step 7: Synchronize the interim table (optional)

If there has been any activity or transaction between the start of the redefinition and now, it might be advisable to resynchronize the interim table one more time. When in doubt, it is very much like chicken soup here ? it may not help, but it will not hurt anything either.
 
BEGIN
  DBMS_REDEFINITION.SYNC_INTERIM_TABLE ('MOVIES', 'CUSTOMER', 'CUSTOMER_INTERIM');
END;
/
Step 8: Complete the redefinition

This step does two things: it severs the behind-the-scenes materialized view connection and swaps the data dictionary entries for the table and interim table. So now, what was the interim table is caught up on structural modifications and any data transactions. Thus, it is safe to make this data dictionary entry swap.
 
BEGIN
  DBMS_REDEFINITION.FINISH_REDEF_TABLE ('MOVIES', 'CUSTOMER', 'CUSTOMER_INTERIM');
END;
/
Step 9: Drop the interim table

The interim table is now finished which, as of the last step, is actually the original table via the dictionary entry swap done by the finish operation. So drop that table. And if there is a concern about the data, an option is to do a SELECT against the new original table to verify that nothing has been lost.
 
drop table movies.customer_interim cascade constraints purge;

---##################################################################
Я один раз попробовала создавать индексы после dbms_redefinition.start_redef_table, что-то у меня не пошло, не помню точно что. От этого отказалась.

Теперь я делаю так:
1 создать временную таблицу
2. создать все индесы во временной таблице
3. dbms_redefinition.start_redef_table

4. регистрация всех индекcов
DBMS_REDEFINITION.REGISTER_DEPENDENT_OBJECT

5. копировать зависимости без индексов
--здесь ignore_errors=TRUE, копировать статистику в секционированную таблицу не надо, поэтому параметр опущен:
DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('...','...','...',DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/
-- проверить ошибки
SELECT object_name, base_table_name, ddl_txt FROM DBA_REDEFINITION_ERRORS;
--есть ошибки по констрейнтам NOT NULL, созданным во время создания таблицы NULL?=N

6. собрать статистику по временной таблице
DBMS_STATS.GATHER_TABLE_STATS

7. синхронизацию можно выполнять несколько раз,
чтобы сократить время на шаг FINISH, что сократит время недоступности таблицы
DBMS_REDEFINITION.SYNC_INTERIM_TABLE

8. временно остановить джобы!!!!!!
и проверить блокировки по данной таблице от джобов

9. финиш
DBMS_REDEFINITION.FINISH_REDEF_TABLE 

10. drop interim table


-- на всякий случай прервать процедуру DBMS_REDEFINITION из другой сессии
ABORT выполнялся 7-8 мин

DBMS_REDEFINITION.ABORT_REDEF_TABLE


-- когда пыталась дропнуть таблицу после аборта пакета, то выдалась ошибка
--ORA-12083: must use DROP MATERIALIZED VIEW to drop "string"."string" 
-- пришлось сначала дропнуть MATERIALIZED VIEW
--потом дропнула таблицу


--############################################################################################
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
The challenge is now to change this table into a partitioned one while it is used with DML & queries by end users. For this purpose, we introduced already in 9i (if I recall it right) the package DBMS_REDEFINITION. First step would be to ask, whether it can be used in this case:

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

--################################################################
DBMS_REDEFINITION Revisited
March 3, 2015
It has come to my attention that my last post on dbms_redefinition was really too simplistic to be useful. Therefore, I have set up a new example to show some of the true capabilities of dbms_redefinition. So for this example, we will change column data types instead of just the column sizes. Below are the layouts of our source table (CUSTDATA) and our interim table (CUSTDATA_INT):

SQL> desc custdata
 Name                                      Null?    Type
 ----------------------------------------- -------- -------------
 CRDATTIM                                  NOT NULL CHAR(26)
 CASE_NUMBER                                        CHAR(10)
 LAST_NAME                                          CHAR(30)
 FIRST_NAME                                         CHAR(30)
 
 
SQL> desc custdata_int
 Name                                      Null?    Type
 ----------------------------------------- -------- -------------------
 CRDATTIM                                  NOT NULL TIMESTAMP(6)
 CASE_NUMBER                                        VARCHAR2(30)
 LAST_NAME                                          VARCHAR2(30)
 FIRST_NAME                                         VARCHAR2(30)
Note that the custdata table layout is not particularly good, but it is an example of an actual case, this is a table of legacy data that we are unable to get rid of.  I am working on getting our application team to redesign it to a more sensible layout, but that will take time. As can be seen, there is an extensive amount of data changes to go through.  As in our previous example, first we have to verify that the table can be redefined use DBMS_REDEFINITION:

SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.CAN_REDEF_TABLE(
  3  uname=>'SCOTT',
  4  tname=>'CUSTDATA',
  5  options_flag=>DBMS_REDEFINITION.cons_use_rowid);
  6  end;
  7  /
 
PL/SQL procedure successfully completed.
Now that we have verified that the source table can be redefined using dbms_redefinition, we begin the process:

SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.START_REDEF_TABLE(
  3  uname=>'SCOTT',
  4  orig_table=>'CUSTDATA',
  5  int_table=>'CUSTDATA_INT',
  6  col_mapping=>'to_timestamp(crdattim,'||''''||'yyyy-mm-dd-hh24.mi.ss.ff'||''
''||') crdattim,
  7  rtrim(ltrim(case_number)) case_number,
  8  rtrim(ltrim(first_name)) first_name,
  9  rtrim(ltrim(last_name)) last_name',
 10  options_flag=>DBMS_REDEFINITION.cons_use_rowid);
 11  end;
 12  /
 
PL/SQL procedure successfully completed.
 
SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.SYNC_INTERIM_TABLE(
  3  uname=>'SCOTT',
  4  orig_table=>'CUSTDATA',
  5  int_table=>'CUSTDATA_INT');
  6  end;
  7  /
 
PL/SQL procedure successfully completed.
So, everything is going well.  Let’s move on to the next step:


  
SQL> SET SERVEROUTPUT ON
SQL> DECLARE
  2  l_num_errors PLS_INTEGER;
  3  begin
  4  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
  5  uname=>'SCOTT',
  6  orig_table=>'CUSTDATA',
  7  int_table=>'CUSTDATA_INT',
  8  copy_indexes => DBMS_REDEFINITION.cons_orig_params,
  9  copy_triggers => TRUE,
 10  copy_constraints => TRUE,
 11  copy_privileges => TRUE,
 12  ignore_errors => FALSE,
 13  num_errors => l_num_errors);
 14  end;
 15  /
DECLARE
*
ERROR at line 1:
ORA-01442: column to be modified to NOT NULL is already NOT NULL
ORA-06512: at "SYS.DBMS_REDEFINITION", line 1015
ORA-06512: at "SYS.DBMS_REDEFINITION", line 1907
ORA-06512: at line 4
At this point, I abort the process and try and track down the problem.  To abort a dbms_Redefinition process, the command is abort_redef_table, like this:

SQL> begin
  2  DBMS_REDEFINITION.ABORT_REDEF_TABLE(uname=>'SCOTT',orig_table=>'CUSTDATA',int_table=>'CUSTDATA_INT');
  3  End;
  4  /
 
PL/SQL procedure successfully completed.
The error message does look like a possible Oracle bug.  Let’s see what the Metalink (My Oracle Support) says: I searched on ORA-01442 DBMS_REDEFINITION, and the first result is Document ID 1116785.1, ORA-1442 Error During Online Redefinition – DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS.  Oracle doesn’t actually say it is a bug, and it may not be.  It probably stems from the fact that I created my interim table using a create table as select, then made changes to it.  It looks like I just need to drop the not null constraint on CUSTDATA_INT and start over, so let’s try that. I ran this query:


SQL> select * from dba_constraints where table_name ='CUSTDATA' and owner='SCOTT';
OWNER
-------------------------------------
CONSTRAINT_NAME                C
------------------------------ -
SCOTT
SYS_C0038648                   C
So there is only one constraint, a check constraint.  I will drop that, and see if that fixes the problem.

SQL> alter table custdata_int drop constraint SYS_C0038648;
Table altered.
Sure enough, that fixed it (NOTE: We have to restart at the beginning since we used the ABORT_REDEF_TABLE procedure.)

SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.START_REDEF_TABLE(
  3  uname=>'SCOTT',
  4  orig_table=>'CUSTDATA',
  5  int_table=>'CUSTDATA_INT',
  6  col_mapping=>'to_timestamp(crdattim,'||''''||'yyyy-mm-dd-hh24.mi.ss.ff'||''
''||') crdattim,
  7  rtrim(ltrim(case_number)) case_number,
  8  rtrim(ltrim(first_name)) first_name,
  9  rtrim(ltrim(last_name)) last_name',
 10  options_flag=>DBMS_REDEFINITION.cons_use_rowid);
 11  end;
 12  /
 
PL/SQL procedure successfully completed.
 
SQL> SET SERVEROUTPUT ON
SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.SYNC_INTERIM_TABLE(
  3  uname=>'SCOTT',
  4  orig_table=>'CUSTDATA',
  5  int_table=>'CUSTDATA_INT');
  6  end;
  7  /
 
PL/SQL procedure successfully completed.
 
SQL> SET SERVEROUTPUT ON
SQL> DECLARE
  2  l_num_errors PLS_INTEGER;
  3  begin
  4  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
  5  uname=>'SCOTT',
  6  orig_table=>'CUSTDATA',
  7  int_table=>'CUSTDATA_INT',
  8  copy_indexes => DBMS_REDEFINITION.cons_orig_params,
  9  copy_triggers => TRUE,
 10  copy_constraints => TRUE,
 11  copy_privileges => TRUE,
 12  ignore_errors => FALSE,
 13  num_errors => l_num_errors);
 14  end;
 15  /
 
PL/SQL procedure successfully completed.
So, lets finish the process:

 
SQL> SET SERVEROUTPUT ON
SQL> begin
  2  DBMS_REDEFINITION.FINISH_REDEF_TABLE(
  3  uname=>'SCOTT',
  4  orig_table=>'CUSTDATA',
  5  int_table=>'CUSTDATA_INT');
  6  end;
  7  /
 
PL/SQL procedure successfully completed.
 
SQL> alter table custdata drop unused columns;
Table altered.
 
SQL> exec dbms_stats.gather_table_stats(ownname=>'SCOTT',tabname=>'CUSTDATA', ca
scade=>true);
 
PL/SQL procedure successfully completed.
 
SQL>
 
SQL> desc custdata;
 Name                                      Null?    Type
 ----------------------------------------- -------- -----------------
 CRDATTIM                                           TIMESTAMP(6)
 CASE_NUMBER                                        VARCHAR2(30)
 LAST_NAME                                          VARCHAR2(30)
 FIRST_NAME                                         VARCHAR2(30)
Note a couple of steps I left off in my earlier example: drop unused columns and gathering stats.  The unused column was used in the redefinition process because I was using the ROWID option (cons_use_rowid).  Oracle added at the start of the process to keep track of rows, and Oracle automatically marks it as unused once the process is complete, but it is a best practice to drop the column when the process is complete.

--#####################################################
On-line Table Reorganization and Redefinition
Submitted by admin on Sat, 2003-08-02 14:21 RDBMS Server

 
Tables can be reorganized and redefined (evolved) on-line with the DBMS_REDEFINITION package. The process is similar to on-line rebuilds of indexes, in that the original table is left on-line, while a new copy of the table is built. However, an index index-rebuild is a singular operation, while table redefinition is a multi-step process.

Table redefinition is started by the DBA creating an interim table based on the original table. The interim table can have a different structure than the original table, and will eventually take the original table's place in the database. While the table is redefined, DML operations on the original table are captured in a Materialized View Log table (MLOG$_%). These changes are eventually transformed and merged into the interim table. When done, the names of the original and the interim tables are swapped in the data dictionary. At this point all users will be working on the new table and the old table can be dropped.

Possible applications:

On-line Table Redefinition can be used for:

Add, remove, or rename columns from a table
Converting a non-partitioned table to a partitioned table and vice versa
Switching a heap table to an index organized and vice versa
Modifying storage parameters
Adding or removing parallel support
Reorganize (defragmenting) a table
Transform data in a table
Restrictions:

One cannot redefine Materialized Views (MViews) and tables with MViews or MView Logs defined on them.
One cannot redefine Temporary and Clustered Tables
One cannot redefine tables with BFILE, LONG or LONG RAW columns
One cannot redefine tables belonging to SYS or SYSTEM
One cannot redefine Object tables
Table redefinition cannot be done in NOLOGGING mode (watch out for heavy archiving)
Cannot be used to add or remove rows from a table
Using On-line Redefinition from Enterprise Manager:

Oracle Enterprise Manager's REORG Wizard (part of the Tuning pack) allows DBAs to reorganize tables off-line or on-line. If on-line reorganization is chosen, Oracle will make use of the DBMS_REDEFINITION package. Off-line reorganization is quicker than on-line reorganization, but if the system cannot go down, the on-line method will prove valuable.

Execute the following steps to start the REORG Wizard: Start OEM. Click on TOOLS -> TUNING PACK -> REORG WIZARD.

Using On-line Redefinition from SQL*Plus:

A table can be redefined in 7 easy steps from SQL*Plus.

Step 1: Grant privileges:

Grant EXECUTE ON DBMS_REDEFINITION and the following privileges to the user that will do the redefinition: CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE, LOCK ANY TABLE, SELECT ANY TABLE. Look at this example:

SQL> grant execute on dbms_redefinition to scott;
SQL> grant dba to scott;
Note: These are powerful privileges, so remember to revoke them afterwards.

Step 2: Test if the table can be redefined:

Execute the DBMS_REDEFINITION.CAN_REDEF_TABLE procedure to test if a table can be redefined or not. A table qualifies for redefinition if no exceptions are raised. Possible errors:

ORA-12089 cannot online redefine table with no primary key
ORA-12091: cannot online redefine table "SCOTT"."EMP" with materialized views
ORA-00942: table or view does not exist
SQL> EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE('scott', 'emp', DBMS_REDEFINITION.CONS_USE_PK);

Note: The redefinition process can be based on a Primary Key or ROWID. Two constants are defined for this purpose: DBMS_REDEFINITION.CONS_USE_PK (the default) and DBMS_REDEFINITION.CONS_USE_ROWID. One can also use the value "1" for the primary key method, and "2" to indicate the rowid method. This is required so Oracle will know how to create the mview log: WITH ROWID, or WITH PRIMARY KEY.

Step 3: Create an interim table with new structure

Create an interim table with the new table structure. Define a primary key if you want to use the primary key method (DBMS_REDEFINITION.CONS_USE_PK). This is not required for the rowid method.

Oracle will TRUNCATE the interim table in step 4; so, do not add any data to it yet. Avoid adding constraints and indexes at this stage (for best performance).

Step 4: Start the redefinition

During this phase Oracle will copy (and transform) the data from the production table to the interim table. Oracle will also create a materialized view (snapshot) log on the table to track DML changes.

SQL> exec dbms_redefinition.start_redef_table('scott', 'emp', 'emp_work', -
>         'emp_id emp_id, ename ename, salary salary', -
>         DBMS_REDEFINITION.CONS_USE_PK);
Note parameter 4: mapping for the old table's columns to the new table's columns. This can be left out if the columns are the same.

Step 5: Sync intermediate changes to interim table (optional)

This step will apply changes captured in the materialized view log to the interim table. Perform this step frequently for high transaction tables.

SQL> exec dbms_redefinition.sync_interim_table('scott', 'emp', 'emp_work');

Step 6: Create indexes, constraints and triggers on the interim table

Note that you cannot use the same names for indexes and constraints. Foreign key constraints must be created DISABLED (Oracle will enable them in step 6).

Step 7: Complete the redefinition process

During this step Oracle will lock both tables in exclusive mode, swap the names of the two tables in the data dictionary, and enable all foreign key constraints. Remember to drop the original table afterwards. One can also consider renaming the constraints back to their original names (e.g.: alter table EMP rename constraint SYS_C001806 to emp_fk).

SQL> exec dbms_redefinition.finish_redef_table('scott', 'emp', 'emp_work');

Optional step to Abort Redefinition:

Redefinition can be aborted at any stage by calling the DBMS_REDEFINITION.ABORT_REDEF_TABLE procedure. This will drop the mview log on the production table. Note that you need to abort before trying again, otherwise you will get an ORA-12091 error as described in step 2.

Examples:

Example 1: On-line Table Reorg using the rowid method

EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE('scott', 'emp', 2);  -- 2=rowid
CREATE TABLE emp_work AS SELECT * FROM emp WHERE 1=2;
EXEC DBMS_REDEFINITION.START_REDEF_TABLE('scott', 'emp', 'emp_work', NULL, 2);
ALTER TABLE emp ADD PRIMARY KEY (empno);
EXEC DBMS_REDEFINITION.FINISH_REDEF_TABLE('scott', 'emp', 'emp_work');
DROP TABLE emp_work;
Example 2: Redefine a table using the primary key method

-- Create a new table with primary key...
CREATE TABLE myemp (
	empid  NUMBER PRIMARY KEY,
	ename  VARCHAR2(30),
	salary NUMBER(8,2),
	deptno NUMBER);
insert into myemp values (1, 'Frank', 15000, 10);
insert into myemp values (2, 'Willie',  10000, 20);
create index myemp_idx on myemp (ename);

-- Test if redefinition is possible...
EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE('scott', 'myemp');

-- Create new empty interim table...
CREATE TABLE myemp_work (
	emp#   NUMBER PRIMARY KEY,	-- Change emp_id to emp#
	ename    VARCHAR2(30),
	salary   NUMBER(8,2),		-- We will increase salary by 10%
	deptno   NUMBER)
   PARTITION BY LIST (deptno) (  	-- Add list partitioning
	PARTITION p10 VALUES (10), 
	PARTITION p20 VALUES (20), 
	PARTITION p30 VALUES (30,40));

-- Create a transformation function...
CREATE FUNCTION raise_sal (salary NUMBER) RETURN NUMBER AS
BEGIN
 return salary + salary*0.10; 
END;
/

-- Start the redefinition process
EXEC DBMS_REDEFINITION.START_REDEF_TABLE('scott', 'myemp', 'myemp_work', -
	'empid emp#, ename ename, raise_sal(salary) salary, deptno deptno', -
	DBMS_REDEFINITION.CONS_USE_PK);

-- Apply captured changed to interim table
EXEC DBMS_REDEFINITION.SYNC_INTERIM_TABLE('scott', 'myemp', 'myemp_work');

-- Add constraints, indexes, triggers, grants on interim table...
create index myempidx2 on myemp_work (ename);

-- Finish the redefinition process...
EXEC DBMS_REDEFINITION.FINISH_REDEF_TABLE('scott', 'myemp', 'myemp_work');

-- Cleanup
DROP TABLE myemp_work;
DROP FUNCTION raise_sal;
References:

Oracle9i Database Administrator's Guide Release 2 (9.2) Chapter 15: Managing Tables