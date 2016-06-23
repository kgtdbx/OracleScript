SQL> create global temporary table tmp$t(c clob) on commit preserve rows;

Table created.

SQL> create table t_remote(c clob, ts timestamp);

Table created.

SQL>
SQL> create or replace function f return sys_refcursor as
  2    result sys_refcursor;
  3  begin
  4    open result for select userenv('sid') sid from dual;
  5    return result;
  6  end;
  7  /

Function created.

SQL> create or replace function f_wrap return timestamp is
  2    result timestamp;
  3    c      clob := xmltype(f).getclobval;
  4  begin
  5    insert into t_remote (c, ts) values (c, systimestamp) returning ts into result;
  6    return result;
  7  end f_wrap;
  8  /

Function created.

SQL>
SQL> truncate table tmp$t;

Table truncated.

SQL> -- LOCAL CALL
SQL> <<block>>
  2  declare
  3    ts timestamp := f_wrap;
  4  begin
  5    insert into tmp$t select c from t_remote where ts = block.ts;
  6  end;
  7  /

PL/SQL procedure successfully completed.

SQL> select * from xmltable('/ROWSET/ROW' passing (select xmltype(c) from tmp$t) columns sid number path 'SID');

       SID
----------
        16

SQL> truncate table tmp$t;

Table truncated.

SQL> -- "REMOTE" CALL
SQL> <<block>>
  2  declare
  3    ts timestamp := f_wrap@self;
  4  begin
  5    insert into tmp$t select c from t_remote@self where ts = block.ts;
  6  end;
  7  /

PL/SQL procedure successfully completed.

SQL> select * from xmltable('/ROWSET/ROW' passing (select xmltype(c) from tmp$t) columns sid number path 'SID');

       SID
----------
       135

SQL> truncate table tmp$t;

Table truncated.