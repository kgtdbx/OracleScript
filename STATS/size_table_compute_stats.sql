
--To get the main default settings
select dbms_stats.get_prefs(pname => 'METHOD_OPT') method_opt_def,
       dbms_stats.get_prefs(pname => 'CASCADE') cascade_def, 
       dbms_stats.get_prefs(pname => 'DEGREE') degree_def, 
       dbms_stats.get_prefs(pname => 'ESTIMATE_PERCENT') estimate_percent_def  
 from dual;


--dbms_stats with examples
https://www.morganslibrary.org/reference/pkgs/dbms_stats.html

/*
Statistics should be gathered as a part of any process that significantly changes the data. Do not rely on nightly jobs to gather statistics, especially in a large data warehouse.

Gathering statistics only in nightly jobs has many potential disadvantages:

The processing has a weird time dependency. Statistics windows can be tricky to coordinate. And sometimes if there's too much work the table you care about may not have time to get analyzed.
There are several types of statistics jobs (scheduler jobs, DBA_JOBS, auto_tasks), all of which tend to get disabled more than they should.
Gathering statistics at the wrong time is much worse than not having statistics at all. If there are no statistics then Oracle can use dynamic sampling to do a decent job. But if the nightly job just happens to gather statistics during the brief period where the table is empty, the statistics may be horribly wrong and performance will suffer. I've seen this happen many times; these errors tend to get blamed on "environmental differences", but if you leave a critical step up to chance then environments are going to randomly fail.
Gathering statistics as part of your data load process has many potential advantages. Since you understand the process and the table better than some generic nightly statistics job you can take advantage of many advanced features:

If the system isn't busy after the data load then parallelism can be used with a parameter like DEGREE=>8.
If it's a direct-path write in 12c you may be able to automatically gather stats while loading data with the GATHER_OPTIMIZER_STATISTICS hint.
If it's an interval partitioned table you may want to setup incremental statistics gathering. This lets the process only spend time gathering statistics for the partition and the global statistics are updated for free.
If the process disabled and rebuilds indexes it can avoid re-gathering index statistics with the parameter NOCASCADE=>TRUE.
Don't outsource statistics gathering to some other scheduled job. Statistics are so important and tricky that they should be fully integrated with any program that is making significant data changes.

 */
 
 /*
 /*
In this scenario the new AUTO_SAMPLE_SIZE algorithm was 9 times faster than the 100% sample and
only 2.4 times slower than the 1 % sample, while the quality of the statistics it produced were nearly
identical to a 100% sample (not different enough to change the execution plans). Note the timings for
this experiment may vary on your system and the larger the data set, the more speedup you will
encounter from the new algorithm.
It is highly recommended from Oracle Database 11g onward you let ESTIMATE_PERCENT default. If
you manually set the ESTIMATE_PERCENT parameter, even if it is set to 100%, you will get the old
statistics gathering algorithm. 
*/


/*
"You should disable the
PARALLEL_ADAPTIVE_MULTI_USER initialization parameter to prevent the parallel jobs from being
down graded to serial."

However, I checked the setting of that parameter in our database, and it is already set to FALSE:

SQL> sho parameter parallel_adaptive_multi_user
 
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
parallel_adaptive_multi_user         boolean     FALSE


Concurrent stats gathering seems to be turned off for us:

SQL> select dbms_stats.get_prefs(pname => 'CONCURRENT') from dual;
 
DBMS_STATS.GET_PREFS(PNAME=>'C
--------------------------------------------------------------------------------
FALSE

So I understand that we would not be getting inter object parallelism, however I'm still confused why we're not getting intra object parallelism. The tables we're trying to analyze have 100M+ rows, which seems like it'd be enough to benefit from parallel execution.
*/

 
 -------------------собрать статистику по таблице---------------
 begin    
  dbms_stats.gather_table_stats(user, 'ST_FT_ECP_PAF_CARR_SC_CDMA');
 end;
------------------
 analyze table t1 compute statistics for table for all indexes for all indexed columns;
 
 begin
 dbms_stats.gather_table_stats(ownname =>'BARS', tabname => 'OPER_ALL', method_opt=> 'FOR ALL INDEXED COLUMNS', degree=>4, cascade=>dbms_stats.auto_cascade, estimate_percent=>10);
