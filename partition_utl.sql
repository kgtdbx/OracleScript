create or replace package prt_utl is

  -- Author         : serhiib
  -- Created        : 25.10.2017
  -- Add changes    : 13.12.2017 


  function get_data_hv_prt
  ( ip_table_owner  in all_tab_partitions.table_owner%type
  , ip_table_name   in all_tab_partitions.table_name%type
  , ip_pos_prt      in all_tab_partitions.partition_position%type
  ) return date;

  procedure p_execute_immediate(ip_sql in varchar2);

  procedure p_table_intrm_create
   ( ip_owner_from      in varchar2
   , ip_table_from      in varchar2
   , ip_owner_to        in varchar2
   , ip_table_to        in varchar2
   , ip_date            in date default null
   , ip_partition_nm    in varchar2 default null
   , op_interim_tbl     out varchar2
   );

  -- ip_flag_smart: 0 - raise exception if table does not exist, 1 -will not raise exception if table does not exist
  procedure p_table_drop
   ( ip_flag_smart  in number
   , ip_table_owner in varchar2
   , ip_table       in varchar2
   );

  --
  -- exchange partition by name
  --
  procedure p_exchange_partition
  ( ip_source_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_source_table_nm   in     all_tab_partitions.table_name%type
  , ip_target_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_target_table_nm   in     all_tab_partitions.table_name%type
  , ip_partition_nm      in     all_tab_partitions.partition_name%type
  );

  --
  -- exchange partition by condition for
  --
  procedure p_exchange_partition_for
  ( ip_source_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_source_table_nm   in     all_tab_partitions.table_name%type
  , ip_target_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_target_table_nm   in     all_tab_partitions.table_name%type
  , ip_date              in     date
  );

  --
  -- exchange subpartition by name
  --
  procedure p_exchange_subpartition
  ( ip_source_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_source_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_target_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_target_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_subpartition_nm   in     all_tab_subpartitions.subpartition_name%type
  );

  --
  -- exchange subpartition by condition for
  --
  procedure p_exchange_subpartition_for
  ( ip_source_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_source_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_target_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_target_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_condition         in     varchar2
  );

end prt_utl;

/

