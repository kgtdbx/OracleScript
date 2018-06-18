/*
COMPARE_SYNC: Introducing the package
Posted on 2015/01/21 by stewashton
After many blog posts about comparing and synchronizing tables, I have united all the techniques I presented in one place. The COMPARE_SYNC package generates SQL for

Comparing tables, views and queries, both local and remote.
Synchronizing, or applying changes to target tables from either source tables or “Change Data Capture” input.
This is a “helper” tool for developers. It does not change the data, it just returns a SQL statement that you can analyze, test and deploy as you wish.

For “help”, look at the comments in the package specification.

I’ll be blogging about some use cases soon. In the meantime, check it out…and please give me feedback in the comments.

Alas, WordPress won’t let me upload .sql files, so I’m afraid you’ll have to do some copying and pasting: sorry.

Hope this helps…

[Update 2015-01-25: the extra “--'” at the end of “default 'OPERATION'” is just a workaround for the SQL syntax highligher.]

[Update 2015-01-30: P_OLD_OWNER now has a default value of null, which means assume the target belongs to the current user but don’t put the owner in the generated SQL. Added the P_OLD_DBLINK parameter. Bug fixes.]

[Update 2015-03-03: Changed name to COMPARE_SYNC. Column lists are CLOBs and are formatted in lines of 80 characters max. Bug fix to allow querying ALL_TAB_COLS in versions 10 and 11.]

[Update 2015-03-06: To get DB version, using V$VERSION (accessible to PUBLIC) instead of V$INSTANCE. Now accessing ALL_CONSTRAINTS from remote database when appropriate.]


*/
create or replace package COMPARE_SYNC
authid current_user as
/*
COMPARE_SYNC generates SQL for comparing or synchronizing
"old" target and "new" source.
 
- "Old" can be a table or view, local or remote.
  Indicate separately the "old" owner, "old" table and "old" dblink.
  To compare two queries, create a view to use as the "old".
  To sync, "old" is usually a table but I do not check that for you.
- "New" can be local, remote, table, view or a query enclosed in parentheses.
  Examples: 'SCOTT.EMP', 'T_SOURCE@DBLINK', '(select * from SCOTT.EMP@DBLINK)'
 
Note: I never check the "new" source for validity.
I only check the "old" target for validity
when I look up columns from the data dictionary.
So the generated SQL is not guaranteed to run without error!
   
The generated SQL is returned as a CLOB.
 
To debug, change the value of G_DOLOG to true. See line 16 of the package body.
 
COMMON INPUT PARAMETERS:
 
P_OLD_OWNER  : owner of the target. Must exist in the database.
  The default is null, which assumes the current user.
   
P_OLD_TABLE  : name of the target table or view. Must exist in the database.
 
P_NEW_SOURCE : source table or view - or query enclosed in parentheses.
 
P_TAB_COLS   : optional sys.odcivarchar2list() array of columns to compare/sync.
  If you leave out P_TAB_COLS, every non-virtual column will be compared/synced,
  both visible and invisible.
   
P_OLD_DBLINK : dblink to the target database.
  The default is null, which means the target is in the local database.
 
2015-01-30:
  bug fixes. Added P_OLD_DBLINK parameter. P_OLD_OWNER now has default value.
2015-02-28:
  Changed name of package to COMPARE_SYNC
  Column lists are now reformatted so line length is 80 maximum.
  Column lists are now CLOB instead of VARCHAR2, so no limits on number of columns.
  Fixed bug accessing ALL_TAB_COLS.USER_GENERATED, which was only added in 12.1.
    I now use different code for previous versions.
2015-03-06:
  To get DB version, using V$VERSION (accessible to PUBLIC) instead of V$INSTANCE.
  Now accessing ALL_CONSTRAINTS from remote database when appropriate.
*/
/*
COMPARING
 
COMPARE_SQL returns SQL that compares new source and old target
using Tom Kyte's GROUP BY method.
*/
/*
Example:
  select COMPARE_SYNC.COMPARE_SQL(user, 'T_TARGET', 'T_SOURCE') from DUAL;
*/
  function COMPARE_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.COMPARE_SQL(
    null, 
    'T_TARGET', 
    'T_SOURCE',
    SYS.ODCIVARCHAR2LIST('C1','C2','C3', '"c4"')
  ) from DUAL;