end;

--after 11g estimate_percent should be AUTO_SAMPLE_SIZE, because it doesn't Unable to gather table stats in parallel(degree=>4 doesn't give any effects)
--It will most likely be due to your estimate_percent. Change it to AUTO (which is a good thing to do anyway).
 begin
 dbms_stats.gather_table_stats(ownname =>'BARS', tabname => 'OPER_ALL', method_opt=> 'FOR ALL INDEXED COLUMNS', degree=>4, cascade=>dbms_stats.auto_cascade, estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);
end;
------------------ 
/*
Усли статистика оптимизатора для таблицы "OFSAA1"."STG_LEDGER_STAT" и ее индексов
устарела.
*/

-- Рекомендуется собрать статистику оптимизатора для этой таблицы.
execute dbms_stats.gather_table_stats(ownname => 'OFSAA1', 
                                      tabname => 'STG_LEDGER_STAT', 
                                      estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, 
                                      method_opt => 'FOR ALL COLUMNS SIZE AUTO');
----------------------------
--Сбор статистики для секционированных объектов
CALL DBMS_STATS.GATHER_TABLE_STATS(
                                    ownname => 'DEMO', 
                                    tabname => 'SALES',
                                    partname => 'SALES_99Q1',
                                    granularity => 'PARTITION');
CALL DBMS_STATS.GATHER_INDEX_STATS(
ownname => 'DEMO', indname => 'SALES_IDX',
partname => 'SALES_99Q1_IDX');
ANALYZE TABLE sales PARTITION (SALES_99Q1)
VALIDATE STRUCTURE INTO INVALID_ROWS;
--• Для секционированных объектов отдельно поддерживается
--статистика для самих объектов, их секций и подсекций
--• Регулируется параметром GRANULARITY
--• ALL, GLOBAL, DEFAULT, PARTITION, SUBPARTITION
--• На практике чаще используют GRANULARITY=ALL
-----
--Получаем размер блока базы данных и соответственно размер таблицы. 
Select bytes / blocks from dba_segments;

analyze table X compute statistics;
select  avg_space * blocks / 1024 /1024 as MB from dba_tables where table_name = 'X';
-----
SELECT a.owner "Схема",
       a.TABLE_NAME "Таблица",
       b.bytes "Размер (Мб)",
       TRUNC((a.blocks * 100) / b.blocks) "Занято(%)",
       b.extents "Экстентов"
FROM sys.all_tables a,
     (
        SELECT owner, segment_name, SUM(bytes)/1024/1024 bytes,
               SUM(blocks) blocks, COUNT(*) extents
          FROM sys.dba_extents
         WHERE segment_type = 'TABLE'
      GROUP BY owner, segment_name
     ) b
WHERE a.owner = 'SB_DWH_TEST' AND a.TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA' AND
      a.owner = b.owner AND a.TABLE_NAME = b.segment_name;