create or replace package body prt_utl is
  
  -- Author         : serhiib
  -- Created        : 25.10.2017
  -- Add changes    : 13.12.2017 

  -- constants
  c_enter   constant varchar2(2) := chr(13)||chr(10);
  c_quote   constant varchar2(2) := chr(39);

  -- exception
  ref_part_restriction exception;
  pragma exception_init(ref_part_restriction, -14650);

  -- Column type or size mismatch in exchange subpartition
  err_column_mismatch exception;
  pragma exception_init( err_column_mismatch, -14278 );

  -- Index mismatch for tables in exchange subpartition
  err_index_mismatch exception;
  pragma exception_init( err_column_mismatch, -14279 );

  function f_table_exists
  ( ip_table_owner    in varchar2
  , ip_table          in varchar2
  ) return boolean is
   bexist boolean := false;
   nexist number(1);
  begin
    begin
      select 1
      into nexist
      from all_tables u
      where u.owner = upper(ip_table_owner)
      and u.table_name = upper(ip_table);
      bexist := true;
    exception
      when no_data_found then
        bexist := false;
    end;
    return bexist;
  end f_table_exists;

  function get_data_hv_prt
  ( ip_table_owner  in all_tab_partitions.table_owner%type
  , ip_table_name   in all_tab_partitions.table_name%type
  , ip_pos_prt      in all_tab_partitions.partition_position%type
  ) return date is
    l_long long;
  begin
      select high_value into l_long
        from all_tab_partitions
       where table_owner = ip_table_owner
         and table_name = ip_table_name
         and partition_position = ip_pos_prt;

          if ( l_long is not null )
          then
          return to_date(substr( l_long, 11, 10 ), 'yyyy-mm-dd');
          else
            return null;
          end if;
  end get_data_hv_prt;

  procedure p_exception
  ( ip_flag_smart   in number default 0
  , ip_text         in varchar2
  ) is
  begin
    if ip_flag_smart = 0 then
       raise_application_error( -20103, ip_text );
   else
       dbms_output.put_line(ip_text);
   end if;
 end p_exception;

  procedure p_execute_immediate(ip_sql in varchar2)
  is
  l_trace_message         varchar2(32767 byte);
  begin
    l_trace_message := ip_sql;
    execute immediate ip_sql;
  exception when others then
        raise;
  end p_execute_immediate;

  procedure p_table_intrm_create
  ( ip_owner_from      in varchar2
  , ip_table_from      in varchar2
  , ip_owner_to        in varchar2
  , ip_table_to        in varchar2
  , ip_date            in date default null
  , ip_partition_nm    in varchar2 default null
  , op_interim_tbl     out varchar2
  ) is
    v_sql     varchar2(32767 byte);
    v_date    date:=add_months(ip_date, -1); 
    begin
     case when ip_date is not null then
             begin
             op_interim_tbl:=substr(ip_table_to,1,22)||'_'||to_char(v_date,'yyyymm');
             v_sql:= 'CREATE TABLE '||ip_owner_to||'.'||op_interim_tbl||c_enter||
                     ' PARALLEL (DEGREE 4) '||c_enter||
                     ' UNRECOVERABLE '||c_enter||
                     ' AS '||c_enter||
                     ' SELECT * FROM '||ip_owner_from||'.'||ip_table_from||' PARTITION FOR (TO_DATE('||c_quote||to_char(v_date,'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
                     ' WHERE 1=1';
             --dbms_output.put_line(v_sql);
             p_execute_immediate(v_sql);
             end;
          else
                begin
                op_interim_tbl:=substr(ip_table_to,1,22)||'_'||ip_partition_nm;
                v_sql:= 'CREATE TABLE '||ip_owner_to||'.'||op_interim_tbl||c_enter||
                        ' PARALLEL (DEGREE 4) '||c_enter||
                        ' UNRECOVERABLE '||c_enter||
                        ' AS '||c_enter||
                        ' SELECT * FROM '||ip_owner_from||'.'||ip_table_from||' PARTITION ('||ip_partition_nm||') '||c_enter||
                        ' WHERE 1=1';
                --dbms_output.put_line(v_sql);
                p_execute_immediate(v_sql);
                end;
     end case;
  end p_table_intrm_create;

  procedure p_table_drop
  ( ip_flag_smart  in number
  , ip_table_owner in varchar2
  , ip_table       in varchar2
  ) is
    v_sql varchar2(32767 byte);
  begin
    if f_table_exists(ip_table_owner, ip_table) then
       v_sql:= 'drop table '||ip_table_owner||'.'||ip_table;
       --dbms_output.put_line(v_sql);
       p_execute_immediate(v_sql);
    else
       p_exception(ip_flag_smart,'Table '||ip_table_owner||'.'||ip_table||' not exist');
    end if;
  end p_table_drop;

  --
  -- exchange partition by name
  --
  procedure p_exchange_partition
  ( ip_source_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_source_table_nm   in     all_tab_partitions.table_name%type
  , ip_target_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_target_table_nm   in     all_tab_partitions.table_name%type
  , ip_partition_nm      in     all_tab_partitions.partition_name%type
  ) is
    v_sql varchar2(32767 byte);
  begin
    case
      when ( ip_source_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_source_table_nm] must be specified!' );
      when ( ip_target_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_target_table_nm] must be specified!' );
      when ( ip_partition_nm    Is Null )
      then raise_application_error( -20666, 'Parameter [ip_partition_nm] must be specified!' );
      else null;
    end case;

    v_sql:= 'ALTER TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' EXCHANGE PARTITION '||ip_partition_nm||c_enter||
            ' WITH TABLE '||ip_source_owner_nm||'.'||ip_source_table_nm||c_enter||
            ' EXCLUDING INDEXES WITHOUT VALIDATION ';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);

  end p_exchange_partition;

  --
  -- exchange partition by condition for
  --
  procedure p_exchange_partition_for
  ( ip_source_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_source_table_nm   in     all_tab_partitions.table_name%type
  , ip_target_owner_nm   in     all_tab_partitions.table_owner%type
  , ip_target_table_nm   in     all_tab_partitions.table_name%type
  , ip_date              in     date
  ) is
    v_sql     varchar2(32767 byte);
    v_date    date:=add_months(ip_date, -1);
  begin
    case
      when ( ip_source_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_source_table_nm] must be specified!' );
      when ( ip_target_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_target_table_nm] must be specified!' );
      when ( ip_date       Is Null )
      then raise_application_error( -20666, 'Parameter [ip_date] must be specified!' );
      else null;
    end case;
    -- partition is first locked to ensure that the partition is created
    v_sql:= 'LOCK TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' PARTITION FOR (TO_DATE('||c_quote||to_char(v_date,'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
            ' IN SHARE MODE';
    dbms_output.put_line(v_sql);
    --p_execute_immediate(v_sql);
    v_sql:= 'ALTER TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' EXCHANGE PARTITION FOR (TO_DATE('||c_quote||to_char(v_date,'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
            ' WITH TABLE '||ip_source_owner_nm||'.'||ip_source_table_nm||c_enter||
            ' EXCLUDING INDEXES WITHOUT VALIDATION ';
     dbms_output.put_line(v_sql);
     --p_execute_immediate(v_sql);

  end p_exchange_partition_for;

  --
  -- exchange subpartition by name
  --
  procedure p_exchange_subpartition
  ( ip_source_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_source_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_target_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_target_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_subpartition_nm   in     all_tab_subpartitions.subpartition_name%type
  ) is
    v_sql varchar2(32767 byte);
  begin
    case
      when ( ip_source_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_source_table_nm] must be specified!', true );
      when ( ip_target_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_target_table_nm] must be specified!', true );
      when ( ip_subpartition_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_subpartition_nm] must be specified!', true );
      else null;
    end case;
    v_sql:= 'ALTER TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' EXCHANGE SUBPARTITION '||ip_subpartition_nm||c_enter||
            ' WITH TABLE '||ip_source_owner_nm||'.'||ip_source_table_nm||c_enter||
            ' EXCLUDING INDEXES WITHOUT VALIDATION ';

    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);

  end p_exchange_subpartition;

  --
  -- exchange subpartition by condition for
  --
  procedure p_exchange_subpartition_for
  ( ip_source_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_source_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_target_owner_nm   in     all_tab_subpartitions.table_owner%type
  , ip_target_table_nm   in     all_tab_subpartitions.table_name%type
  , ip_condition         in     varchar2
  ) is
  /**
  <b>p_exchange_subpartition_for</b> - EXCHANGE SUBPARTITION without specified SUBPARTITION NAME (by section key)
  %param ip_source_owner_nm - source table owner name
  %param ip_source_table_nm - source table name
  %param ip_target_owner_nm - target table owner name
  %param ip_target_table_nm - target table name
  %param ip_condition       - section key for subpartition
  */
    v_sql varchar2(32767 byte);
  begin
        case
          when ( ip_source_table_nm Is Null )
          then raise_application_error( -20666, 'Parameter [ip_source_table_nm] must be specified!' );
          when ( ip_target_table_nm Is Null )
          then raise_application_error( -20666, 'Parameter [ip_target_table_nm] must be specified!' );
          when ( ip_condition       Is Null )
          then raise_application_error( -20666, 'Parameter [ip_condition] must be specified!' );
          else null;
        end case;

    -- subpartition is first locked to ensure that the partition is created
    v_sql:= 'LOCK TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' SUBPARTITION FOR '||ip_condition||c_enter||
            ' IN SHARE MODE';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);
    begin
    v_sql:= 'ALTER TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' EXCHANGE SUBPARTITION FOR '||ip_condition||c_enter||
            ' WITH TABLE '||ip_source_owner_nm||'.'||ip_source_table_nm||c_enter||
            ' EXCLUDING INDEXES WITHOUT VALIDATION ';
    p_execute_immediate(v_sql);
    exception
      when err_column_mismatch then
        raise err_column_mismatch;
      when err_index_mismatch then
        raise err_index_mismatch;
    end;

  end p_exchange_subpartition_for;

end prt_utl;

/
