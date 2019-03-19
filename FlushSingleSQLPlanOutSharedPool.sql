
--#######################--
--https://blog.dbi-services.com/a-migration-pitfall-with-all-column-size-auto/
/*
The statistics gathering was run with the default option – rolling invalidation. Which means that my bad execution plans – with full table scan – are still used. 
Because I don’t want too many hard parses at the same time, I invalidate only the plans that I’ve identified as causing a problem to users:
*/
exec for c in (select address,hash_value,users_executing,sql_text from v$sqlarea where sql_id='cbr6yy2vwr6s0') loop sys.dbms_shared_pool.purge(c.address||','||c.hash_value,'...'); end loop;
 
--#######################--

Todays let‘s have look at the query which we use to resolve this issue ” How to Flush Single SQL Plan out of Shared Pool”. 

Find the address and the hash value

SQL> select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID='495fdyn7cd34r';

ADDRESS          HASH_VALUE
---------------- ----------
00000005ODJD9BC0 247122679

SQL> select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID='495fdyn7cd34r';
 
ADDRESS          HASH_VALUE
---------------- ----------
00000005ODJD9BC0 247122679


Execute the purge procedure
SQL> exec DBMS_SHARED_POOL.PURGE ('00000005ODJD9BC0,247122679','C');

PL/SQL procedure successfully completed.

SQL> exec DBMS_SHARED_POOL.PURGE ('00000005ODJD9BC0,247122679','C');
 
PL/SQL procedure successfully completed.


----------------
https://blog.dbi-services.com/flush-one-sql-statement-to-hard-parse-it-again/

Flush one SQL statement to hard parse it again
By Oracle TeamJanuary 29, 2015Database management, Oracle4 Comments
.
If you want a statement to be hard parsed on its next execution, you can flush the shared pool, but you don’t want all the cursors to be hard parsed. Here is how to flush only one statement, illustrated with the case where it can be useful.
During the performance training, here is how I introduce Adaptive Cursor Sharing, here is how I show the bind variable peeking problem that is well known by everyone that was DBA at the times of 9iR2 upgrades.

I’ve a customer table with very few ones born before 30’s and lot of ones born in 70’s. Optimal plan is index access for those from 1913 and full table scan for those born in 1971.

I’ve an histogram on that column so the optimizer can choose the optimal plan, whatever the value is. But I’m a good developer and I’m using bind variables in order to avoid to parse and waste shared pool memory for each value.

Here is my first user that executes the query for the value 1913

SQL> execute :YEAR:=1913;
PL/SQL procedure successfully completed.
 
SQL> select cust_gender,count(*) from CUSTOMERS where cust_year_of_birth=:YEAR group by cust_gender;
 
C   COUNT(*)
- ----------
M          4
F          1
Here is the execution plan:


SQL> select * from table(dbms_xplan.display_cursor(format=>'iostats last +peeked_binds'));
 
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------------------
SQL_ID  dpxj8c5y81bdr, child number 0
-------------------------------------
select cust_gender,count(*) from CUSTOMERS where
cust_year_of_birth=:YEAR group by cust_gender
 
Plan hash value: 790974867
 
------------------------------- ------------ --------------------------------------
| Id  | Operation               | Name       | Starts | E-Rows | A-Rows | Buffers |
------------------------------- ------------ --------------------------------------
|   0 | SELECT STATEMENT        |            |      1 |        |      2 |       7 |
|   1 |  HASH GROUP BY          |            |      1 |      2 |      2 |       7 |
|   2 |   TABLE ACCESS BY INDEX | CUSTOMERS  |      1 |      5 |      5 |       7 |
|*  3 |    INDEX RANGE SCAN     | DEMO_CUST_ |      1 |      5 |      5 |       2 |
------------------------------- ------------ --------------------------------------
And thanks to the ‘+peeked_binds’ I know that it has been optimized for 1913


Peeked Binds (identified by position):
--------------------------------------
   1 - :1 (NUMBER): 1913
 
Predicate Information (identified by operation id):
---------------------------------------------------
   3 - access("CUST_YEAR_OF_BIRTH"=:YEAR)
I’ve the right plan, optimal for my value.

But I’ve used bind variables in order to share my cursor. Others will execute the same with other values. They will soft parse only and share my cursor. Look at it:

SQL> execute :YEAR:=1971;
PL/SQL procedure successfully completed.
 
SQL> select cust_gender,count(*) from CUSTOMERS where cust_year_of_birth=:YEAR group by cust_gender;
 
C   COUNT(*)
- ----------
M        613
F        312
Look at the plan, it’s the same:


SQL> select * from table(dbms_xplan.display_cursor(format=>'iostats last +peeked_binds'));
 
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------
SQL_ID  dpxj8c5y81bdr, child number 0
-------------------------------------
select cust_gender,count(*) from CUSTOMERS where
cust_year_of_birth=:YEAR group by cust_gender
 
Plan hash value: 790974867
 
