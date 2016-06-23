--Create a Sample Schema

--First we create a sample schema as our starting point.
-- Create and populate a small lookup table.
CREATE TABLE lookup (
  id            NUMBER(10),
  description   VARCHAR2(50)
);

ALTER TABLE lookup ADD (
  CONSTRAINT lookup_pk PRIMARY KEY (id)
);

INSERT INTO lookup (id, description) VALUES (1, 'ONE');
INSERT INTO lookup (id, description) VALUES (2, 'TWO');
INSERT INTO lookup (id, description) VALUES (3, 'THREE');
COMMIT;

-- Create and populate a larger table that we will later partition.
CREATE TABLE big_table (
  id            NUMBER(10),
  created_date  DATE,
  lookup_id     NUMBER(10),
  data          VARCHAR2(50)
);

DECLARE
  l_lookup_id    lookup.id%TYPE;
  l_create_date  DATE;
BEGIN
  FOR i IN 1 .. 1000000 LOOP
    IF MOD(i, 3) = 0 THEN
      l_create_date := ADD_MONTHS(SYSDATE, -24);
      l_lookup_id   := 2;
    ELSIF MOD(i, 2) = 0 THEN
      l_create_date := ADD_MONTHS(SYSDATE, -12);
      l_lookup_id   := 1;
    ELSE
      l_create_date := SYSDATE;
      l_lookup_id   := 3;
    END IF;
    
    INSERT INTO big_table (id, created_date, lookup_id, data)
    VALUES (i, l_create_date, l_lookup_id, 'This is some data for ' || i);
  END LOOP;
  COMMIT;
END;
/

-- Apply some constraints to the table.
ALTER TABLE big_table ADD (
  CONSTRAINT big_table_pk PRIMARY KEY (id)
);

CREATE INDEX bita_created_date_i ON big_table(created_date);

CREATE INDEX bita_look_fk_i ON big_table(lookup_id);

ALTER TABLE big_table ADD (
  CONSTRAINT bita_look_fk
  FOREIGN KEY (lookup_id)
  REFERENCES lookup(id)
);

