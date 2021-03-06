This is exactly what incremental statistics was built for.
--https://docs.oracle.com/database/121/TGSQL/tgsql_stats.htm#GUID-7BECE839-ACC5-4768-8BE6-A16AAD14A9ED

With incremental statistics, Oracle will only gather partition statistics for partitions that have changed. Synopses are built for each partition, and those synopses are quickly combined to create global statistics without having to re-scan the whole table.

To enable it you only need to set a table preference and then gather statistics. The first gather will be slow but future statistics gathering will be much faster.

begin
    dbms_stats.set_table_prefs('TABLE_OWNER', 'TABLE_NAME', 'incremental', 'true');
    dbms_stats.gather_table_stats('TABLE_OWNER', 'TABLE_NAME');
end;
/

--#################################--

--https://blog.toadworld.com/sophisticated-incremental-statistics-gathering-feature-in-12c

Sophisticated Incremental Statistics gathering feature in 12c
 Mar 21, 2016 10:14:00 AM by Steve Hilker

Overview
In typical data warehousing environment existence of huge partitioned tables is very common, gathering statistics on such tables is challenging tasks. For partitioned tables there are two types of statistics Global and Partition level statistics. Gathering global statistics is very expensive and resource consuming operation as it scans whole table. Hence most of the time people use to reduce estimate_percent down to less than 1 percent. This does helps in reducing time taken to gather stats but may not be sufficient to represent the data distribution. Gathering partition level statistics is not so expensive as it gathers only for the partitions where data has been changed.

Traditionally statistics are gathered in two phase

Scan complete table to gather Global statistics
Scan only the partitions where data has been changed
Obviously global stats can be derived by using partition level stats like say for example number of rows at table level = just sum number of rows from all the partitions. But global stats like NDV(Number of Distinct Values) which is very important in calculating cardinality can't be derived so easily. The only way to derive them is by scanning the whole table.

This is why Oracle introduced Incremental Statistics gathering feature in 11g, this feature not only reduces the time it takes to gather global stats but also it increases the statistics accuracy. This avoids scanning whole table when computing global statistics and derives it from partition level statistics. But since NDV can't be derived from partition level statistics it creates synopsis for each column at individual partition level. This synopsis maintains detail information of distinct values at each partition for every columns. After implementing Incremental Statistics feature when a new partition is added to the table it gathers partition level statistics along with its synopsis and then merges all the partitions synopses to create global synopsis, at the end global statistics will be derived by using partition level statistics and global synopsis.

These synopsis data are stored in WRI$_OPTSTAT_SYNOPSIS$ and WRI$_OPTSTAT_SYNOPSIS_HEAD$ tables residing in SYSAUX tablespace. Table WRI$_OPTSTAT_SYNOPSIS$ will grow enormously as there will be individual synopsis created for each hash proportional to distinct value existing at table,partition and column level. Table WRI$_OPTSTAT_SYNOPSIS_HEAD$ will have each record for every table, partition, and column. In 11.1 release gathering incremental statistics would take longer time if you have wide tables with many partitions due to delete statement working on WRI$_OPTSTAT_SYNOPSIS$ table. In 11.2 this issue has been resolved by Range-Hash partitioning the WRI$_OPTSTAT_SYNOPSIS$ table.

SQL> select OWNER,TABLE_NAME,PARTITIONING_TYPE,SUBPARTITIONING_TYPE from dba_part_tables where TABLE_NAME='WRI$_OPTSTAT_SYNOPSIS$';

OWNER           TABLE_NAME                     PARTITIONING_TYPE           SUBPARTITIONING_TYPE
--------------- ------------------------------ --------------------------- ---------------------------
SYS             WRI$_OPTSTAT_SYNOPSIS$         RANGE                       HASH
In 12c WRI$_OPTSTAT_SYNOPSIS$ table has been changed to List-Hash partitioning to reduce the data movement when compared previous partitioning strategy.

SQL> select OWNER,TABLE_NAME,PARTITIONING_TYPE,SUBPARTITIONING_TYPE from dba_part_tables where TABLE_NAME='WRI$_OPTSTAT_SYNOPSIS$';

