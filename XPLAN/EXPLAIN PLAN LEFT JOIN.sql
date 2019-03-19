
set linesize 250 pagesize 0 trims on tab off long 1000000
set timing on
set autotrace traceonly explain


/*
--http://www.dba-oracle.com/plsql/t_plsql_plans.htm

utlxpls.sql

Prior to Oracle 9i Release 2, the utlxpls.sql script or the utlxplp.sql script for parallel queries was used to query the plan_table and display execution plan.  The example below shows the expected output from the script.

SQL> EXPLAIN PLAN FOR
  2  SELECT *
  3  FROM   emp e, dept d
  4  WHERE  e.deptno = d.deptno
  5  AND    e.ename  = 'SMITH';

Explained.

SQL> @$ORACLE_HOME/rdbms/admin/utlxpls.sql

Plan Table
-------------------------------------------------------------------------------
| Operation                 |  Name   |  Rows | Bytes|  Cost  | Pstart| Pstop |
-------------------------------------------------------------------------------
| SELECT STATEMENT          |         |       |      |        |       |       |
|  NESTED LOOPS             |         |       |      |        |       |       |
|   TABLE ACCESS FULL       |EMP      |       |      |        |       |       |
|   TABLE ACCESS BY INDEX RO|DEPT     |       |      |        |       |       |
|    INDEX UNIQUE SCAN      |PK_DEPT  |       |      |        |       |       |
-------------------------------------------------------------------------------

8 rows selected.

SQL>

By default, the Oracle scripts do not accept a statement_id parameter, but they can be modified to create a personal script, like the explain.sql script shown below.

explain.sql

-- *****************************************************************
-- Parameters:
--   1) Statement ID
-- *****************************************************************

SET PAGESIZE 100
SET LINESIZE 200
SET VERIFY OFF

COLUMN plan             FORMAT A50
COLUMN object_name      FORMAT A30
COLUMN object_type      FORMAT A15
COLUMN bytes            FORMAT 9999999999
COLUMN cost             FORMAT 9999999
COLUMN partition_start  FORMAT A20
COLUMN partition_stop   FORMAT A20

SELECT LPAD(' ', 2 * (level - 1)) ||
       DECODE (level,1,NULL,level-1 || '.' || pt.position || ' ') ||
       INITCAP(pt.operation) ||
       DECODE(pt.options,NULL,'',' (' || INITCAP(pt.options) || ')') plan,
       pt.object_name,
       pt.object_type,
       pt.bytes,
       pt.cost,
       pt.partition_start,
       pt.partition_stop
FROM   plan_table pt
START WITH pt.id = 0
  AND pt.statement_id = '&1'
CONNECT BY PRIOR pt.id = pt.parent_id
  AND pt.statement_id = '&1';

The following example shows the output from the explain.sql script.

SQL> EXPLAIN PLAN SET STATEMENT_ID = 'TIM' FOR
  2  SELECT *
  3  FROM   emp e, dept d
  4  WHERE  e.deptno = d.deptno
  5  AND    e.ename  = 'SMITH';

Explained.

SQL> @explain.sql TIM

PLAN                                               OBJECT_NAME                    OBJECT_TYPE           BYTES     COST PARTITION_START      PARTITION_STOP
-------------------------------------------------- ------------------------------ --------------- ----------- ----Select Statement                                                                                           57        4

  1.1 Nested Loops                                                       
57        4
    2.1 Table Access (Full)                        EMP                            
TABLE                    37        3
    2.2 Table Access (By Index Rowid)              DEPT                           
TABLE                    20        1
      3.1 Index (Unique Scan)                      PK_DEPT                        
INDEX (UNIQUE)                     0

5 rows selected.

The utlxpls.sql script is still present in later versions of Oracle, but it now displays the execution plan using the dbms_xplan package.
*/




Basically there are no such limitations to the scenario.You always have to be greddy enough for it..I look basically for some things like
* Total number of row scan(You must be having estimate of table size)
*Whether its using any index or not.
*If its using index then which index its using.
*Which optimizer is being used for plan generation..
If you are using more than one table then ordering position of driving table and arranging sequence of conditions will show some good result in explain plan output..Don't forget to provide hint to optimiser in that case for RBO/CBO..
*In case optimiser is using Cost based , what is the cost involved for each process.

and the list goes on

Some basic do's and don't are
- avoid using data conversions in condition clause
- don't let oracle to convert data type implicitly..
-put conditions directly related to driving table first(In case you are giving hint as RULE)
-avoid using not null in condition clause.Use minus query instead.
- use inline views instead of co-related subquery.
- avoid joins as much as possible.

