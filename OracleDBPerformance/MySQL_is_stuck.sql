"My SQL is stuck." 
"My Query is taking long time to execute.".

These problem statements are very common, but for the most part the problems as easily solved – if you know how to debug the issue. In this article I will attempt to explain how I debugged and solved a real performance issue. (Note that the objects have been renamed.)

I received a request to look into a performance issue: “I am unable to refresh GLUSR_OPPORTUNITY_MV materialized view, and the dbms_mview.refresh is stuck for last the 45 minutes.” The person was trying to re-create GLUSR_OPPORTUNITY_MV materialized view after adding one new varchar2 column from the existing base table. There was no other change in the query of the materialized view, no table was added, and no condition was altered. Prior to the problem this materialized view refreshed in less than 5 minutes.

I performed the following steps to debug and resolve the performance issue. Step 1: I look into V$SESSION to see if the session is Waiting or Working. The person is logged in with the DBSNPUSR schema.

Step 1: I look into V$SESSION to see if the session is Waiting or Working. The person is logged in with the DBSNPUSR schema.

ngarg> select sid, state, seconds_in_wait, event, sql_id
  2    from v$session
  3    where username = 'DBSNPUSR';

       SID STATE               SECONDS_IN_WAIT EVENT                                                    SQL_ID
---------- ------------------- --------------- -------------------------------------------------------- ------------
      1719 WAITED SHORT TIME                 0 direct path write temp                                   70bybu7qaukzb

Figure 1

The session STATE is "WAITED SHORT TIME," which means the session is working. The EVENT is "direct path write temp," which means the database is writing to a temporary tablespace.

To explain V$SESSION a bit, we usually look at the STATE column first to check whether the session is Waiting for something or Working. The EVENT column tells us what the event Session is Waiting for, or what task Session is performing. SECONDS_IN_WAIT tells us how long our session has been waiting for something. In this case the database is writing (not waiting), so SECONDS_IN_WAIT is 0. If SECONDS_IN_WAIT has some significant number, there might be a performance bottleneck. SQLID is the identifier of the SQL statement associated with the operation the session is performing.

Now we need to debug what the database is doing. The simplest way to know what operation the database is working on is to look into V$SESSION_LONGOPS.

ngarg> select target, time_remaining, elapsed_seconds, sql_plan_operation, sql_plan_options
  2  from v$session_longops where sql_id = '70bybu7qaukzb' and  TIME_REMAINING > 0;

TARGET                   TIME_REMAINING ELAPSED_SECONDS SQL_PLAN_OPERATION    SQL_PLAN_OPTIONS 
------------------------ -------------- --------------- --------------------- -----------------
DBSNPUSR.GLUSR_OPTY_STG  46383          6238            MAT_VIEW ACCESS       FULL

Figure 2

OK, now we know that the database is full-scanning DBSNPUSR.GLUSR_OPTY_STG for the last 6238 seconds and that 46383 seconds remain. At first sight, the GLUSR_OPTY_STG table seems to have some issues.

Here is some detail about the V$SESSION_LONGOPS columns I used in my query. V$SESSION_LONGOPS displays the status of various operations that run for longer than six seconds.

TARGET column identifies the object on which Oracle is performing the operation
TIME_REMAINING provides the estimated time in which Oracle should complete the operation
ELAPSED_SECONDS refers to the seconds elapsed since the operation started
SQL_PLAN_OPERATION identifies which operation session is performing on the target
SQL_PLAN_OPTIONS tells us how the session is performing SQL_PLAN_OPERATION on TARGET
The query of GLUSR_OPPORTUNITY_MV reveals that GLUSR_OPTY_STG is being used in "WITH CLAUSE", and that the view "base" was used multiple times. (I can’t share the complete code here, but that code is not significant to our performance issue.)

base AS
(SELECT glusr_opty_id, created_on_dt, email_address
   FROM dbsnpusr.glusr_opty_stg
  WHERE email_address IS NOT NULL
)

Figure 3

The natural next step is to look at the Execution Plan for Query of GLUSR_OPPORTUNITY_MVs. We can easily get the time Execution plan of any SQL (if we know the SQL_ID) using the dbms_xplan.display_cursor.