OWNER           TABLE_NAME                     PARTITIONING_TYPE           SUBPARTITIONING_TYPE
--------------- ------------------------------ --------------------------- ---------------------------
SYS             WRI$_OPTSTAT_SYNOPSIS$         LIST                        HASH
NOTE: In 10.2.0.4 we can use 'APPROX_GLOBAL AND PARTITION' for the GRANULARITY parameter of the GATHER_TABLE_STATS procedures to gather statistics in incremental way, but drawback is about unavailability of NDV for non-partitioning columns and number of distinct keys of the index at the global level. This method derives all other global statistics accurately, hence it reduces the frequency of deriving global statistics but doesn't completely resolves the overhead of NDV.

Implementation
To enable Incremental Statistics feature for each table we need to ensure that

The INCREMENTAL value for the partitioned table is true.(Default is FALSE)
The PUBLISH value for the partitioned table is true.(Default is TRUE)
The user specifies AUTO_SAMPLE_SIZE for ESTIMATE_PERCENT and AUTO for GRANULARITY when gathering statistics on the table.(Default is ESTIMATE_PERCENT=>AUTO_SAMPLE_SIZE and GRANULARITY=>AUTO)
Its challenging task when we try to initially enable Incremental Statistics and start gathering global statistics, as it will create synopsis for all the partitions and this will takes huge amount of time/resources due to large partitioned tables. Sometimes it may takes days together to create it. Lot of planning and controlled approach is required to enable Incremental Statistics on large partitioned tables. Different deviated approach has to be considered to create initial synopsis, as we can't blindly use GRANULARITY=>AUTO as per the documentation.

Trick is to create synopsis for each partition in a controlled manner by using GRANULARITY=>PARTITION and then gather global statistics. For example, I have a monthly partitioned table ORDERS_DEMO in OE schema to which Incremental Statistics has to be enabled in controlled manner as shown below.

1. Set up Incremental Statistics feature mandatory parameters.

SQL> exec dbms_stats.set_table_prefs('OE','ORDERS','INCREMENTAL','TRUE');
PL/SQL procedure successfully completed.

SQL> SELECT dbms_stats.get_prefs('INCREMENTAL','OE','ORDERS_DEMO') "INCREMENTAL" FROM   dual;
INCREMENTAL
------------------------
FALSE

SQL> SELECT dbms_stats.get_prefs('PUBLISH','OE','ORDERS_DEMO') "PUBLISH" FROM   dual;
PUBLISH
------------------------
TRUE

SQL> SELECT dbms_stats.get_prefs('ESTIMATE_PERCENT','OE','ORDERS_DEMO') "ESTIMATE_PERCENT" FROM   dual;
ESTIMATE_PERCENT
------------------------
DBMS_STATS.AUTO_SAMPLE_SIZE

SQL> SELECT dbms_stats.get_prefs('GRANULARITY','OE','ORDERS_DEMO') "GRANULARITY" FROM   dual;
GRANULARITY
------------------------
AUTO
2. Create synopsis for each partition in a controlled manner.

SQL> exec dbms_stats.gather_table_stats('OE','ORDERS_DEMO',partname=>'ORDERS_OCT_2015',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, granularity=>'PARTITION');
PL/SQL procedure successfully completed.
3. Check synopsis creation time.

SELECT o.name         "Table Name",
       p.subname      "Part",
       c.name         "Column",
       h.analyzetime  "Synopsis Creation Time"
FROM   WRI$_OPTSTAT_SYNOPSIS_HEAD$ h,
       OBJ$ o,
       USER$ u,
       COL$ c,
       ( ( SELECT TABPART$.bo#  BO#,
                  TABPART$.obj# OBJ#
           FROM   TABPART$ tabpart$ )
         UNION ALL
         ( SELECT TABCOMPART$.bo#  BO#,
                  TABCOMPART$.obj# OBJ#
           FROM   TABCOMPART$ tabcompart$ ) ) tp,
       OBJ$ p
WHERE  u.name = 'OE' AND
       o.name = 'ORDERS_DEMO' AND
       tp.obj# = p.obj# AND
       h.bo# = tp.bo# AND
       h.group# = tp.obj# * 2 AND
       h.bo# = c.obj#(+) AND
       h.intcol# = c.intcol#(+) AND
       o.owner# = u.user# AND
       h.bo# = o.obj#
ORDER  BY 4,1,2,3
/

Table Name           Part                 Column                    Synopsis Creation Time
-------------------- -------------------- ------------------------- ------------------------------
ORDERS_DEMO          ORDERS_SEP_2015      CUSTOMER_ID               2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_DATE                2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_ID                  2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_MODE                2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_STATUS              2015-11-17-01:00:25
4. Gradually build Synopsis for remaining partitions