-- Gather statistics on the schema objects
EXEC DBMS_STATS.gather_table_stats(USER, 'LOOKUP', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats(USER, 'BIG_TABLE', cascade => TRUE);
Create a Partitioned Interim Table

--Next we create a new table with the appropriate partition structure to act as an interim table.

-- Create partitioned table.
CREATE TABLE big_table2 (
  id            NUMBER(10),
  created_date  DATE,
  lookup_id     NUMBER(10),
  data          VARCHAR2(50)
)
PARTITION BY RANGE (created_date)
(PARTITION big_table_2003 VALUES LESS THAN (TO_DATE('01/01/2004', 'DD/MM/YYYY')),
 PARTITION big_table_2004 VALUES LESS THAN (TO_DATE('01/01/2005', 'DD/MM/YYYY')),
 PARTITION big_table_2005 VALUES LESS THAN (MAXVALUE));
 
 
 --With this interim table in place we can start the online redefinition.

--Start the Redefinition Process

--First we check the redefinition is possible using the following command.

EXEC DBMS_REDEFINITION.can_redef_table(USER, 'CUSTOMERW');
--or

begin
dbms_redefinition.can_redef_table
 (uname=>'BARS',
 tname=>'CUSTOMERW',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/

--###########################  ORA-42012: error occurred while completing the redefinition
begin
dbms_redefinition.can_redef_table
 (uname=>'BARS',
 tname=>'CUSTOMERW',
 options_flag=>DBMS_REDEFINITION.CONS_USE_PK);
end;
/


--If no errors are reported it is safe to start the redefinition using the following command.

-- Alter parallelism to desired level for large tables.
--ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
--ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

BEGIN
  DBMS_REDEFINITION.start_redef_table(
    uname      => USER,        
    orig_table => 'CUSTOMERW',
    int_table  => 'CUSTOMERW_IOT');
END;
/
--or

BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE
 (uname=>'ADAM',
 orig_table=>'ORIGINAL',
 int_table=>'INTERIM',
 options_flag=>DBMS_REDEFINITION.CONS_USE_ROWID);
end;
/


--Depending on the size of the table, this operation can take quite some time to complete.

--Create Constraints and Indexes (Dependencies)

--If there is delay between the completion of the previous operation and moving on to finish the redefinition, it may be sensible to resynchronize the interim table before building any constraints and indexes. The resynchronization of the interim table is initiated using the following command.

-- Optionally synchronize new table with interim data before index creation
BEGIN
  dbms_redefinition.sync_interim_table(
    uname      => USER,        
    orig_table => 'BIG_TABLE',
    int_table  => 'BIG_TABLE2');
END;
/


--The dependent objects will need to be created against the new table. This is done using the COPY_TABLE_DEPENDENTS procedure. You can decide which dependencies should be copied.

SET SERVEROUTPUT ON
DECLARE
  l_errors  NUMBER;
BEGIN
  DBMS_REDEFINITION.copy_table_dependents(
    uname            => USER,
    orig_table       => 'BIG_TABLE',
    int_table        => 'BIG_TABLE2',
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

--The fact you are partitioning the table means you should probably consider the way you are indexing the table. You may want to manually create the constraints and indexes against the interim table using alternate names to prevent errors. The indexes should be created with the appropriate partitioning scheme to suit their purpose.

-- Add new keys, FKs and triggers.
ALTER TABLE big_table2 ADD (
  CONSTRAINT big_table_pk2 PRIMARY KEY (id)
);

CREATE INDEX bita_created_date_i2 ON big_table2(created_date) LOCAL;

CREATE INDEX bita_look_fk_i2 ON big_table2(lookup_id) LOCAL;

ALTER TABLE big_table2 ADD (
  CONSTRAINT bita_look_fk2
  FOREIGN KEY (lookup_id)
  REFERENCES lookup(id)
);

-- Gather statistics on the new table.
EXEC DBMS_STATS.gather_table_stats(USER, 'BIG_TABLE2', cascade => TRUE);

--Complete the Redefinition Process
--Once the constraints and indexes have been created the redefinition can be completed using the following command.

BEGIN
  dbms_redefinition.finish_redef_table(
    uname      => USER,        
    orig_table => 'BIG_TABLE',
    int_table  => 'BIG_TABLE2');
END;
/


--At this point the interim table has become the "real" table and their names have been switched in the data dictionary. All that remains is to perform some cleanup operations.

-- Remove original table which now has the name of the interim table.
DROP TABLE big_table2;

-- Rename all the constraints and indexes to match the original names.
ALTER TABLE big_table RENAME CONSTRAINT big_table_pk2 TO big_table_pk;
ALTER TABLE big_table RENAME CONSTRAINT bita_look_fk2 TO bita_look_fk;
ALTER INDEX big_table_pk2 RENAME TO big_table_pk;
ALTER INDEX bita_look_fk_i2 RENAME TO bita_look_fk_i;
ALTER INDEX bita_created_date_i2 RENAME TO bita_created_date_i;

--The following queries show that the partitioning was successful.

SELECT partitioned
FROM   user_tables
WHERE  table_name = 'BIG_TABLE';


SELECT partition_name
FROM   user_tab_partitions
WHERE  table_name = 'BIG_TABLE';


--###################   MY    Exemple       #######################
-- Create new table

 CREATE TABLE customerw_prt (rnk   NUMBER(38),
                                               tag   CHAR(5),
                                               value VARCHAR2(500),
                                               isp   NUMBER(38),
                                               PRIMARY KEY (tag, rnk))
   PARTITION BY HASH (tag)
   PARTITIONS 8 
   STORE IN (BRSBIGD, IMP_DATA);
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
             STORE IN (BRSDYNI, IMP_DATA)
             OVERFLOW STORE IN (IMP_DATA);
 
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

/*
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
/*