*/
  function COMPARE_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
   
/*
SYNCHRONIZING
 
The package can synchronize in one of three ways:
1) SYNC: Compare and sync from source to target: inserts, updates and deletes.
2) SYNC_UPSERT: sync from source to target: inserts and updates but no deletes.
3) SYNC_CDC: the source is a "Change Data Capture" table.
  It contains inserts, updates and deletes to be directly applied.
 
SYNC_UPSERT and SYNC_CDC require a target
  with both primary key and non-key columns.
SYNC works with any combination of key and non-key columns,
but the target must be a table when I use the ROWID.
 
Additional input parameters are:
 
P_KEY_COLS : optional array of primary key columns as sys.odcivarchar2list().
  This overrides the default search for PK columns in ALL_CONS_COLUMNS.
  You can specify P_KEY_COLS without specifying P_TAB_COLS,
  but not the reverse.
   
P_OPERATION_COL : name of the column containing the CDC flag ('D', 'I', 'U').
  The default is 'OPERATION'.
  I delete the rows where the value is 'D'. I ignore any other value
  because I can tell whether to insert or update without it.
*/
/*
Example:
  select COMPARE_SYNC.SYNC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE'
  ) from DUAL;
*/
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
   
/*
Example:
  select COMPARE_SYNC.SYNC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE'
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2')
  ) from DUAL;
*/
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
   
/*
Example:
  select COMPARE_SYNC.SYNC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE',
    P_TAB_COLS => SYS.ODCIVARCHAR2LIST('C1','C2','C3', '"c4"'),
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2')
  ) from DUAL;
*/
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
   
/*
Example:
  select COMPARE_SYNC.SYNC_UPSERT_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE'
  ) from DUAL;
*/
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.SYNC_UPSERT_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE',
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2')
  ) from DUAL;
*/
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.SYNC_UPSERT_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_SOURCE',
    P_TAB_COLS => SYS.ODCIVARCHAR2LIST('C1','C2','C3', '"c4"'),
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2')
  ) from DUAL;
*/
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.SYNC_CDC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_CDC'
  ) from DUAL;
*/
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OPERATION_COL in varchar2 default 'OPERATION',  --'
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.SYNC_CDC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_CDC',
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2')
  ) from DUAL;
*/
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OPERATION_COL in varchar2 default 'OPERATION',  --'
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
/*
Example:
  select COMPARE_SYNC.SYNC_CDC_SQL(
    P_OLD_OWNER => user,
    P_OLD_TABLE => 'T_TARGET',
    P_NEW_SOURCE => 'T_CDC',
    P_TAB_COLS => SYS.ODCIVARCHAR2LIST('C1','C2','C3', '"c4"'),
    P_KEY_COLS => SYS.ODCIVARCHAR2LIST('C1','C2'),
    P_OPERATION_COL => 'OPCODE'
  ) from DUAL;
*/
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OPERATION_COL in varchar2 default 'OPERATION',  --'
    P_OLD_DBLINK in varchar2 default null
  ) return clob;
 
end COMPARE_SYNC;
/
 

create or replace package body COMPARE_SYNC as
 
  G_DOLOG CONSTANT BOOLEAN := false;
 
  type T_REPL is RECORD(
    OLD_OWNER_TABLE varchar2(255),
    NEW_SOURCE varchar2(4000),
    FIRST_COL USER_TABLES.TABLE_NAME%type,
    ALL_COLS2 clob,
    ALL_COLS4 clob,
    ALL_COLS6 clob,
    INSERT_COLS2 clob,
    PK_COLS6 clob,
    ON_COLS2 clob,
    SET_COLS2 clob,
    DECODE_COLS2 clob,
    OPERATION_COL USER_TABLES.TABLE_NAME%type
  );
 
  procedure LOGGER(P_TXT in clob) is
  begin
    if G_DOLOG then
      DBMS_OUTPUT.PUT_LINE('prompt > ' || P_TXT);
    end if;
  end LOGGER;
 
  /*
  Format input array into CLOB with configurable maximum line length
  and configurable indentation. Indent all lines including the first.
  Start the result on a new line in the first column.
  Pattern is simplified printf: each occurence of '%s' is replaced by the array element.
  */
  function STRINGAGG(
    PT_COLS in SYS.ODCIVARCHAR2LIST,
    P_INDENTLEN in integer default 4,
    P_PATTERN in varchar2 default '%s',
    P_SEPARATOR in varchar2 default ',',
    P_LINEMAXLEN in number default 80
  ) return clob is
    C_NEWLINE varchar2(2) := '