ngarg> select plan_table_output from table(dbms_xplan.display_cursor('70bybu7qaukzb',null,'Typical'));
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name             | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |                  |       |       | 33231 (100)|          |    |          |
|   1 |  LOAD TABLE CONVENTIONAL        | GLUSR_OPPORTUNITY_MV |   |       |            |          |    |          |
|*  2 |   HASH JOIN OUTER               |                  |     1 |  2325 | 33231  (21)| 00:00:01 |    |          |
|*  3 |    HASH JOIN OUTER              |                  |     1 |  2241 | 31359  (21)| 00:00:01 |    |          |
|*  4 |     HASH JOIN OUTER             |                  |     1 |  2157 |  5799  (13)| 00:00:01 |    |          |
|*  5 |      MAT_VIEW ACCESS FULL       | GLUSR_OPTY_STG   |     1 |  2073 |     2   (0)| 00:00:01 |    |          |
|   6 |      VIEW                       |                  |     1 |    84 |  5797  (13)| 00:00:01 |    |          |
|   7 |       SORT UNIQUE               |                  |     1 |    25 |  5797  (13)| 00:00:01 |    |          |
|*  8 |        VIEW                     |                  |     1 |    25 |  5796  (13)| 00:00:01 |    |          |
|*  9 |         WINDOW SORT PUSHED RANK |                  |     1 |  2109 |  5796  (13)| 00:00:01 |    |          |
|* 10 |          HASH JOIN              |                  |     1 |  2109 |  5795  (13)| 00:00:01 |    |          |
|* 11 |           MAT_VIEW ACCESS FULL  | GLUSR_OPTY_STG   |     1 |  2073 |     2   (0)| 00:00:01 |    |          |
|* 12 |           TABLE ACCESS FULL     | GLUSR_FORMSUBMIT |  3600 |   126K|  5792  (13)| 00:00:01 |    |          |
|  13 |     VIEW                        |                  |     1 |    84 | 25559  (23)| 00:00:01 |    |          |
|  14 |      SORT UNIQUE                |                  |     1 |    27 | 25559  (23)| 00:00:01 |    |          |
|* 15 |       VIEW                      |                  |     1 |    27 | 25558  (23)| 00:00:01 |    |          |
|* 16 |        WINDOW SORT PUSHED RANK  |                  |     1 |    92 | 25558  (23)| 00:00:01 |    |          |
|  17 |         VIEW                    | VM_NWVW_2        |     1 |    92 | 25557  (23)| 00:00:01 |    |          |
|  18 |          SORT UNIQUE            |                  |     1 |  2159 | 25557  (23)| 00:00:01 |    |          |
|* 19 |           HASH JOIN             |                  |     1 |  2159 | 25556  (23)| 00:00:01 |    |          |
|  20 |            MERGE JOIN CARTESIAN |                  |     1 |  2123 |     7  (15)| 00:00:01 |    |          |
|* 21 |             MAT_VIEW ACCESS FULL| GLUSR_OPTY_STG   |     1 |  2085 |     2   (0)| 00:00:01 |    |          |
|  22 |             BUFFER SORT         |                  |  5037 |   186K|     5  (20)| 00:00:01 |    |          |
|* 23 |              TABLE ACCESS FULL  | GLUSR_CAMP_API   |  5037 |   186K|     5  (20)| 00:00:01 |    |          |
|  24 |            PARTITION RANGE ALL  |                  |   407K|    13M| 25531  (23)| 00:00:01 |  1 |1048575|
|* 25 |             TABLE ACCESS FULL   | GLUSR_PAGEVISIT  |   407K|    13M| 25531  (23)| 00:00:01 |  1 |1048575|
|  26 |    VIEW                         |                  |     1 |    84 |  1871  (26)| 00:00:01 |    |          |
|  27 |     SORT UNIQUE                 |                  |     1 |    27 |  1871  (26)| 00:00:01 |    |          |
|* 28 |      VIEW                       |                  |     1 |    27 |  1870  (26)| 00:00:01 |    |          |
|* 29 |       WINDOW SORT PUSHED RANK   |                  |     1 |    92 |  1870  (26)| 00:00:01 |    |          |
|  30 |        VIEW                     | VM_NWVW_1        |     1 |    92 |  1869  (26)| 00:00:01 |    |          |
|  31 |         SORT UNIQUE             |                  |     1 |  2123 |  1869  (26)| 00:00:01 |    |          |
|* 32 |          HASH JOIN              |                  |     1 |  2123 |  1868  (26)| 00:00:01 |    |          |
|* 33 |           MAT_VIEW ACCESS FULL  | GLUSR_OPTY_STG   |     1 |  2085 |     2   (0)| 00:00:01 |    |          |
|* 34 |           TABLE ACCESS FULL     | GLUSR_RESPONSE   |  1973K|    71M|  1776  (22)| 00:00:01 |    |          |
--------------------------------------------------------------------------------------------------------------------


