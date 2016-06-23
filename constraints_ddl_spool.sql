Don't have time to look too close but perhaps this script will work
for you, this is what I required to generate some PK/FK related DDL.
It created some scripts which I could use to drop, rebuild some
constraints for a particular issue I was working on.

Call it like this...

@script.sql TABLE_NAME

set echo off feed off pages 0 trims on term off trim on
set long 500000
set heading off
set linesize 255
set ver off
set term on

column ddl format a200 word_wrapped

spool ~metadata.sql

select 'select dbms_metadata.get_ddl(''REF_CONSTRAINT'','''||a.constraint_name||''')||'';''
ddl from dual;'
from

user_constraints a,
user_constraints b
where a.constraint_type='R'
and a.r_constraint_name=b.constraint_name

and b.constraint_type='P'
and b.table_name='&1';

spool off

spool make_fk.sql
@~metadata.sql
spool off

spool drop_fk.sql

select 'alter table '||a.table_name||' drop constraint
'||a.constraint_name||';' ddl
from

user_constraints a,
user_constraints b
where a.constraint_type='R'
and a.r_constraint_name=b.constraint_name

and b.constraint_type='P'
and b.table_name='&1';

spool off

spool ~metadata.sql

select 'select dbms_metadata.get_ddl(''CONSTRAINT'','''||a.constraint_name||''')||'';''
ddl from dual;'
from

user_constraints a
where a.constraint_type='P'
and a.table_name='&1';

spool off

spool pk.sql

select 'alter table &1 drop primary key;' ddl from dual;

@~metadata.sql

spool off

!rm ~metadata.sql