As you saw Synopsis gets created for each column in a table. Same way build synopsis for all the remaining partitions and in the end gather global statistics which will use previously created synopsis and partition level statistics.

exec dbms_stats.gather_table_stats('OE','ORDERS_DEMO',partname=>'ORDERS_OCT_2015',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, granularity=>'PARTITION');
exec dbms_stats.gather_table_stats('OE','ORDERS_DEMO',partname=>'ORDERS_NOV_2015',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, granularity=>'PARTITION');
exec dbms_stats.gather_table_stats('OE','ORDERS_DEMO',partname=>'ORDERS_DEC_2015',ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, granularity=>'PARTITION');
5. Verify timing information of partition level statistics gathering.

SELECT partition_name,
       to_char( last_analyzed, 'DD-MON-YYYY, HH24:MI:SS' ) last_analyze,
       num_rows
FROM   DBA_TAB_PARTITIONS
WHERE  table_name = 'ORDERS_DEMO'
ORDER  BY partition_position;

PARTITION_NAME                           LAST_ANALYZE                               NUM_ROWS
---------------------------------------- ---------------------------------------- ----------
ORDERS_SEP_2015                          17-NOV-2015, 01:00:25                           180
ORDERS_OCT_2015                          17-NOV-2015, 02:28:15                           186
ORDERS_NOV_2015                          17-NOV-2015, 03:35:19                           180
ORDERS_DEC_2015                          17-NOV-2015, 05:01:12                             0
6. Gather global statistics using Incremental Statistics feature.

exec dbms_stats.gather_table_stats('OE','ORDERS_DEMO');
7. Ensure that partition level statistics have not been re-gathered and synopsis are intact.

SELECT partition_name,
       to_char( last_analyzed, 'DD-MON-YYYY, HH24:MI:SS' ) last_analyze,
       num_rows
FROM   DBA_TAB_PARTITIONS
WHERE  table_name = 'ORDERS_DEMO'
ORDER  BY partition_position; 

PARTITION_NAME                           LAST_ANALYZE                               NUM_ROWS
---------------------------------------- ---------------------------------------- ----------
ORDERS_SEP_2015                          17-NOV-2015, 01:00:25                           180
ORDERS_OCT_2015                          17-NOV-2015, 02:28:15                           186
ORDERS_NOV_2015                          17-NOV-2015, 03:35:19                           180
ORDERS_DEC_2015                          17-NOV-2015, 05:01:12                             0
8. Check if we have actually gathered global statistics by using Incremental Statistics gathering feature.

SELECT o.name,
       decode( bitand( h.spare2, 8 ), 8, 'yes', 'no' ) incremental
FROM   HIST_HEAD$ h,
       OBJ$ o
WHERE  h.obj# = o.obj# AND
       o.name = 'ORDERS_DEMO' AND
       o.subname IS NULL; 

NAME             INCREMENTAL
---------------- ----------------
ORDERS_DEMO      yes

With this approach we can create synopsis on each partition in a controlled manner and then derive global statistics efficiently by using synopsis created before hand. Hence on large partitioned tables its better to follow this approach and avoid enabling Incremental Statistics feature directly by setting GRANULARITY=>AUTO as per the documentation.
Drastic enhancements in 12c
In 12c Incremental Statistics has been enhanced tremendously when compared to 11g. Now in 12c we have greater control and flexibility over the behavior of Incremental Statistics feature. Let walk through some of the important enhancements in detail.

Control over STALENESS of partition statistics
In 11g release if DML occurs on any partition then partition level statistics of those partitions are meant to be stale, and thus it will result in re-gathering partition statistics which are stale before deriving global statistics through Incremental gathering. This overhead has obligated many people to not use Incremental Statistics feature as even single row modification would result in staleness of partition level statistics.

In 12c we can control staleness of partition level statistics by using statistics preference INCREMENTAL_STALENESS along with value USE_STALE_PERCENT, this value defines percentage of rows modified due to DML activity for a partition/sub-partition statistics to be become stale. By default it is defined as 10%, so if more than 10% of the rows are modified in a partition/sub-partition then partition/sub-partition statistics are considered to be stale. This way in 12c we can avoid overhead of collecting partition statistics whenever there is data change(even single row) in partition/sub-partition during Incremental gathering of global statistics.

To set USE_STALE_PERCENT for table ORDER_DEMO.