Figure 4

The figure above I have trimmed the output and removed the extra data, so that we can focus on the issue (highlighted). As we can see in execution plan, GLUSR_OPTY_STG is used 4 times with "MAT_VIEW ACCESS FULL" access path, but the Oracle is expecting only 1 row from this it. This looks like some issue.

Let’s check how many rows GLUSR_OPTY_STG table has-

ngarg> select count(*) from GLUSR_OPTY_STG;
  COUNT(*)
----------

Figure 5

Oh, What Oracle is estimating for GLUSR_OPTY_STG seems to be off by huge margin. We should also quickly look for other tables used in query of GLUSR_OPPORTUNITY_MV materialized view…

 ngarg> select distinct REFERENCED_NAME from dba_dependencies
  2  where name = 'GLUSR_OPPORTUNITY_MV';

REFERENCED_NAME
-----------------------------------------------------------------------------------
GLUSR_PAGEVISIT
GLUSR_CAMP_API
GLUSR_FORMSUBMIT
GLUSR_OPPORTUNITY_MV
GLUSR_OPTY_STG
GLUSR_RESPONSE

Figure 6

… and checked the NUM_ROWS from DBA_TABLES …

ngarg> SELECT TABLE_NAME, NUM_ROWS, BLOCKS FROM DBA_TABLES WHERE TABLE_NAME IN
  2  (
  3  'GLUSR_RESPONSE',
  4  'GLUSR_PAGEVISIT',
  5  'GLUSR_CAMP_API',
  6  'GLUSR_FORMSUBMIT'
  7  );

TABLE_NAME                         NUM_ROWS   BLOCKS
-------------------------------- ---------- ---------
GLUSR_CAMPAIGN_API                     5037        23
GLUSR_FORMSUBMIT                    2674220     45694
GLUSR_RESPONSE                      1976366     12423
GLUSR_PAGEVISIT                    22124000    177680

Figure 7

… compare NUM_ROWS with the actual row counts of the tables

ngarg> select count(*) from GLUSR_RESPONSE;
  COUNT(*)
----------
   1976366

ngarg> select count(*) from GLUSR_PAGEVISIT;
  COUNT(*)
----------
  22119490

ngarg> select count(*) from GLUSR_CAMPAIGN_API;
  COUNT(*)
----------
      5812

ngarg> select count(*) from GLUSR_FORMSUBMIT;
  COUNT(*)
----------
   2665326

Figure 8

With the two outputs above we can determine that the statistics for all the tables used in the query of the GLUSR_OPPORTUNITY_MV materialized view are similar, except that the GLUSR_OPTY_STG. GLUSR_OPTY_STG statistics are missing/stale, as determined by which Oracle database is generating a suboptimal plan. Now that we have the action plan, we should gather the stats of GLUSR_OPTY_STG, and execute the refresh for the GLUSR_OPPORTUNITY_MV materialized view.

The produced output might look like this:

ngarg> exec dbms_stats.gather_table_stats(null, 'GLUSR_OPTY_STG');      2
Figure 9

Just to add a little about dbms_stats.gather_table_stats, it uses ESTIMATE_PERCENT to control the sample size used when gathering statistics and default values for ESTIMATE_PERCENT is AUTO_SAMPLE_SIZE, which means that the Oracle Database automatically determines the appropriate sampling percentage, which is highly recommended over the fixed sampling percentage.

After I gathered the statistics, the GLUSR_OPTY_STG, GLUSR_OPPORTUNITY_MV materialized view was refreshed in under 5 minutes. When I checked with the developer, he confirmed that before creating GLUSR_OPPORTUNITY_MV materialized view, he re-created GLUSR_OPTY_STG too.

Lessons Learned
To generate the optimal execution plan, Oracle database is very much dependent on statistics. Most performance issues can be resolved if we can ensure that table statistics are not missing and that the statistics are not stale. Also, use the default value of ESTIMATE_PERCENT, which is AUTO_SAMPLE_SIZE, so that Oracle can effectively gather statistics by adjusting the sample size when the data distribution changes. Happy Database Performance Tuning!