Cost - - This column is weighted sum of cpu cost and I/O cost..General trend is lower the cost , faster the query executes , but its not true..So this factor is not reliable from performance point of view.Example optimiser could not calculate accurate cost in case of missing metadata.[get rough idea BUT DO NOT TRUST IT] 

Cardinality -- This is estimation of number of rows that needs to be read in different step in plan.This plays role as you would get an idea of detailed distribution of row scan in query and hence you will get idea which part of query is incresing row scans. 

Bytes -- It is almost estimation in terms of memory..Number of rows doesnt gives idea about actual byte scan in a row..There could be 10 column in a row and there could be 90 also..but row will be 1 in both case.So Byte is more important property than cardinality for me.
 Dave A.
Dave
Dave A.
Founder, SkillBuilders.com, Senior Oracle DBA

EXPLAIN PLAN is a command. It generates the predicted execution plan. You cannot answer answer your question without embarking on learning how to read an execution plan (i.e. in what order is the plan executed) and learning what the steps in the plan mean. There are "red flags" to look for, yes. But you must learn. You asked not to post a link and I will of course honor that. But if you want a link to excellent, free, video tutorials, respond and I will post.

1) "how we come to know that query requires optimization on the basis of explain plan" 
you don't. you know that the query requires optimization because it doesn't run as fast as you would like. then you use the plan to see what it is doing, to help you decide how to change it. if you see it doing full table scans, maybe you need an index or maybe you have a function on the indexed column in the where clause which is suppressing the index. or maybe it means you forgot a join condition and query is slow because it is wrong. or maybe your stats are not current, and oracle thinks the million row table only has 5 rows. you don't start with the plan, you start with a stopwatch. 

2) 
like Himanshu said, don't get hung up on the cost - it's relative to itself, and meaningless for comparison. when oracle parses a sql, it contemplates multiple plans - should I use index A or B, should I do I nested loop or hash join, start with table X or Y, etc, etc. then each of these potential plans are given "cost", which is weighted against the costs of the other possible plans. 

now let's say you create a new index, and run the same query again. oracle builds a whole new set of possible plans, and the costs of these have no relation to the costs of the plans from the first run (before the new index was created), because the conditions have changed. so any change in the environment. 

next, instead of creating an index, you simply rewrite your query - you changed a "not in" subquery to a "not exists" correlated subquery. this is a different query than you had before (even though it achieves the same results), so the "cost" assigned to it is relative to all possible plans for THIS query, and is totally unrelated to the cost of the original query. 

so, the cost is only meaningful to a specific query, and cannot be compared across queries - for two different queries, a higher cost might be faster than a lower cost, simply because they are different queries, and the costs are not relative to each other.




explain plan for
  select a.id from t1 a, t2 b
   where a.id=b.id(+)
     and b.id is null;

select * from table(dbms_xplan.display);

explain plan for
  select a.id from t1 a, t2 b
   where a.id=b.id(+)
     and b.id is null;
SELECT * FROM TABLE(dbms_xplan.display(NULL,NULL,'ALL'));
--or
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY('plan_table',null,'basic +predicate +cost')); 
--or
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'basic')); 
--or
select plan_table_output from
table(dbms_xplan.display('plan_table',null,'typical -cost -bytes'));

--or

--Displaying the execution plan for any other statement requires the SQL ID to be provided, either directly or indirectly:

--Directly:

select plan_table_output from
table(dbms_xplan.display_cursor('fnrtqw9c233tt',null,'basic'));

--Indirectly:

select plan_table_output
from v$sql s,
table(dbms_xplan.display_cursor(s.sql_id,
                               s.child_number, 'basic')) t
where upper(s.sql_text) like 'SELECT A.ID%';

--

set linesize 250 pagesize 0 trims on tab off long 1000000
set timing on
select plan_table_output
from v$sql s,
table(dbms_xplan.display_cursor(s.sql_id,
                               s.child_number, 'ADVANCED +peeked_binds +projection')) t
where upper(s.sql_text) like 'SELECT /*+ GATHER_PLAN_STATISTICS */%';

--#########################--
Displaying an execution plan corresponding to a SQL Plan Baseline.

SQL> alter session set optimizer_capture_sql_plan_baselines=true;

Session altered.

SQL> select prod_category, avg(amount_sold)
 2   from sales s, products p
 3   where p.prod_id = s.prod_id
 4   group by prod_category;