';
    L_CLOB clob := RPAD(' ', P_INDENTLEN, ' ');
    L_NEW varchar2(128);
    L_LINELEN number := P_INDENTLEN;
  begin
    for I in 1..PT_COLS.COUNT LOOP
      L_NEW := case when I > 1 then ' ' end
        || replace(P_PATTERN, '%s', PT_COLS(I))
        || case when I < PT_COLS.COUNT then P_SEPARATOR end;
      if L_LINELEN + length(L_NEW) > P_LINEMAXLEN then
        L_CLOB := L_CLOB || C_NEWLINE || RPAD(' ', P_INDENTLEN, ' ');
        L_LINELEN := P_INDENTLEN;
        L_NEW := SUBSTR(L_NEW,2);
      end if;
      L_CLOB := L_CLOB || L_NEW;
      L_LINELEN := L_LINELEN + length(L_NEW);
    end LOOP;
    return L_CLOB;
  end STRINGAGG;
 
  procedure MAKE_REPLACEMENTS(
    P_REPL in OUT NOCOPY T_REPL,
    P_OLD_OWNER in varchar2,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2,
    P_OPERATION_COL in varchar2 default null
  ) is
    L_NON_KEY_COLS SYS.ODCIVARCHAR2LIST;
  begin
    LOGGER('MAKE_REPLACEMENTS');
    P_REPL := null;
    if P_OLD_OWNER is null then
      P_REPL.OLD_OWNER_TABLE := P_OLD_TABLE || P_OLD_DBLINK;
    else
      P_REPL.OLD_OWNER_TABLE := P_OLD_OWNER || '.' || P_OLD_TABLE || P_OLD_DBLINK;
    end if;
    if P_NEW_SOURCE is null then
      RAISE_APPLICATION_ERROR(
        -20001,
        'P_NEW_SOURCE is null. Must be table, view or query within parentheses.'
      );
    else
      P_REPL.NEW_SOURCE := P_NEW_SOURCE;
    end if;
    if P_TAB_COLS is null or P_TAB_COLS.COUNT = 0 then
      RAISE_APPLICATION_ERROR(
        -20002,
        'P_TAB_COLS is null or is an empty collection.'
      );
    else
      P_REPL.FIRST_COL := P_TAB_COLS(1);
      P_REPL.ALL_COLS2 := STRINGAGG(P_TAB_COLS,2);
      P_REPL.ALL_COLS4 := STRINGAGG(P_TAB_COLS,4);
      P_REPL.ALL_COLS6 := STRINGAGG(P_TAB_COLS,6);
      P_REPL.INSERT_COLS2 := STRINGAGG(P_TAB_COLS, 2, 'N.%s');
    end if;
    if P_KEY_COLS is not null and P_KEY_COLS.COUNT > 0 then
      P_REPL.PK_COLS6 := STRINGAGG(P_KEY_COLS, 6);
      P_REPL.ON_COLS2 := STRINGAGG(P_KEY_COLS, 2, 'O.%s=N.%s', ' and ');
      select column_value bulk collect into L_NON_KEY_COLS
      from table(P_TAB_COLS)
      where replace(column_value,'"','') not in (
        select replace(column_value,'"','') from table(P_KEY_COLS)
      );
      if L_NON_KEY_COLS.COUNT between 1 and P_TAB_COLS.COUNT - 1 then
        P_REPL.SET_COLS2 := STRINGAGG(L_NON_KEY_COLS, 2, '%s=N.%s');
        P_REPL.DECODE_COLS2 := STRINGAGG(L_NON_KEY_COLS, 2, 'decode(O.%s,N.%s,0,1)');
      end if;
    end if;
    P_REPL.OPERATION_COL := P_OPERATION_COL;
  end MAKE_REPLACEMENTS;
 
  procedure OLD_OWNER_CHECK(
    P_OLD_OWNER in varchar2,
    P_OLD_DBLINK in varchar2
  ) is
    L_CNT number;
    L_SQL varchar2(255) :=