BEGIN
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_DEMO', 
		pname    => 'INCREMENTAL_STALENESS', 
		pvalue   => 'USE_STALE_PERCENT');
END;
/
To modify the default 10% stale percent to 20%.

BEGIN
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_DEMO', 
		pname    => 'STALE_PERCENT', 
		pvalue   => 20);
END;
/
Control over LOCKED partition statistics
In 11g release if statistics of partitions are locked and if any data gets modified in such partition then the only way to gather global statistics is by scanning full table, its due to the fact that partition level statistics can't be gathered as they are locked. Its very common in warehousing databases to have partitions meant to archive the data and modification of data on such partitions is rare, maintaining global statistics on such type of tables was challenging even after implementing Incremental Statistics feature.

In 12c we can instruct to not consider locked partition or subpartition statistics as stale regardless of DML changes(No matter how many rows are modified, it also ignores STALE_PERCENT preference) by setting statistics preference INCREMENTAL_STALENESS to value USE_LOCKED_STATS. This way in 12c we can maintain global statistics incrementally by using existing locked partition level statistics and ignoring the fact that locked partition level statistics are stale.

To set USE_LOCKED_STATS for table ORDER_DEMO.

BEGIN
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_DEMO', 
		pname    => 'INCREMENTAL_STALENESS', 
		pvalue   => 'USE_LOCKED_STATS');
END;
/
We can also set both USE_STALE_PERCENT and USE_LOCKED_STATS for table ORDER_DEMO.

BEGIN
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_DEMO', 
		pname    => 'INCREMENTAL_STALENESS', 
		pvalue   => 'USE_STALE_PERCENT,USE_LOCKED_STATS');
END;
/
NOTE: If preference INCREMENTAL_STALENESS is unset then by default it behaves similar to 11g - where even if single row is modified within the partition/sub-partition then Incremental gathering will gather partition/sub-partition statistics before deriving global statistics. Also even if single row is modified within the partition/sub-partition whose statistics are locked then Incremental gathering will perform full table scan to derive global statistics.

Incremental Statistics during partition maintenance
In 11g release if we perform partition maintenance operation then Incremental Statistics gathering will gather impacted partition statistics(synopsis) before deriving global statistics. Say for example, if we perform partition exchange with a table having up to date statistics(no synopsis) then Incremental gathering will ignore these table level stats and gather them once again after completion of partition exchange operation. Practically partition exchange is just a matter of updating dictionary information, but Incremental gathering is not able to leverage it and thus creates overhead of gathering partition level statistics(synopsis) for this new exchanged partition. There is no way to avoid this overhead in warehousing environment where loading table through partition exchange operation is very common.

In 12c we can create synopsis on a non-partitioned table which is going to be exchanged with the partitioned table where global statistics are maintained incrementally. The synopsis of non-partitioned table will allow to maintain incremental statistics as part of a partition exchange operation without having to explicitly gathering statistics on the partition after the exchange.

For example, I want to exchange non-partitioned staging table ORDERS_STAGING with partitioned table ORDERS_DEMO along with synopsis to maintain incremental statistics as part of the partition exchange operation

Partitioned table : ORDERS_DEMO

Non-partitioned table : ORDERS_STAGING

1. Enable synopsis creation for non-partitioned table ORDERS_STAGING

BEGIN
-- Enable Incremental feature 
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_STAGING', 
		pname    => 'INCREMENTAL', 
		pvalue   => 'TRUE');

-- Set synopsis creation at table level
	DBMS_STATS.SET_TABLE_PREFS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_STAGING', 
		pname    => 'INCREMENTAL_LEVEL', 
		pvalue   => 'TABLE');
END;
/
As you saw I have set INCREMENTAL_LEVEL preference to value 'TABLE', this is a new introduction of preference in 12c to gather table-level synopsis.

2. Create synopsis for non-partitioned staging table

BEGIN
	DBMS_STATS.GATHER_TABLE_STATS (
		ownname  => 'OE', 
		tabname  => 'ORDERS_STAGING'); 
END;
/
3. Check and confirm synopsis creation of staging table ORDERS_STAGING

SELECT o.name         "Table Name",
       p.subname      "Part",
       c.name         "Column",
       h.analyzetime  "Synopsis Creation Time"