no rows selected
If the above statement has been executed more than once, a SQL Plan Baseline will be created for it and you can verified this using the follows query:

SQL> select SQL_HANDLE, PLAN_NAME, ACCEPTED
 2   from dba_sql_plan_baselines
 3   where sql_text like 'select prod_category%';

SQL_HANDLE                     PLAN_NAME                      ACC
------------------------------ ------------------------------ ---
SYS_SQL_1899bb9331ed7772       SYS_SQL_PLAN_31ed7772f2c7a4c2  YES
The execution plan for the SQL Plan Baseline created above can be displayed either directly or indirectly:

Directly

select t.* from
table(dbms_xplan.display_sql_plan_baseline('SYS_SQL_1899bb9331ed7772',
                                           format => 'basic')) t
Indirectly

select t.*
    from (select distinct sql_handle
          from dba_sql_plan_baselines
          where sql_text like 'select prod_category%') pb,
         table(dbms_xplan.display_sql_plan_baseline(pb.sql_handle,
                                                    null,'basic')) t;

                                                    
                                                    
                                                    -----------dbms_xplan------------
DISPLAY
DISPLAY_CURSOR
DISPLAY_AWR
DISPLAY_SQL_PLAN_BASELINE
DISPLAY_SQL_SET


SELECT * FROM TABLE(dbms_xplan.display%());

DBMS_XPLAN.DISPLAY_CURSOR 
• SQL_ID 
• CURSOR_CHILD_NO (defaults to 0!) 
• FORMAT 
    – TYPICAL = DEFAULT 
    – ALL = TYPICAL + QB + PROJECTION + ALIAS + REMOTE 
    – ADVANCED = ALL + OUTLINE + BINDS 
    – ALLSTATS = IOSTATS + MEMSTATS (all executions) 
    – ALLSTATS LAST (last execution) 
    – ADAPTIVE (12c)
    
 

-------------------------------

How do I display and read the execution plans for a SQL statement
Mohamed Zait 
https://blogs.oracle.com/optimizer/how-do-i-display-and-read-the-execution-plans-for-a-sql-statement

Generating and displaying the execution plan of a SQL statement is a common task for most DBAs, SQL developers and performance experts as it provides them information on the performance characteristics of a SQL statement. An execution plan shows the detailed steps necessary to execute a SQL statement. These steps are expressed as a set of database operators that consumes and produces rows. The order of the operators and their implementation is decided by the query optimizer using a combination of query transformations and physical optimization techniques.

This post covers how you can use the PL/SQL package DBMS_XPLAN to display execution plan information. If you want to learn more about DBMS_XPLAN options, alternative methods for generating plans as well as HTML and graphical representations, then check out this post too.

While the display is commonly shown in a tabular format, the plan is in fact tree-shaped. For example, consider the following query based on the SH schema (Sales History):

select prod_category, avg(amount_sold)
from sales s, products p
where p.prod_id = s.prod_id
group by prod_category;
The tabular representation of this query's plan is:

------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------
While the tree-shaped representation of the plan is:

   GROUP BY
      |
     JOIN
 _____|_______
 |            |
ACCESS     ACCESS
(PRODUCTS) (SALES)
When you read a plan tree you should start from the bottom up. In the above example begin by looking at the access operators (or the leaves of the tree). In this case the access operators are implemented using full table scans. The rows produced by these tables scans will be consumed by the join operator. Here the join operator is a hash-join (other alternatives include nested-loop or sort-merge join). Finally the group-by operator implemented here using hash (alternative would be sort) consumes rows produced by the join-operator.
The execution plan generated for a SQL statement is just one of the many alternative execution plans considered by the query optimizer. The query optimizer selects the execution plan with the lowest cost. Cost is a proxy for performance, the lower is the cost the better is the performance. The cost model used by the query optimizer accounts for the IO, CPU, and network usage in the query.

There are two different methods you can use to look at the execution plan of a SQL statement:

EXPLAIN PLAN command - This displays an execution plan for a SQL statement without actually executing the statement.
V$SQL_PLAN - A dictionary view that shows the execution plan for a SQL statement that has been compiled into a cursor in the cursor cache.
Under certain conditions the plan shown when using EXPLAIN PLAN can be different from the plan shown using V$SQL_PLAN. For example, when the SQL statement contains bind variables the plan shown from using EXPLAIN PLAN ignores the bind variable values while the plan shown in V$SQL_PLAN takes the bind variable values into account in the plan generation process.

