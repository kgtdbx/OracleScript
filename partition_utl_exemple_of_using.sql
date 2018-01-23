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
       begin
       prt_utl.p_table_intrm_create( ip_owner_from      => v_source_owner_nm
                                   , ip_table_from      => v_source_table_nm
                                   , ip_owner_to        => v_target_owner_nm
                                   , ip_table_to        => v_target_table_nm 
                                   , ip_date            =>  null
                                   , ip_partition_nm    => v_partition_nm
                                   , op_interim_tbl     => v_interim_tbl
                                   );
       prt_utl.p_exchange_partition ( ip_source_owner_nm   => v_target_owner_nm
                                    , ip_source_table_nm   => v_interim_tbl
                                    , ip_target_owner_nm   => v_target_owner_nm
                                    , ip_target_table_nm   => v_target_table_nm
                                    , ip_partition_nm      => v_partition_nm
                                    );
       prt_utl.p_table_drop(ip_flag_smart =>1, ip_table_owner => v_target_owner_nm, ip_table=> v_interim_tbl);
       end;

for i in (select atp.table_owner, atp.table_name, atp.partition_position from all_tab_partitions atp 
          where atp.table_owner = v_source_owner_nm
          and atp.table_name = v_source_table_nm
          and atp.partition_position >= v_position_from
          and atp.partition_position <= v_position_to
          order by atp.partition_position)
loop
select prt_utl.get_data_hv_prt(i.table_owner, i.table_name, i.partition_position) into v_date from dual; 
dbms_output.put_line(v_date);
prt_utl.p_table_intrm_create( ip_owner_from      => v_source_owner_nm
                            , ip_table_from      => v_source_table_nm
                            , ip_owner_to        => v_target_owner_nm
                            , ip_table_to        => v_target_table_nm 
                            , ip_date            => v_date
                            , ip_partition_nm    => null
                            , op_interim_tbl     => v_interim_tbl
                            );
prt_utl.p_exchange_partition_for( ip_source_owner_nm   => v_target_owner_nm
                                , ip_source_table_nm   => v_interim_tbl
                                , ip_target_owner_nm   => v_target_owner_nm
                                , ip_target_table_nm   => v_target_table_nm
                                , ip_date              => v_date
                                );
prt_utl.p_table_drop(ip_flag_smart =>1, ip_table_owner => v_target_owner_nm, ip_table=> v_interim_tbl);
end loop;
end;
/