--Размер таблицы (с фрагментацией):
SELECT TABLE_NAME, ROUND((BLOCKS * 8)/1024, 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA';
--Реальные данные:
SELECT TABLE_NAME, ROUND((NUM_ROWS * AVG_ROW_LEN / 1024 / 1024), 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA';

--*********************************************************--



--############################################################
-- not use degree=> for small table, degree=>4 for table size 200 Mb - 4 Gb, degree=>32 for big table
--
--Concurrent statistics gathering
--set parametr job_que_process = 32
--grant create job, manage scheduler, manage any queue to bars
--
alter system set parallel_adaptive_multi_user=false;

begin
dbms_stats.set_global_prefs('CONCURRENT', 'TRUE');
end;
/
BEGIN
  SYS.DBMS_STATS.GATHER_SCHEMA_STATS (
     OwnName           => 'BARS'
    ,Granularity       => 'DEFAULT'
    ,Options           => 'GATHER'
    ,Gather_Temp       => FALSE
    ,Estimate_Percent  => NULL
    ,Method_Opt        => 'FOR ALL INDEXED COLUMNS'
    ,Degree            => 20
    ,Cascade           => TRUE
    ,No_Invalidate     => FALSE);
END;
/
---от Кикотя--
BEGIN
  SYS.DBMS_STATS.GATHER_SCHEMA_STATS (
     OwnName           => 'BARS'
    ,Granularity       => 'DEFAULT'
    ,Options           => 'GATHER'
    ,Gather_Temp       => FALSE
    ,Estimate_Percent  => NULL
    ,Method_Opt        => 'FOR ALL INDEXED COLUMNS'
    ,Degree            => 16
    ,Cascade           => TRUE
    ,No_Invalidate  => FALSE);
END;

exec dbms_stats.set_global_prefs('concurrent','true');

select dbms_stats.get_prefs('concurrent') from dual
----
begin
 dbms_stats.gather_schema_stats(ownname =>'BARS', 
                                method_opt=> 'FOR ALL INDEXED COLUMNS', 
                                degree=>32, 
                                cascade=>dbms_stats.auto_cascade, 
                                estimate_percent=>10);
end;

begin
 dbms_stats.gather_table_stats(ownname =>'BARS', 
                               tabname => 'OPER', 
                               method_opt=> 'FOR ALL INDEXED COLUMNS', 
                               degree=>32, 
                               cascade=>dbms_stats.auto_cascade, 
                               estimate_percent=>10);
end;

call dbms_stats.gather_table_stats(ownname => 'BARS', 
                                   tabname =>'BPK_ACC_UPDATE', 
                                   estimate_percent =>10, 
                                   method_opt => 'FOR ALL COLUMNS SIZE AUTO');

SELECT A.TABLE_NAME,
A.LAST_ANALYZED,
A.NUM_ROWS, 
A.* 
FROM ALL_TABLES A
WHERE A.OWNER = 'BARS'
AND A.TABLE_NAME = 'CUSTOMERW_UPDATE';
-----*********************************************************-------
--от ОС Консалтинг, без сбора гисторамм(типа это зло)
BEGIN   
SYS.DBMS_STATS.GATHER_SCHEMA_STATS ( OwnName            => 'BARS',
                                     Granularity        => 'DEFAULT',
                                     Options            => 'GATHER',
                                     Gather_Temp        => FALSE,
                                     Estimate_Percent   => NULL,
                                     Method_Opt         => 'FOR ALL COLUMNS SIZE SKEWONLY',
                                     Degree             => 8,
                                     Cascade            => TRUE,
                                     No_Invalidate      => FALSE
                                    ); 
END;
-----*********************************************************-------

declare
  v_table_name varchar2(64) := ''; --your table
  v_key_value number := ;  -- your range value

  v_data_object_id number;
  v_object_name varchar2(64);
  v_object_type varchar2(64);
  v_granularity varchar2(64);
  v_part_name   varchar2(64);
begin
  begin
    for i in (select kc.column_name
              from user_part_key_columns kc
              where kc.name = upper(v_table_name)
                and kc.object_type = 'TABLE')
     loop
       execute immediate 'select /*+ first_rows */ dbms_rowid.rowid_object(rowid)

                          from ' || v_table_name || '
                          where '|| i.column_name || ' = '|| v_key_value || 
                          ' and rownum = 1'
        into v_data_object_id;
     end loop;
  exception
    when no_data_found then
      v_data_object_id := null;
  end;

  begin
    select t.subobject_name, t.OBJECT_TYPE
      into v_object_name, v_object_type
    from user_objects t
    where t.data_object_id = v_data_object_id;
    exception
      when no_data_found then
        v_object_name := null;
  end;

  if v_object_name is null
    then
      dbms_output.put_line ('no data found');
    else
      if v_object_type = 'TABLE SUBPARTITION'
        then 
          v_granularity := 'SUBPARTITION';

          select t.partition_name
            into v_part_name
          from user_tab_subpartitions t
          where t.subpartition_name = v_object_name;

        else
          v_granularity := 'PARTITION';
          v_part_name := v_object_name;
      end if;

      dbms_stats.gather_table_stats (ownname => user
                                    ,tabname => upper(v_table_name)
                                    ,partname => v_part_name
                                    ,granularity => v_granularity
                                    ,cascade => true
                                    ,no_invalidate => false);
  end if;
end;
---------------------------------