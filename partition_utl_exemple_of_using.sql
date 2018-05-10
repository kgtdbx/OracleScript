--##################################--
set serveroutput on
declare
v_date date;
v_source_owner_nm   varchar2(30 char) := 'VERDANDI';
v_source_table_nm   varchar2(30 char) := 'STG_DEPOSITS_AGREEMENTS_ARC';
v_target_owner_nm   varchar2(30 char) := 'BIFROST';
v_target_table_nm   varchar2(30 char) := 'TST_DEPOSITS_AGREEMENTS_ARC';
v_position_from     number := 2;
v_position_to       number := 4;
v_partition_nm      varchar2(30 char) := 'OLD';      
v_interim_tbl       varchar2(30 char) := '';

begin
       -- block for OLD partition with ordinary exchange way 
       begin
       -- create interim table as obligatory condition of exchange partitions process
       prt_utl.p_table_intrm_create( ip_owner_from      => v_source_owner_nm
                                   , ip_table_from      => v_source_table_nm
                                   , ip_owner_to        => v_target_owner_nm
                                   , ip_table_to        => v_target_table_nm 
                                   , ip_date            =>  null
                                   , ip_partition_nm    => v_partition_nm
                                   , op_interim_tbl     => v_interim_tbl
                                   );
       -- ordinary exchange partition way
       prt_utl.p_exchange_partition ( ip_source_owner_nm   => v_target_owner_nm
                                    , ip_source_table_nm   => v_interim_tbl
                                    , ip_target_owner_nm   => v_target_owner_nm
                                    , ip_target_table_nm   => v_target_table_nm
                                    , ip_partition_nm      => v_partition_nm
                                    );
       -- drop interim table
       prt_utl.p_table_drop(ip_flag_smart =>1, ip_table_owner => v_target_owner_nm, ip_table=> v_interim_tbl);
       end;

-- open for cursor to retrieve all needed partitions information of source table          
for i in (select atp.table_owner, atp.table_name, atp.partition_position from all_tab_partitions atp 
          where atp.table_owner = v_source_owner_nm
          and atp.table_name = v_source_table_nm
          and atp.partition_position >= v_position_from
          and atp.partition_position <= v_position_to
          order by atp.partition_position)
loop
-- find the date for partition exchange on the basis of cursor information
select prt_utl.get_data_hv_prt(i.table_owner, i.table_name, i.partition_position) into v_date from dual; 
-- dbms_output.put_line(v_date);
-- create interim table as obligatory condition of exchange partitions process
prt_utl.p_table_intrm_create( ip_owner_from      => v_source_owner_nm
                            , ip_table_from      => v_source_table_nm
                            , ip_owner_to        => v_target_owner_nm
                            , ip_table_to        => v_target_table_nm 
                            , ip_date            => v_date
                            , ip_partition_nm    => null
                            , op_interim_tbl     => v_interim_tbl
                            );
-- exchange partition process for interval partitioned table
prt_utl.p_exchange_partition_for( ip_source_owner_nm   => v_target_owner_nm
                                , ip_source_table_nm   => v_interim_tbl
                                , ip_target_owner_nm   => v_target_owner_nm
                                , ip_target_table_nm   => v_target_table_nm
                                , ip_date              => v_date
                                );
-- drop interim table
prt_utl.p_table_drop(ip_flag_smart =>1, ip_table_owner => v_target_owner_nm, ip_table=> v_interim_tbl);
end loop;
--gather statistics block
dbms_stats.gather_table_stats( ownname          => v_owner_nm,
                               tabname          => v_table_nm,
                               estimate_percent => dbms_stats.auto_sample_size,
                               method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',
                               cascade          => true,
                               degree           => 4);
end;
/

--################# manage table block#################--
set serveroutput on
declare
v_owner_nm                  varchar2(30 char) := 'BIFROST';
v_table_nm                  varchar2(30 char) := 'TST_DEPOSITS_AGREEMENTS_ARC';
v_position_from             number := 2;
v_position_to               number := 5;
v_partition_from_nm         varchar2(3000 char) := null;
v_partition_to_nm           varchar2(30 char) := 'ALL_PRT';

begin
--drop indexes block
prt_utl.p_indexes_drop(ip_owner_nm=> v_owner_nm, ip_table_nm=> v_table_nm);

--transform table block
prt_utl.p_turn_intrvl_tbl_into_range(ip_owner_nm=> v_owner_nm, ip_table_nm=> v_table_nm);

--merge partition block
select listagg(atp.partition_name, ',') within group(order by atp.partition_position) prt_name, 
       atp.table_owner, atp.table_name into v_partition_from_nm, v_owner_nm, v_table_nm
            from all_tab_partitions atp 
           where atp.table_owner = v_owner_nm
             and atp.table_name = v_table_nm
             and atp.partition_position >= v_position_from
             and atp.partition_position <= v_position_to
           group by atp.table_owner, atp.table_name;
           
prt_utl.p_merge_partition( ip_owner_nm           => v_owner_nm
                         , ip_table_nm           => v_table_nm
                         , ip_partition_from_nm  => v_partition_from_nm
                         , ip_partition_to_nm    => v_partition_to_nm
                         );

--split partition block
v_partition_from_nm:= 'ALL_PRT';
v_partition_to_nm:= null;
prt_utl.p_split_partition
  ( ip_owner_nm             => v_owner_nm
  , ip_table_nm             => v_table_nm
  , ip_partition_from_nm    => v_partition_from_nm
  , ip_partition_to_nm      => v_partition_to_nm
  );

--index creation block
prt_utl.p_index_create
  ( ip_idx_nm           => 'IX_TST_DEP_AGR_ARC_AI_RD'
  , ip_idx_type         => 'LOCAL'
  , ip_idx_owner_nm     => v_owner_nm
  , ip_idx_compress_tp  => 'COMPRESS ADVANCED LOW'
  , ip_table_nm         => v_table_nm
  , ip_column_nm        => 'AGREEMENT_ID, REFERENCE_DATE'
  , ip_tablespace_nm    => 'STAGING'
  );
prt_utl.p_index_create
  ( ip_idx_nm           => 'IX_TST_DEP_AGR_ARC_OPS'
  , ip_idx_type         => null
  , ip_idx_owner_nm     => v_owner_nm
  , ip_idx_compress_tp  => 'COMPRESS ADVANCED LOW'
  , ip_table_nm         => v_table_nm
  , ip_column_nm        => 'OWNER_PARTY_SSN'
  , ip_tablespace_nm    => 'STAGING'
  ); 

--transform table block
prt_utl.p_turn_range_tbl_into_intrvl(ip_owner_nm=> v_owner_nm, ip_table_nm=> v_table_nm, ip_interval_by => 'month');

--gather statistics block
dbms_stats.gather_table_stats( ownname          => v_owner_nm,
                               tabname          => v_table_nm,
                               estimate_percent => dbms_stats.auto_sample_size,
                               method_opt       => 'FOR ALL COLUMNS SIZE SKEWONLY',
                               cascade          => true,
                               degree           => 4);
end;
/