------------------------------- --------------- --------------------------------------
| Id  | Operation               | Name          | Starts | E-Rows | A-Rows | Buffers |
------------------------------- --------------- --------------------------------------
|   0 | SELECT STATEMENT        |               |      1 |        |      2 |     228 |
|   1 |  HASH GROUP BY          |               |      1 |      2 |      2 |     228 |
|   2 |   TABLE ACCESS BY INDEX | CUSTOMERS     |      1 |      5 |    925 |     228 |
|*  3 |    INDEX RANGE SCAN     | DEMO_CUST_YEA |      1 |      5 |    925 |       4 |
------------------------------- --------------- --------------------------------------
 
Peeked Binds (identified by position):
--------------------------------------
   1 - :1 (NUMBER): 1913
 
Predicate Information (identified by operation id):
---------------------------------------------------
   3 - access("CUST_YEAR_OF_BIRTH"=:YEAR)
The plan is optimized for 1913, estimating 5 rows (E-Rows) but now returning 925 rows (A-Rows). That may be bad. Imagine a nested loop planned for few rows but finally running on million of rows…

The goal of this post is not to show Adaptive Cursor Sharing that may solve the issue once the problem has occured. And Adaptive Cursor Sharing do not work in all contexts (see Bug 8357294: ADAPTIVE CURSOR SHARING DOESN’T WORK FOR STATIC SQL CURSORS FROM PL/SQL)

The goal is to answer to a question I had during the workshop: Can we flush one cursor in order to have it hard parsed again ? It’s a good question and It’s a good idea to avoid to flush the whole shared pool!

This is not new (see here, here, here, here, here,…). But here is the query I use to quickly flush a statement with its sql_id.

I have the following cursor in memory:

SQL> select child_number,address,hash_value,last_load_time from v$sql where sql_id='dpxj8c5y81bdr';
 
CHILD_NUMBER ADDRESS          HASH_VALUE LAST_LOAD_TIME
------------ ---------------- ---------- -------------------
           0 00000000862A0E08 2088807863 2015-01-29/14:56:46
and I flush it with dbms_shared_pool.purge:


SQL> exec for c in (select address,hash_value,users_executing,sql_text from v$sqlarea where sql_id='dpxj8c5y81bdr') loop sys.dbms_shared_pool.purge(c.address||','||c.hash_value,'...'); end loop;
 
PL/SQL procedure successfully completed.
I’ve 3 remarks about it:

1. If the cursor is currently running, the procedure will wait (updated JUL-17 it seems that in current version it doesn’t wait and just don’t flush).
2. In 10g you have to set the following event for your session:

1
alter session set events '5614566 trace name context forever';
 
3. The ‘…’ is anything you want which is not a P,Q,R,T which are used for Procedures, seQences, tRigger, Type. Anything else is for cursors. Don’t worry, this is in the doc.

Ok, the cursor is not there anymore:

SQL> select child_number,address,hash_value,last_load_time from v$sql where sql_id='dpxj8c5y81bdr';
no rows selected
And the next execution will optimize it for its peeked bind value:

SQL> execute :YEAR:=1971;
PL/SQL procedure successfully completed.
 
SQL> select cust_gender,count(*) from CUSTOMERS where cust_year_of_birth=:YEAR group by cust_gender;
 
C   COUNT(*)
- ----------
M          4
F          1
 
SQL> select * from table(dbms_xplan.display_cursor(format=>'iostats last +peeked_binds'));
 
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------
SQL_ID  dpxj8c5y81bdr, child number 0
-------------------------------------
select cust_gender,count(*) from CUSTOMERS where
cust_year_of_birth=:YEAR group by cust_gender
 
Plan hash value: 1577413243
 
-----------------------------------------------------------------------------
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows | Buffers |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      2 |     233 |
|   1 |  HASH GROUP BY     |           |      1 |      2 |      2 |     233 |
|*  2 |   TABLE ACCESS FULL| CUSTOMERS |      1 |    925 |      5 |     233 |
-----------------------------------------------------------------------------
 
Peeked Binds (identified by position):
--------------------------------------
   1 - :1 (NUMBER): 1971
 
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - filter("CUST_YEAR_OF_BIRTH"=:YEAR)
Here is the cursor that have been re-loaded, re-parsed, and re-optimized:


SQL> select child_number,address,hash_value,last_load_time from v$sql where sql_id='dpxj8c5y81bdr';
 
CHILD_NUMBER ADDRESS          HASH_VALUE LAST_LOAD_TIME
------------ ---------------- ---------- -------------------
           0 00000000862A0E08 2088807863 2015-01-29/14:56:49
That’s the right plan. A full table scan when I want to read lot of rows.

Don’t take it wrong. This is not a solution. It’s just a quick fix when a plan has gone wrong because the first execution was done by a special value. We flush the plan and expect that the following execution is done with a regular value.
You probably have the sql_id as you have seen a long running query with a bad plan. Here is the way to flush all its children – ready to copy/paste in case of emergency:


set serveroutput on
begin
 for c in (select address,hash_value,users_executing,sql_text from v$sqlarea where sql_id='&sql_id') 
 loop 
  dbms_output.put_line(c.users_executing||' users executing '||c.sql_text);
  sys.dbms_shared_pool.purge(c.address||','||c.hash_value,'...'); 
  dbms_output.put_line('flushed.');
 end loop;
end;
/