q'!select COUNT(*) from ALL_USERS#DBLINK# where USERNAME = '#OLD_OWNER#'!';
  begin
    LOGGER('old_owner_check');
    if P_OLD_OWNER is not null then
      L_SQL := replace(L_SQL, '#DBLINK#', P_OLD_DBLINK);
      L_SQL := replace(L_SQL, '#OLD_OWNER#', NVL(P_OLD_OWNER, user));
      LOGGER(L_SQL);
      execute immediate L_SQL into L_CNT;
      if L_CNT = 0 then
        RAISE_APPLICATION_ERROR(
          -20003,
          'P_OLD_OWNER = ' ||P_OLD_OWNER|| ': user not found in the database.'
        );
      end if;
    end if;
  end OLD_OWNER_CHECK;
 
  function GET_TAB_COLS(
    P_OLD_OWNER in varchar2,
    P_OLD_TABLE in varchar2,
    P_OLD_DBLINK in varchar2
  ) return SYS.ODCIVARCHAR2LIST is
    l_version number;
    l_instance_sql varchar2(255) := 
q'!select to_number(regexp_substr(banner, 'Release ([^|.]+)', 1, 1, 'i', 1))
from v$version#DBLINK#
where rownum = 1!';
    L_TAB_COLS SYS.ODCIVARCHAR2LIST;
    L_SQL varchar2(255) := 
q'!select '"'||COLUMN_NAME||'"'
from ALL_TAB_COLS#DBLINK#
where (OWNER, TABLE_NAME, VIRTUAL_COLUMN) =
(('#OLD_OWNER#', '#OLD_TABLE#', 'NO'))
and #VERSION_DEPENDENT#
order by SEGMENT_COLUMN_ID!';
  begin
    LOGGER('get_tab_cols');
    OLD_OWNER_CHECK(P_OLD_OWNER, P_OLD_DBLINK);
    l_instance_sql := replace(l_instance_sql, '#DBLINK#', P_OLD_DBLINK);
    LOGGER(l_instance_sql);
    execute immediate l_instance_sql into l_version;
    logger('l_version = ' || l_version);
    if l_version >= 12 then
      L_SQL := replace(L_SQL, '#VERSION_DEPENDENT#', 'USER_GENERATED = ''YES''');
    else
      L_SQL := replace(L_SQL, '#VERSION_DEPENDENT#', 'HIDDEN_COLUMN = ''NO''');
    end if;
    L_SQL := replace(L_SQL, '#DBLINK#', P_OLD_DBLINK);
    L_SQL := replace(L_SQL, '#OLD_OWNER#', NVL(P_OLD_OWNER, user));
    L_SQL := replace(L_SQL, '#OLD_TABLE#', P_OLD_TABLE);
    LOGGER(L_SQL);
    execute immediate L_SQL bulk collect into L_TAB_COLS;
    if L_TAB_COLS.COUNT = 0 then
      RAISE_APPLICATION_ERROR(
        -20004,
        NVL(P_OLD_OWNER, user) || '.' ||P_OLD_TABLE || ': table not found.'
      );
    end if;
    return L_TAB_COLS;
  end GET_TAB_COLS;
   
  function PREFIX_DBLINK( P_OLD_DBLINK in varchar2) return varchar2 is
  begin
    if P_OLD_DBLINK is null or SUBSTR(P_OLD_DBLINK,1,1) = '@' then
      return P_OLD_DBLINK;
    else
      return '@' || P_OLD_DBLINK;
    end if;
  end PREFIX_DBLINK;
 
  function GET_KEY_COLS(
    P_OLD_OWNER in varchar2,
    P_OLD_TABLE in varchar2,
    P_OLD_DBLINK in varchar2
  ) return SYS.ODCIVARCHAR2LIST is
    L_KEY_COLS SYS.ODCIVARCHAR2LIST;
    L_SQL varchar2(4000) := 