FROM   WRI$_OPTSTAT_SYNOPSIS_HEAD$ h,
       OBJ$ o,
       USER$ u,
       COL$ c,
       ( ( SELECT TABPART$.bo#  BO#,
                  TABPART$.obj# OBJ#
           FROM   TABPART$ tabpart$ )
         UNION ALL
         ( SELECT TABCOMPART$.bo#  BO#,
                  TABCOMPART$.obj# OBJ#
           FROM   TABCOMPART$ tabcompart$ ) ) tp,
       OBJ$ p
WHERE  u.name = 'OE' AND
       o.name = 'ORDERS_STAGING' AND
       tp.obj# = p.obj# AND
       h.bo# = tp.bo# AND
       h.group# = tp.obj# * 2 AND
       h.bo# = c.obj#(+) AND
       h.intcol# = c.intcol#(+) AND
       o.owner# = u.user# AND
       h.bo# = o.obj#
ORDER  BY 4,1,2,3
/

Table Name           Part                 Column                    Synopsis Creation Time
-------------------- -------------------- ------------------------- ------------------------------
ORDERS_STAGING                            CUSTOMER_ID               2015-11-23-04:01:46
ORDERS_STAGING                            ORDER_DATE                2015-11-23-04:01:46
ORDERS_STAGING                            ORDER_ID                  2015-11-23-04:01:46
ORDERS_STAGING                            ORDER_MODE                2015-11-23-04:01:46
ORDERS_STAGING                            ORDER_STATUS              2015-11-23-04:01:46
4. Perform partition exchange

ALTER TABLE ORDER_DEMO EXCHANGE PARTITION ORDERS_DEC_2015 WITH TABLE ORDERS_STAGING;
5. Check and confirm that partition level synopsis(ORDERS_DEC_2015) has been exchanged instead of re-gathering it

SELECT o.name         "Table Name",
       p.subname      "Part",
       c.name         "Column",
       h.analyzetime  "Synopsis Creation Time"
FROM   WRI$_OPTSTAT_SYNOPSIS_HEAD$ h,
       OBJ$ o,
       USER$ u,
       COL$ c,
       ( ( SELECT TABPART$.bo#  BO#,
                  TABPART$.obj# OBJ#
           FROM   TABPART$ tabpart$ )
         UNION ALL
         ( SELECT TABCOMPART$.bo#  BO#,
                  TABCOMPART$.obj# OBJ#
           FROM   TABCOMPART$ tabcompart$ ) ) tp,
       OBJ$ p
WHERE  u.name = 'OE' AND
       o.name = 'ORDERS_DEMO' AND
       p.subname in ('ORDERS_DEC_2015','ORDERS_NOV_2015','ORDERS_OCT_2015') AND
       tp.obj# = p.obj# AND
       h.bo# = tp.bo# AND
       h.group# = tp.obj# * 2 AND
       h.bo# = c.obj#(+) AND
       h.intcol# = c.intcol#(+) AND
       o.owner# = u.user# AND
       h.bo# = o.obj#
ORDER  BY 4,1,2,3
/

Table Name           Part                 Column                    Synopsis Creation Time
-------------------- -------------------- ------------------------- ------------------------------
ORDERS_DEMO          ORDERS_SEP_2015      CUSTOMER_ID               2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_DATE                2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_ID                  2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_MODE                2015-11-17-01:00:25
ORDERS_DEMO                               ORDER_STATUS              2015-11-17-01:00:25

ORDERS_DEMO          ORDERS_OCT_2015      CUSTOMER_ID               2015-11-17-02:28:15
ORDERS_DEMO                               ORDER_DATE                2015-11-17-02:28:15
ORDERS_DEMO                               ORDER_ID                  2015-11-17-02:28:15
ORDERS_DEMO                               ORDER_MODE                2015-11-17-02:28:15
ORDERS_DEMO                               ORDER_STATUS              2015-11-17-02:28:15
               
ORDERS_DEMO          ORDERS_NOV_2015      CUSTOMER_ID               2015-11-17-03:35:19
ORDERS_DEMO                               ORDER_DATE                2015-11-17-03:35:19
ORDERS_DEMO                               ORDER_ID                  2015-11-17-03:35:19
ORDERS_DEMO                               ORDER_MODE                2015-11-17-03:35:19
ORDERS_DEMO                               ORDER_STATUS              2015-11-17-03:35:19
               
