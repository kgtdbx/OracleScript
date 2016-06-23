
--define username= BARS
accept username prompt 'Input username:'
--define tab= CUSTOMERW
accept tab prompt 'Input table name:'
--define inttab= CUSTOMERW_IOT
accept inttab prompt 'Input interim table name:'

--##########################################

PROMPT ===========================================
PROMPT -- 
PROMPT ===========================================


PROMPT ===========================================
PROMPT -- Check table can be redefined
PROMPT ===========================================

BEGIN
DBMS_REDEFINITION.CAN_REDEF_TABLE
 (uname        =>'BARS',
  tname        =>'ACCOUNTSW',
  options_flag    =>DBMS_REDEFINITION.CONS_USE_ROWID);
END;
/
--WHENEVER SQLERROR EXIT
WHENEVER SQLERROR CONTINUE
--ORA-42039: cannot online redefine table with FGA or RLS enabled ---Bug with virtual column or need to disabke policy

 --##########################################
-- Alter parallelism to desired level for large tables.
--ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
--ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;
PROMPT ===========================================
PROMPT -- Start Redefinition
PROMPT ===========================================

BEGIN
DBMS_REDEFINITION.START_REDEF_TABLE
 (uname      =>'BARS',
  orig_table  =>'OPERW',
  int_table    =>'OPERW_PRT',
  options_flag  =>DBMS_REDEFINITION.CONS_USE_ROWID);
END;
/

 --##########################################
PROMPT ===========================================
PROMPT -- Optionally synchronize new table with interim data before index creation
PROMPT ===========================================

BEGIN
  DBMS_REDEFINITION.SYNC_INTERIM_TABLE
  (uname        =>'BARS',        
   orig_table  =>'OPERW',
   int_table  =>'OPERW_PRT');
END;
/

 --##########################################
PROMPT ===========================================
PROMPT -- Copy dependent objects
PROMPT ===========================================

DECLARE
  num_errors PLS_INTEGER;
BEGIN
  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS ('BARS',  'OPERW', 'OPERW_PRT',
    DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
END;
/

--проверяем что вылетело в ощибки
--select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS;
--##########################################
PROMPT ===========================================
PROMPT -- Complete redefinition
PROMPT ===========================================

BEGIN
  DBMS_REDEFINITION.FINISH_REDEF_TABLE
   (uname           =>'BARS',        
    orig_table       =>'OPERW',
    int_table        =>'OPERW_PRT');
END;
/

--##########################################
PROMPT ===========================================
PROMPT -- ALTER TABLE OPERW DROP UNUSED COLUMNS
PROMPT ===========================================

--удаляем виртуальный уже не нужный виртуальный столбец, если  использовал CONS_USE_ROWID
ALTER TABLE OPERW DROP UNUSED COLUMNS;
--##########################################
PROMPT ===========================================
PROMPT -- GATHER_TABLE_STATS
PROMPT ===========================================

begin
 DBMS_STATS.GATHER_TABLE_STATS('BARS', 'OPERW', cascade => TRUE); 
 end;
 /
--##########################################
PROMPT ===========================================
PROMPT -- Remove original table which now has the name of the new table
PROMPT ===========================================

DROP TABLE OPERW_PRT CASCADE CONSTRAINTS PURGE; 
--##########################################
PROMPT ===========================================
PROMPT -- Rename the primary key constraint
PROMPT ===========================================

ALTER TABLE OPERW RENAME CONSTRAINT PK_OPERW_PRT TO PK_OPERW;
--##########################################
PROMPT ===========================================
PROMPT -- Validate constraints
PROMPT ===========================================

declare
 l_tab       varchar2(4000) :='OPERW';
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
/  
--##########################################
--по необходимости ребилд зависимых объектов или схемы

prompt -- =======================
prompt -- Rebuilding schema ... 
prompt -- =======================
exec dbms_utility.compile_schema(schema=>'BARS', compile_all=>false);

prompt -- =======================
prompt -- Show INVALID objects ... 
prompt -- =======================

column object_name format a30
column object_type format a30
select object_name,object_type
from user_objects
where status <> 'VALID';

prompt -- ===========================================
prompt -- Execution is completed.
prompt -- Check log file for error.
prompt -- ===========================================

spool off