q'!select '"'||COLUMN_NAME||'"'
from ALL_CONS_COLUMNS#DBLINK#
where (OWNER, CONSTRAINT_NAME) = (
  select OWNER, CONSTRAINT_NAME from ALL_CONSTRAINTS#DBLINK#
  where (OWNER, TABLE_NAME, CONSTRAINT_TYPE) =
        (('#OLD_OWNER#', '#OLD_TABLE#', 'P'))
)!';
  begin
    LOGGER('get_key_cols');
    OLD_OWNER_CHECK(P_OLD_OWNER, P_OLD_DBLINK);
    L_SQL := replace(L_SQL, '#DBLINK#', P_OLD_DBLINK);
    L_SQL := replace(L_SQL, '#OLD_OWNER#', NVL(P_OLD_OWNER, user));
    L_SQL := replace(L_SQL, '#OLD_TABLE#', P_OLD_TABLE);
    LOGGER(L_SQL);
    execute immediate L_SQL bulk collect into L_KEY_COLS;
    return L_KEY_COLS;
  end GET_KEY_COLS;
 
  function COMPARE_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_REPL T_REPL;
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('compare_sql with tab_cols');
    MAKE_REPLACEMENTS(
      L_REPL,
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      P_TAB_COLS,
      SYS.ODCIVARCHAR2LIST(),
      L_OLD_DBLINK
    );
    return to_clob('select
')||L_REPL.ALL_COLS2||',
sum(OLD_CNT) OLD_CNT, sum(NEW_CNT) NEW_CNT
FROM (
  select
'||L_REPL.ALL_COLS2||',
  1 OLD_CNT, 0 NEW_CNT
  from '||L_REPL.OLD_OWNER_TABLE||' O
  union all
  select
'||L_REPL.ALL_COLS2||',
  0 OLD_CNT, 1 NEW_CNT
  from '||L_REPL.NEW_SOURCE||' N
)
group by
'||L_REPL.ALL_COLS2||'
having sum(OLD_CNT) != sum(NEW_CNT)
order by 1, NEW_CNT';
  end COMPARE_SQL;
 
  function COMPARE_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('compare_sql without tab_cols');
    return COMPARE_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      L_OLD_DBLINK
    );
  end COMPARE_SQL;
 
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
   
    L_REPL T_REPL;
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
 
  begin
    LOGGER('sync_sql with tab_cols');
    MAKE_REPLACEMENTS(
      L_REPL,
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      P_TAB_COLS,
      P_KEY_COLS,
      L_OLD_DBLINK
    );
    if L_REPL.SET_COLS2 is null then
      LOGGER('without set_cols');
      return to_clob('merge /*+ use_nl(O) */into ')||L_REPL.OLD_OWNER_TABLE||' O