ORDERS_DEMO          ORDERS_DEC_2015      CUSTOMER_ID               2015-11-23-04:01:46
ORDERS_DEMO                               ORDER_DATE                2015-11-23-04:01:46
ORDERS_DEMO                               ORDER_ID                  2015-11-23-04:01:46
ORDERS_DEMO                               ORDER_MODE                2015-11-23-04:01:46
ORDERS_DEMO                               ORDER_STATUS              2015-11-23-04:01:46
By comparing creation time(2015-11-23-04:01:46) of Synopsis we can conclude that it has been copied from ORDERS_STAGING to ORDERS_DEMO partition ORDERS_DEC_2015 due to partition exchange operation. This way we can easily swap the synopsis from staging table to partitioned table along with partition exchange operation and avoid overhead of re-gathering partition level stats and synopsis.

Conclusion
Alongside Histograms can also take advantage of this feature as they can be derived/aggregated from partition level histogram to build table level histogram. If there is change in method_opt while gathering stats resulting in new histogram on partition then whole table has to be scan using a small sample to build table level histogram. This saves huge amount of time and resource required to build histogram as each histogram will add another burden to dbms_stats processing. Its important to keep in mind that histogram data is not stored in synopsis but global histogram can be derived from partition level histograms by leveraging Incremental statistics gathering feature.

In case of indexes it doesn't use Incremental strategy, so to gather higher level statistics for partitioned indexes it scans complete index with lower sample size and time required to gather it is directly proportional to index size.

Using Incremental Statistics gathering in 11g was painful due to limited control over it, but in 12c we have great control over the behavior of Incremental Statistics gathering. Enhancements in 12c has made this feature prominent in warehousing environment by saving huge amount of resources for gathering expensive global partitioned statistics.




---#################my_solution###############################--

---------------------Common step for all tables which have been repartitioned ------------------------------
--it has been already applied for ('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC'); 

--3.Implementing of incremental statistic

/*
Implementation
To enable Incremental Statistics feature for each table we need to ensure that
The INCREMENTAL value for the partitioned table is true.(Default is FALSE) - item 3.1.1.
The PUBLISH value for the partitioned table is true.(Default is TRUE)      - item 3.1.2.
The user specifies AUTO_SAMPLE_SIZE for ESTIMATE_PERCENT and AUTO for GRANULARITY when gathering statistics on the table. - item 3.1.3.
(Default is ESTIMATE_PERCENT=>AUTO_SAMPLE_SIZE and GRANULARITY=>AUTO)
*/

  
--3.1.1 Checking\Enabling synopses and other properties
--Checking that incremental maintenance is enabled
--The value of the DBMS_STATS preference can be checked as follows:
--uncomment and put table name if want to check properties for one table 
/*
SELECT dbms_stats.get_prefs(pname       => 'INCREMENTAL',
                            ownname     => 'EXTSTG',
                            tabname     => 'RB_FINANCIAL_EVENTS_11_ARC') 
FROM dual;
*/

--or cheack for list of tables
set serveroutput on size unlimited
declare
type t_tbl is table of varchar2(50);
v_tbl       t_tbl;
v_perf      varchar2(10 char);
v_owner     varchar2(30) :='EXTSTG';

begin
v_tbl:= t_tbl('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC');

for i in v_tbl.first..v_tbl.last
    loop
      select dbms_stats.get_prefs(pname     =>'INCREMENTAL',
                                  ownname   => v_owner,
                                  tabname   =>v_tbl(i)) into v_perf
      from dual;
dbms_output.put_line(v_perf);
end loop;
end;
/

--if FALSE then

--To enable the creation of synopses, a table must be configured to use incremental maintenance. 
--This feature is switched on using a DBMS_STATS preference called ‘INCREMENTAL’.

--uncomment and put table name if want to set properties for one table 
--call dbms_stats.set_table_prefs('EXTSTG','RB_FINANCIAL_EVENTS_11_ARC','INCREMENTAL','TRUE');

--or set for list of tables
set serveroutput on size unlimited
declare
type t_tbl is table of varchar2(50);
v_tbl       t_tbl;
v_owner     varchar2(30) :='EXTSTG';

begin
v_tbl:= t_tbl('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC');

for i in v_tbl.first..v_tbl.last
    loop
      dbms_stats.set_table_prefs(v_owner, v_tbl(i),'INCREMENTAL','TRUE');
end loop;
end;
/

--3.1.2. Also check if PUBLISH attribute is true. default is true

select dbms_stats.get_prefs ('PUBLISH','EXTSTG','RB_FINANCIAL_EVENTS_11_ARC') publish
from dual;

