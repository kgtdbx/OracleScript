ops$tkyte%ORA11GR2> CREATE TABLE t
  2  (
  3    dt  date,
  4    x   int,
  5    y   varchar2(30)
  6  )
  7  PARTITION BY RANGE (dt)
  8  (
  9    PARTITION part1 VALUES LESS THAN (to_date('13-mar-2003','dd-mon-yyyy')) ,
 10    PARTITION part2 VALUES LESS THAN (to_date('14-mar-2003','dd-mon-yyyy')) ,
 11    PARTITION junk VALUES LESS THAN (MAXVALUE)
 12  )
 13  /

Table created.

ops$tkyte%ORA11GR2> 
ops$tkyte%ORA11GR2> create or replace function get_high_value( p_table_name in varchar2, p_partition_name in varchar2 ) return date
  2  authid current_user
  3  as
  4      l_high_value long;
  5      l_date       date;
  6  begin
  7      select high_value
  8        into l_high_value
  9        from user_tab_partitions
 10       where table_name = p_table_name
 11         and partition_name = p_partition_name;
 12  
 13      if ( l_high_value <> 'MAXVALUE' )
 14      then
 15          execute immediate 'begin :x := ' || l_high_value || '; end;' using OUT l_date;
 16      end if;
 17  
 18      return l_date;
 19  end;
 20  /

Function created.

ops$tkyte%ORA11GR2> 
ops$tkyte%ORA11GR2> select table_name, partition_name, get_high_value( table_name, partition_name )
  2    from user_tab_partitions
  3   where table_name = 'T';

TABLE_NAME                     PARTITION_NAME                 GET_HIGH_
------------------------------ ------------------------------ ---------
T                              JUNK
T                              PART1                          13-MAR-03
T                              PART2                          14-MAR-03