using (
  select * from (
    select
    SUM(Z##FLAG) over(partition by
'||L_REPL.ALL_COLS6||'
    ) Z##NUM_ROWS,
    COUNT(NULLIF(Z##FLAG,-1)) over(partition by
'||L_REPL.ALL_COLS6||'
      order by null rows unbounded preceding
    ) Z##NEW,
    COUNT(NULLIF(Z##FLAG,1)) over(partition by
'||L_REPL.ALL_COLS6||'
      order by null rows unbounded preceding
    ) Z##OLD,
    a.* from (
      select
'||L_REPL.ALL_COLS6||',
      -1 Z##FLAG, rowid Z##RID
      from '||L_REPL.OLD_OWNER_TABLE||' O
      union all
      select
'||L_REPL.ALL_COLS6||',
      1 Z##FLAG, null
      from '||L_REPL.NEW_SOURCE||' N
    ) a
  )
  where Z##NUM_ROWS != 0
  and SIGN(Z##NUM_ROWS) = Z##FLAG
  and ABS(Z##NUM_ROWS) >=
    case SIGN(Z##NUM_ROWS) when 1 then Z##NEW else Z##OLD end
) N
on (O.rowid = N.Z##RID)
when matched then update set '||L_REPL.FIRST_COL||' = N.'||L_REPL.FIRST_COL||'
delete where 1=1
when not matched then insert (
'||L_REPL.ALL_COLS2||'
) values(
'||L_REPL.INSERT_COLS2||'
)';
    else
      LOGGER('with set_cols');
      return to_clob('merge into ')||L_REPL.OLD_OWNER_TABLE||' O
using (
  select * from (
    select
'||L_REPL.ALL_COLS4||',
    COUNT(*) over(partition by
'||L_REPL.PK_COLS6||'
    )
    - SUM(Z##_CNT) Z##IUD_FLAG
    from (
      select
'||L_REPL.ALL_COLS6||',
      -1 Z##_CNT
      from '||L_REPL.OLD_OWNER_TABLE||' O
      union all
      select
'||L_REPL.ALL_COLS6||',
      1 Z##_CNT
      from '||L_REPL.NEW_SOURCE||' N
    )
    group by
'||L_REPL.ALL_COLS4||'
    having SUM(Z##_CNT) != 0
  )
  where Z##IUD_FLAG < 3
) N
on (
'||L_REPL.ON_COLS2||'
)
when matched then update set
'||L_REPL.SET_COLS2||'
  delete where N.Z##IUD_FLAG = 2
when not matched then insert (
'||L_REPL.ALL_COLS2||'
) values(
'||L_REPL.INSERT_COLS2||'
)';
    end if;
  end SYNC_SQL;
 
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_sql without key_cols');
    return SYNC_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      GET_KEY_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      L_OLD_DBLINK
    );
  end SYNC_SQL;
 
  function SYNC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_sql with key_cols');
    return SYNC_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      P_KEY_COLS,
      L_OLD_DBLINK
    );
  end SYNC_SQL;
 
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
 
    L_REPL T_REPL;
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
 
  begin
    LOGGER('sync_upsert_sql with tab_cols');
    MAKE_REPLACEMENTS(
      L_REPL,
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      P_TAB_COLS,
      P_KEY_COLS,
      L_OLD_DBLINK
    );
    if L_REPL.SET_COLS2 is null then
      RAISE_APPLICATION_ERROR(
        -20005,
        'SYNC_UPSERT_SQL requires a target with both primary and non-key columns'
      );
    end if;
    return to_clob('merge into (
  select
')||L_REPL.ALL_COLS2||'
  from '||L_REPL.OLD_OWNER_TABLE||'
) O
using (
  select
'||L_REPL.ALL_COLS2||'
  from '||L_REPL.NEW_SOURCE||'
) N
on (
'||L_REPL.ON_COLS2||'
)
when matched then update set
'||L_REPL.SET_COLS2||'
where 1 in (
'||L_REPL.DECODE_COLS2||'
)
when not matched then insert (
'||L_REPL.ALL_COLS2||'
) values(
'||L_REPL.INSERT_COLS2||'
)';
  end SYNC_UPSERT_SQL;
 
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_upsert_sql without key_cols');
    return SYNC_UPSERT_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      GET_KEY_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      L_OLD_DBLINK
    );
  end SYNC_UPSERT_SQL;
 
  function SYNC_UPSERT_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_upsert_sql with key_cols');
    return SYNC_UPSERT_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      P_KEY_COLS,
      L_OLD_DBLINK
    );
  end SYNC_UPSERT_SQL;
 
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_TAB_COLS in SYS.ODCIVARCHAR2LIST,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OPERATION_COL in varchar2 default 'OPERATION',
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
 
    L_REPL T_REPL;
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
 
  begin
    LOGGER('sync_cdc_sql with tab_cols');
    LOGGER('P_OPERATION_COL = ' || P_OPERATION_COL);
    if P_OPERATION_COL is null then
      RAISE_APPLICATION_ERROR(
        -20006,
        'P_OPERATION_COL is null. Must be valid column in source data.'
      );
    end if;
    MAKE_REPLACEMENTS(
      L_REPL,
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      P_TAB_COLS,
      P_KEY_COLS,
      L_OLD_DBLINK,
      P_OPERATION_COL
    );
    if L_REPL.SET_COLS2 is null then
      RAISE_APPLICATION_ERROR(
        -20007,
        'SYNC_CDC_SQL requires a target with both primary and non-key columns'
      );
    end if;
    return to_clob('merge into (
  select
')||L_REPL.ALL_COLS2||'
  from '||L_REPL.OLD_OWNER_TABLE||'
) O
using (
  select '||L_REPL.OPERATION_COL||',
'||L_REPL.ALL_COLS2||'
  from '||L_REPL.NEW_SOURCE||'
) N
on (
'||L_REPL.ON_COLS2||'
)
when matched then update set
'||L_REPL.SET_COLS2||'
where N.'||L_REPL.OPERATION_COL||' = ''D'' or 1 in (
'||L_REPL.DECODE_COLS2||'
)
delete where N.'||L_REPL.OPERATION_COL||' = ''D''
when not matched then insert (
'||L_REPL.ALL_COLS2||'
) values(
'||L_REPL.INSERT_COLS2||'
) where N.'||L_REPL.OPERATION_COL||' != ''D''';
  end SYNC_CDC_SQL;
 
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_KEY_COLS in SYS.ODCIVARCHAR2LIST,
    P_OPERATION_COL in varchar2 default 'OPERATION',
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_cdc_sql with key_cols');
    return SYNC_CDC_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      P_KEY_COLS,
      P_OPERATION_COL,
      L_OLD_DBLINK
    );
  end SYNC_CDC_SQL;
 
  function SYNC_CDC_SQL(
    P_OLD_OWNER in varchar2 default null,
    P_OLD_TABLE in varchar2,
    P_NEW_SOURCE in varchar2,
    P_OPERATION_COL in varchar2 default 'OPERATION',
    P_OLD_DBLINK in varchar2 default null
  ) return clob is
    L_OLD_DBLINK varchar2(255) := PREFIX_DBLINK(P_OLD_DBLINK);
  begin
    LOGGER('sync_cdc_sql without key_cols');
    return SYNC_CDC_SQL(
      P_OLD_OWNER,
      P_OLD_TABLE,
      P_NEW_SOURCE,
      GET_TAB_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      GET_KEY_COLS(P_OLD_OWNER, P_OLD_TABLE, L_OLD_DBLINK),
      P_OPERATION_COL,
      L_OLD_DBLINK
    );
  end SYNC_CDC_SQL;
 
end COMPARE_SYNC;
/

/*
1. shouldn’t the line 200 read: “select OWNER, CONSTRAINT_NAME from ALL_CONSTRAINTS#DBLINK#”?
2. in many cases v$instance might not be available to the destination table’s owner’s schema. Maybe it’s better to use conditional compilation in this case, as in:
”
$IF DBMS_DB_VERSION.VER_LE_10 $THEN
L_SQL := replace(L_SQL, ‘#VERSION_DEPENDENT#’, ‘HIDDEN_COLUMN = ”NO”’);
$ELSIF DBMS_DB_VERSION.VER_LE_11 $THEN
L_SQL := replace(L_SQL, ‘#VERSION_DEPENDENT#’, ‘HIDDEN_COLUMN = ”NO”’);
$ELSE
L_SQL := replace(L_SQL, ‘#VERSION_DEPENDENT#’, ‘USER_GENERATED = ”YES”’);
$END
”
*/

/*
Example using SCOTT.EMP: 

select compare_sync.compare_sql('SCOTT', 'EMP', 'SCOTT.EMP') from dual;

select
  "EMPNO", "ENAME", "JOB", "MGR", "HIREDATE", "SAL", "COMM", "DEPTNO",
sum(OLD_CNT) OLD_CNT, sum(NEW_CNT) NEW_CNT
FROM (
  select
  "EMPNO", "ENAME", "JOB", "MGR", "HIREDATE", "SAL", "COMM", "DEPTNO",
  1 OLD_CNT, 0 NEW_CNT
  from SCOTT.EMP O
  union all
  select
  "EMPNO", "ENAME", "JOB", "MGR", "HIREDATE", "SAL", "COMM", "DEPTNO",
  0 OLD_CNT, 1 NEW_CNT
  from SCOTT.EMP N
)
group by
  "EMPNO", "ENAME", "JOB", "MGR", "HIREDATE", "SAL", "COMM", "DEPTNO"
having sum(OLD_CNT) != sum(NEW_CNT)
order by 1, NEW_CNT;
To generate the SQL queries for every table in a schema:
select compare_sync.compare_sql('SCOTT', table_name, 'SCOTT.'||table_name)
from all_tables where owner = 'SCOTT';
*/