--3.1.3.check if AUTO_SAMPLE_SIZE for ESTIMATE_PERCENT and AUTO for GRANULARITY

select
dbms_stats.get_prefs('ESTIMATE_PERCENT','EXTSTG','RB_FINANCIAL_EVENTS_11_ARC') estimate_percent,
dbms_stats.get_prefs('GRANULARITY','EXTSTG','RB_FINANCIAL_EVENTS_11_ARC') granularity
from dual;


--3.2. Checking\Enabling option for incremental refresh


--option to allow multiple DML changes to occur against a partition or sub-partition before it is a target for incremental refresh. 
declare
type t_tbl is table of varchar2(50);
v_tbl       t_tbl;
v_owner     varchar2(30) :='EXTSTG';

begin
v_tbl:= t_tbl('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC');

for i in v_tbl.first..v_tbl.last
    loop
      dbms_stats.set_table_prefs(v_owner, v_tbl(i),'INCREMENTAL_STALENESS','USE_STALE_PERCENT');
end loop;
end;  
/

--Trick is to create synopsis for each partition in a controlled manner by using GRANULARITY=>PARTITION

set timing on
declare
cursor prt_cur(ip_table_name sys.DBMSOUTPUT_LINESARRAY, ip_table_owner varchar2)
is
select table_name,
           partition_name
      FROM all_tab_partitions atp
        join table(ip_table_name) p
        on atp.table_name = p.column_value;

v_table_name_list sys.DBMSOUTPUT_LINESARRAY;
v_owner varchar2(30) :='EXTSTG';

begin
  v_table_name_list:= sys.DBMSOUTPUT_LINESARRAY('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC');

  for i_cursor in prt_cur(v_table_name_list, v_owner) loop
  --    dbms_output.put_line(i_cursor.table_name||' - '||i_cursor.partition_name);
  dbms_stats.gather_table_stats(v_owner, i_cursor.table_name, partname=>i_cursor.partition_name,ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, granularity=>'PARTITION');

  end loop;
end;
/


--or run letter with dbms_scheduler
begin
    dbms_scheduler.create_job 
    (  
      job_name      =>  'One_Time_EXTSTG_GATH_ST_Job',  
      job_type      =>  'PLSQL_BLOCK',  
      job_action    =>  'declare
                            cursor prt_cur(ip_table_name sys.DBMSOUTPUT_LINESARRAY, ip_table_owner varchar2)
                            is
                            select table_name, partition_name
                                  FROM all_tab_partitions atp
                                    join table(ip_table_name) p
                                    on atp.table_name = p.column_value;
                            v_table_name_list sys.DBMSOUTPUT_LINESARRAY;
                            v_owner varchar2(30) :=''EXTSTG'';
                            begin
                              v_table_name_list:= sys.DBMSOUTPUT_LINESARRAY(''RB_FINANCIAL_EVENTS_11_ARC'',''RB_AGREEMENTS_11_ARC'',''RB_PARTY_NUMBERS_10_ARC'', ''RB_PARTIES_11_ARC'');
                              for i_cursor in prt_cur(v_table_name_list, v_owner) loop
                              dbms_stats.gather_table_stats(v_owner, i_cursor.table_name, partname=>i_cursor.partition_name, granularity=>''PARTITION'');
                              end loop;
                            end;',  
      start_date    =>  sysdate+1,  
      enabled       =>  TRUE,  
      auto_drop     =>  TRUE,  
      comments      =>  'one-time job');
  end;
  /



--and then gather global which will use previously created synopsis and partition level statistics.

set timing on
declare
v_table_name_list sys.DBMSOUTPUT_LINESARRAY;
v_owner varchar2(30) :='EXTSTG';

begin
v_table_name_list:= sys.DBMSOUTPUT_LINESARRAY('RB_FINANCIAL_EVENTS_11_ARC','RB_AGREEMENTS_11_ARC', 'RB_PARTY_NUMBERS_10_ARC', 'RB_PARTIES_11_ARC');
    for i_cursor in (select column_value from table(v_table_name_list)) loop
    --    dbms_output.put_line(i_cursor.table_name||' - '||i_cursor.partition_name);
    dbms_stats.gather_table_stats(v_owner, i_cursor.column_value, degree=>4);
    end loop;
end;
/

--After all you just need to add into appropriate pkg a procedure which will gather statistic only for last partition
--And process of gathering Global statistics for those tables should take seconds instead of hours

