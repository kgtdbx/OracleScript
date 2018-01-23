Create a SQL Profile to let the Optimizer ignore hints in #Oracle

Something I presented recently during an Oracle Database 12c Performance Management and Tuning class. Hints are a double-edged sword; they may do more harm than good. What if  hinted SQL comes from an application that you as the DBA in charge can’t modify? You can tell the Optimizer to ignore that nasty hint.

One method is to use alter session set “_optimizer_ignore_hints”=true; This will make the optimizer ignore all hints during that session  – also the useful ones, so maybe that is not desirable. The method I show here works on the statement level. The playground:

SQL> select /*+ index (sales,sales_bix) */ max(amount_sold) from sales where channel_id=3;

MAX(AMOUNT_SOLD)
----------------
         1782.72

Elapsed: 00:00:04.92
SQL> select plan_table_output from table(dbms_xplan.display_cursor);

PLAN_TABLE_OUTPUT
--------------------------------------
SQL_ID  7m2k0y4hy1ngh, child number 0
--------------------------------------
select /*+ index (sales,sales_bix) */ max(amount_sold) from sales where channel_id=3

Plan hash value: 1767991108

--------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |           |       |       |   139K(100)|          |

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------
|   1 |  SORT AGGREGATE                      |           |     1 |     8 |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID BATCHED| SALES     |    17M|   131M|   139K  (1)| 00:00:06 |
|   3 |    BITMAP CONVERSION TO ROWIDS       |           |       |       |            |          |
|*  4 |     BITMAP INDEX SINGLE VALUE        | SALES_BIX |       |       |            |          |
--------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("CHANNEL_ID"=3)
The index hint directs the optimizer here to use a bad plan that wouldn’t be used otherwise:

SQL> select max(amount_sold) from sales where channel_id=3;

MAX(AMOUNT_SOLD)
----------------
         1782.72

Elapsed: 00:00:01.06
SQL> select plan_table_output from table(dbms_xplan.display_cursor);

PLAN_TABLE_OUTPUT
--------------------------------------
SQL_ID  ahw4npmjpnu1k, child number 0
--------------------------------------
select max(amount_sold) from sales where channel_id=3

Plan hash value: 1047182207

----------------------------------------------------------------------------
| Id  | Operation          | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |       |       | 28396 (100)|          |
|   1 |  SORT AGGREGATE    |       |     1 |     8 |            |          |

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------
|*  2 |   TABLE ACCESS FULL| SALES |    17M|   131M| 28396   (1)| 00:00:02 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CHANNEL_ID"=3)
Now the remedy:

begin
 dbms_sqltune.import_sql_profile(
 name => 'MYPROFILE1',
 category => 'DEFAULT',
 sql_text => 'select /*+ index (sales,sales_bix) */ max(amount_sold) from sales where channel_id=3',
 profile => sqlprof_attr('IGNORE_OPTIM_EMBEDDED_HINTS')
                                 );
end;
/

PL/SQL procedure successfully completed.

SQL> select /*+ index (sales,sales_bix) */ max(amount_sold) from sales where channel_id=3;

MAX(AMOUNT_SOLD)
----------------
         1782.72

Elapsed: 00:00:01.05

SQL> select plan_table_output from table(dbms_xplan.display_cursor);

PLAN_TABLE_OUTPUT
-------------------------------------
SQL_ID  7m2k0y4hy1ngh, child number 0
-------------------------------------
select /*+ index (sales,sales_bix) */ max(amount_sold) from sales where channel_id=3

Plan hash value: 1047182207

----------------------------------------------------------------------------
| Id  | Operation          | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |       |       | 28396 (100)|          |

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------
|   1 |  SORT AGGREGATE    |       |     1 |     8 |            |          |
|*  2 |   TABLE ACCESS FULL| SALES |    17M|   131M| 28396   (1)| 00:00:02 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CHANNEL_ID"=3)

Note
-----

PLAN_TABLE_OUTPUT
----------------------------------------------------
   - SQL profile MYPROFILE1 used for this statement
This works for that SQL statement only without having to modify the application. The SQL profile can be removed like this:

SQL> exec dbms_sqltune.drop_sql_profile('MYPROFILE1')
PL/SQL procedure successfully completed.
All the above is not new, but still I think it might be worthwhile to mention it here for your reference, should you encounter some nasty hints once ??




inShare
127Email

Share on Tumblr
Save


Related
Exadata Part I: Smart Scan
In "TOI"
Restoring old Optimizer Statistics for troubleshooting purpose
In "TOI"
Index Competition in #Oracle 12c
In "TOI"
optimizer, Performance Tuning
This entry was posted on July 7, 2016, 10:36 and is filed under TOI. You can follow any responses to this entry through RSS 2.0. You can leave a response, or trackback from your own site.

COMMENTS (3)

#1 by Hanno Ernst on July 7, 2016 - 13:25
Hi Uwe,
that’s correct, but dbms_sqltune is under licence of the tuning pack. A better capability do get this behavior is a sql patch. Sql Patch is a part of Oracle Enterprise Edition and no additional licence is needed.

Here a short example that should do the same than your’s. Maybe you can give it a try,

DECLARE
clsql_text CLOB;
BEGIN
SELECT sql_fulltext INTO clsql_text FROM V$sql where sql_id = ‘7m2k0y4hy1ngh’ and rownum clsql_text,
hint_text => q'[IGNORE_OPTIM_EMBEDDED_HINTS]’,
name => ‘MY_SQL_PATCH’);
end;
/

…

exec DBMS_SQLDIAG.DROP_SQL_PATCH(‘MY_SQL_PATCH’);

brdgs
Hanno


#2 by Aníbal Gattás on July 7, 2016 - 13:34
Neat and clear. Excellent post Uwe, thanks for sharing.


#3 by Hanno Ernst on July 7, 2016 - 17:20
inside the SELECT row there were something cutted.

I’ll try again. Hope now it works… (a “lower than” symbol beside the “=” was the problem)

DECLARE
clsql_text CLOB;
BEGIN
SELECT sql_fulltext INTO clsql_text FROM V$sql where sql_id = ‘7m2k0y4hy1ngh’ and rownum=1;
sys.dbms_sqldiag_internal.i_create_patch(sql_text => clsql_text,
hint_text => q'[IGNORE_OPTIM_EMBEDDED_HINTS]’,
name => ‘MY_SQL_PATCH’);
end;
/