Displaying an execution plan is made easy if you use the DBMS_XPLAN package. This packages provides several PL/SQL procedures to display the plan from different sources:

EXPLAIN PLAN command
V$SQL_PLAN
Automatic Workload Repository (AWR)
SQL Tuning Set (STS)
SQL Plan Baseline (SPM)
The following examples illustrate how to generate and display an execution plan for our original SQL statement using the different functions provided in the dbms_xplan package.

Example 1: Uses the EXPLAIN PLAN command and the DBMS_XPLAN.DISPLAY function.

SQL> EXPLAIN PLAN FOR
 2   select prod_category, avg(amount_sold)
 3   from sales s, products p
 4   where p.prod_id = s.prod_id
 5   group by prod_category;

Explained.

SQL> select plan_table_output from table(dbms_xplan.display('plan_table',null,'basic'));

------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------
The arguments are for DBMS_XPLAN.DISPLAY are:

Plan table name (default 'PLAN_TABLE')
Statement_id (default NULL)
Format (default 'TYPICAL')
More details can be found in $ORACLE_HOME/rdbms/admin/dbmsxpln.sql.

Example 2: Generating and displaying the execution plan for the last SQL statement executed in a session:

SQL> select prod_category, avg(amount_sold)
 2   from sales s, products p
 3   where p.prod_id = s.prod_id
 4   group by prod_category;

no rows selected

SQL> select plan_table_output
 2    from table(dbms_xplan.display_cursor(null,null,'basic'));
------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------
The arguments used by DBMS_XPLAN.DISPLAY_CURSOR are:

SQL ID (default NULL, which means the last SQL statement executed in this session)
Child number (default 0)
Format (default 'TYPICAL')
The details are in $ORACLE_HOME/rdbms/admin/dbmsxpln.sql.

Example 3: Displaying the execution plan for any other statement requires the SQL ID to be provided, either directly or indirectly:

Directly:

SQL> select plan_table_output from
 2   table(dbms_xplan.display_cursor('fnrtqw9c233tt',null,'basic'));
Indirectly:

SQL> select plan_table_output
 2   from v$sql s,
 3   table(dbms_xplan.display_cursor(s.sql_id,
 4                                  s.child_number, 'basic')) t
 5   where s.sql_text like 'select PROD_CATEGORY%';

Example 4: Displaying an execution plan corresponding to a SQL Plan Baseline.

SQL> alter session set optimizer_capture_sql_plan_baselines=true;

Session altered.

SQL> select prod_category, avg(amount_sold)
 2   from sales s, products p
 3   where p.prod_id = s.prod_id
 4   group by prod_category;

no rows selected
If the above statement has been executed more than once, a SQL Plan Baseline will be created for it and you can verified this using the follows query:

SQL> select SQL_HANDLE, PLAN_NAME, ACCEPTED
 2   from dba_sql_plan_baselines
 3   where sql_text like 'select prod_category%';

SQL_HANDLE                     PLAN_NAME                      ACC
------------------------------ ------------------------------ ---
SYS_SQL_1899bb9331ed7772       SYS_SQL_PLAN_31ed7772f2c7a4c2  YES
The execution plan for the SQL Plan Baseline created above can be displayed either directly or indirectly:

Directly

select t.* from
table(dbms_xplan.display_sql_plan_baseline('SYS_SQL_1899bb9331ed7772',
                                           format => 'basic')) t
Indirectly

select t.*
    from (select distinct sql_handle
          from dba_sql_plan_baselines
          where sql_text like 'select prod_category%') pb,
         table(dbms_xplan.display_sql_plan_baseline(pb.sql_handle,
                                                    null,'basic')) t;
The output of either of these two statements is:

----------------------------------------------------------------------------
SQL handle: SYS_SQL_1899bb9331ed7772
SQL text: select prod_category, avg(amount_sold) from sales s, products p
          where p.prod_id = s.prod_id group by prod_category
----------------------------------------------------------------------------
----------------------------------------------------------------------------
Plan name: SYS_SQL_PLAN_31ed7772f2c7a4c2
Enabled: YES     Fixed: NO      Accepted: YES     Origin: AUTO-CAPTURE
----------------------------------------------------------------------------
Plan hash value: 4073170114
---------------------------------------------------------
 Id   Operation                 Name               
---------------------------------------------------------
   0  SELECT STATEMENT                             
   1   HASH GROUP BY                               
   2    HASH JOIN                                  
   3     VIEW                   index$_join$_002   
   4      HASH JOIN                                
   5       INDEX FAST FULL SCAN PRODUCTS_PK        
   6       INDEX FAST FULL SCAN PRODUCTS_PROD_CAT_IX
   7     PARTITION RANGE ALL                       
   8      TABLE ACCESS FULL     SALES              
---------------------------------------------------------
Formatting
The format argument is highly customizable and allows you to see as little (high-level) or as much (low-level) details as you need / want in the plan output. The high-level options are:

Basic
The plan includes the operation, options, and the object name (table, index, MV, etc)
Typical
It includes the information shown in BASIC plus additional optimizer-related internal information such as cost, size, cardinality, etc. These information are shown for every operation in the plan and represents what the optimizer thinks is the operation cost, the number of rows produced, etc. It also shows the predicates evaluation by the operation. There are two types of predicates: ACCESS and FILTER. The ACCESS predicates for an index are used to fetch the relevant blocks because they apply to the search columns. The FILTER predicates are evaluated after the blocks have been fetched.
All
It includes the information shown in TYPICAL plus the lists of expressions (columns) produced by every operation, the hint alias and query block names where the operation belongs. The last two pieces of information can be used as arguments to add hints to the statement.
The low-level options allow the inclusion or exclusion of find details, such as predicates and cost.

For example:

select plan_table_output
from table(dbms_xplan.display('plan_table',null,'basic +predicate +cost'));

-------------------------------------------------------
 Id   Operation              Name      Cost (%CPU)
-------------------------------------------------------
   0  SELECT STATEMENT                    17  (18)
   1   HASH GROUP BY                      17  (18)
*  2    HASH JOIN                         15   (7)
   3     TABLE ACCESS FULL   PRODUCTS      9   (0)
   4     PARTITION RANGE ALL               5   (0)
   5      TABLE ACCESS FULL  SALES         5   (0)
-------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
2 - access("P"."PROD_ID"="S"."PROD_ID")

select plan_table_output from
table(dbms_xplan.display('plan_table',null,'typical -cost -bytes'));

----------------------------------------------------------------------------
 Id   Operation              Name      Rows  Time      Pstart Pstop
----------------------------------------------------------------------------
   0  SELECT STATEMENT                    4  00:00:01             
   1   HASH GROUP BY                      4  00:00:01             
*  2    HASH JOIN                       960  00:00:01             
   3     TABLE ACCESS FULL   PRODUCTS   766  00:00:01             
   4     PARTITION RANGE ALL            960  00:00:01      1     16
   5      TABLE ACCESS FULL  SALES      960  00:00:01      1     16
----------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
2 - access("P"."PROD_ID"="S"."PROD_ID")
Note Section
In addition to the plan, the package displays notes in the NOTE section, such as that dynamic sampling was used during query optimization or that star transformation was applied to the query.

For example, if the table SALES did not have statistics then the optimizer will use dynamic sampling and the plan display will report it as follows (see s'+note' detail in the query):

select plan_table_output
from table(dbms_xplan.display('plan_table',null,'basic +note'));

------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------
Note
-----
- dynamic sampling used for this statement
Bind Peeking
The query optimizer takes into account the values of bind variable values when generation an execution plan. It does what is generally called bind peeking. See the first post in this blog about the concept of bind peeking and its impact on the plans and the performance of SQL statements.

As stated earlier the plan shown in V$SQL_PLAN takes into account the values of bind variables while the one shown from using EXPLAIN PLAN does not. The DBMS_XPLAN package allows the display of the bind variable values used to generate a particular cursor/plan. This is done by adding '+peeked_binds' to the format argument when using display_cursor().

This is illustrated with the following example:

variable pcat varchar2(50)
exec :pcat := 'Women'

select PROD_CATEGORY, avg(amount_sold)
from sales s, products p
where p.PROD_ID = s.PROD_ID
and prod_category != :pcat
group by PROD_CATEGORY;
select plan_table_output
from table(dbms_xplan.display_cursor(null,null,'basic +PEEKED_BINDS'));

------------------------------------------
 Id   Operation              Name   
------------------------------------------
   0  SELECT STATEMENT              
   1   HASH GROUP BY                
   2    HASH JOIN                   
   3     TABLE ACCESS FULL   PRODUCTS
   4     PARTITION RANGE ALL        
   5      TABLE ACCESS FULL  SALES  
------------------------------------------
Peeked Binds (identified by position):
--------------------------------------
1 - :PCAT (VARCHAR2(30), CSID=2): 'Women'

--------- 