create or replace package prt_utl is

  -- Author         : serhiib
  -- Created        : 25.10.2017
  -- Add changes    : 13.12.2017

/*=====================================================================================================*/
    type t_par_list is table of varchar2(3000) index by varchar2(3000);
    g_par_list   t_par_list;
/*=====================================================================================================*/
    procedure clear_params;
/*=====================================================================================================*/
    procedure set_parameter(ip_name in varchar2, ip_value in varchar2);
/*=====================================================================================================*/
    function get_parameter(ip_name in varchar2) return varchar2;
/*=====================================================================================================*/
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

  --
  -- INDEXES
  --
  procedure p_index_save         (ip_index in varchar2);
  procedure p_indexes_save       (ip_table in varchar2);
  procedure p_indexes_drop       (ip_owner_nm in varchar2, ip_table_nm in varchar2);
  procedure p_indexes_nonuq_drop
  ( ip_owner_nm in varchar2
  , ip_table_nm in varchar2
  );
  procedure p_index_create
  ( ip_idx_nm               in varchar2
  , ip_idx_type             in varchar2 default null
  , ip_idx_owner_nm         in varchar2
  , ip_idx_compress_tp      in varchar2 default 'NOCOMPRESS'
  , ip_table_nm             in varchar2
  , ip_column_nm            in varchar2
  , ip_tablespace_nm        in varchar2
  );
  procedure p_index_restore      (ip_index in varchar2);
  procedure p_indexes_restore    (ip_table in varchar2, ip_table_from in varchar2);
  
  --
  --  reorganisation table process
  --
  procedure p_turn_intrvl_tbl_into_range
  ( ip_owner_nm   in     all_tables.owner%type
  , ip_table_nm   in     all_tables.table_name%type
  );  

  -- possible parameters ip_interval_by (year, month, day, hour)
  procedure p_turn_range_tbl_into_intrvl
  ( ip_owner_nm     in     all_tables.owner%type
  , ip_table_nm     in     all_tables.table_name%type
  , ip_interval_by  in     varchar2
  );
  
  --
  -- merge partition by name
  --
  procedure p_merge_partition
  ( ip_owner_nm             in     all_tab_partitions.table_owner%type
  , ip_table_nm             in     all_tab_partitions.table_name%type
  , ip_partition_from_nm    in     all_tab_partitions.partition_name%type
  , ip_partition_to_nm      in     all_tab_partitions.partition_name%type
  );
  
  --
  -- split partition by name
  --
  procedure p_split_partition
  ( ip_owner_nm             in     all_tab_partitions.table_owner%type
  , ip_table_nm             in     all_tab_partitions.table_name%type
  , ip_partition_from_nm    in     all_tab_partitions.partition_name%type
  , ip_partition_to_nm      in     all_tab_partitions.partition_name%type
  );  
  
end prt_utl;

create or replace package body prt_utl is

  -- Author         : serhiib
  -- Created        : 25.10.2017
  -- Add changes    : 13.12.2017
/*=====================================================================================================*/
  -- constants
  c_enter   constant varchar2(2) := chr(13)||chr(10);
  c_quote   constant varchar2(2) := chr(39);
/*=====================================================================================================*/
  -- exception
  ref_part_restriction exception;
  pragma exception_init(ref_part_restriction, -14650);

  -- Column type or size mismatch in exchange subpartition
  err_column_mismatch exception;
  pragma exception_init( err_column_mismatch, -14278 );

  -- Index mismatch for tables in exchange subpartition
  err_index_mismatch exception;
  pragma exception_init( err_column_mismatch, -14279 );
/*=====================================================================================================*/
  procedure clear_params is
  begin
    g_par_list.delete;
  end;
/*=====================================================================================================*/
  procedure set_parameter(ip_name in varchar2, ip_value in varchar2) is
  begin
    g_par_list(upper(ip_name)) := ip_value;
  end;

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

/*=====================================================================================================*/
  function get_parameter(ip_name in varchar2) return varchar2
   is
  begin
    return g_par_list(upper(ip_name));
  exception
    when no_data_found then
      return null;
  end;
  
/*=====================================================================================================*/    
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
 
/*=====================================================================================================*/  
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

/*=====================================================================================================*/  
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

/*=====================================================================================================*/    
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
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);
    v_sql:= 'ALTER TABLE '||ip_target_owner_nm||'.'||ip_target_table_nm||c_enter||
            ' EXCHANGE PARTITION FOR (TO_DATE('||c_quote||to_char(v_date,'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
            ' WITH TABLE '||ip_source_owner_nm||'.'||ip_source_table_nm||c_enter||
            ' EXCLUDING INDEXES WITHOUT VALIDATION ';
     --dbms_output.put_line(v_sql);
     p_execute_immediate(v_sql);

  end p_exchange_partition_for;

/*=====================================================================================================*/  
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

 /*=====================================================================================================*/  
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

/*=====================================================================================================*/  
  procedure p_index_drop
  ( ip_owner_nm in varchar2
  , ip_index_nm in varchar2
  ) is
  v_sql  varchar2(32767 byte);
  begin
    v_sql := 'DROP INDEX '||ip_owner_nm||'.'||ip_index_nm;
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);

    exception when others then
    --ORA-22864: cannot ALTER or DROP LOB indexes
    --ORA-02429: cannot drop index used for enforcement of unique/primary key
    if sqlcode=(-22864) then null;
       elsif sqlcode=(-02429) then null;
    else raise; end if;
  end;
 
/*=====================================================================================================*/   
  procedure p_indexes_nonuq_drop
  ( ip_owner_nm in varchar2
  , ip_table_nm in varchar2
  ) is
  v_sql              varchar2(32767 byte);
  begin
    for cur in
      (
       select i.owner, i.index_name
       from all_indexes i
       where i.owner = upper(ip_owner_nm)
         and i.table_name = upper(ip_table_nm)
         and i.uniqueness = 'NONUNIQUE'
      )
    loop
      p_index_drop(cur.owner, cur.index_name);
    end loop;
  end p_indexes_nonuq_drop;
 
/*=====================================================================================================*/  
  procedure p_indexes_drop
  ( ip_owner_nm in varchar2
  , ip_table_nm in varchar2
  ) is
  begin
   for r in
     (
      select ui.owner, ui.index_name
      from all_indexes ui
       where ui.owner = upper (ip_owner_nm)
         and ui.table_name = upper (ip_table_nm)
      )
   loop
      p_index_drop(r.owner, r.index_name);
    end loop;
  end p_indexes_drop;
 
 /*=====================================================================================================*/  
  procedure p_index_create
  ( ip_idx_nm               in varchar2
  , ip_idx_type             in varchar2 default null --LOCAL, GLOBAL
  , ip_idx_owner_nm         in varchar2
  , ip_idx_compress_tp      in varchar2 default 'NOCOMPRESS' --'COMPRESS ADVANCED LOW', 'COMPRESS ADVANCED HIGH'
  , ip_table_nm             in varchar2
  , ip_column_nm            in varchar2
  , ip_tablespace_nm        in varchar2
  ) is
  v_sql              varchar2(32767 byte);
  begin
    v_sql:= 'CREATE INDEX '||ip_idx_owner_nm||'.'|| ip_idx_nm||c_enter||
            ' ON '||ip_idx_owner_nm||'.'|| ip_table_nm||' ('||ip_column_nm||') '||ip_idx_compress_tp||' '||ip_idx_type||c_enter||
            ' TABLESPACE '||ip_tablespace_nm||c_enter||
            ' PARALLEL (DEGREE 4)';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);

    exception when others then
    raise;
  end p_index_create;
  
/*=====================================================================================================*/  
  function f_index_get_metadata
  ( ip_index in varchar2
  ) return clob
  is
   cbuffer      clob;
   cresult      clob;
   nhandle      number;
   nddl_handle  number;
   sobject_type varchar2(19) := 'INDEX';
  begin
   dbms_lob.createtemporary(cresult, true);
   nhandle := dbms_metadata.open(sobject_type);
   dbms_metadata.set_filter(nhandle, 'NAME', ip_index);
   nddl_handle  := dbms_metadata.add_transform(nhandle, 'DDL');
   dbms_metadata.set_transform_param(nddl_handle, 'STORAGE', false);
   loop
     cbuffer := dbms_metadata.fetch_clob(nhandle);
     if cbuffer is null then
       exit;
     else
       dbms_lob.append(cresult, cbuffer);
     end if;
   end loop;

   return cresult;

  end f_index_get_metadata;

/*=====================================================================================================*/   
  procedure p_object_save
  ( ip_object_name in varchar2
  , ip_sql_text    in clob
  ) is
  begin
   prt_utl.clear_params();
   prt_utl.set_parameter(ip_object_name, ip_sql_text);      
  end p_object_save;

/*=====================================================================================================*/  
  procedure p_index_save
  ( ip_index in varchar2
  ) is
  csql_text clob;
  begin
    csql_text := f_index_get_metadata(ip_index);
    p_object_save('i_index', csql_text);
  end p_index_save;

/*=====================================================================================================*/   
  procedure p_indexes_save
  ( ip_table in varchar2
  ) is
  ncount number;
  begin
    if ltrim(ip_table)is null then
       p_exception(0,'No table name is specified');
    end if;

    for cur in
      (
       select u.index_name
       from user_indexes u
       where u.index_type <> 'LOB'
         and u.table_name = ip_table
       )
    loop
      p_index_save(cur.index_name);
    end loop;
    commit;
  end p_indexes_save;

/*=====================================================================================================*/ 
  procedure p_object_restore
  ( ip_sql_text in clob
  ) is
  pragma autonomous_transaction;
  ssql_text clob;
  begin
    p_execute_immediate(ip_sql_text);
    --dbms_output.put_line(ip_sql_text);
    exception
    when no_data_found then
      commit;
    when others then
    --ORA-14024: number of partitions of LOCAL index must equal that of the underlying table
    if  sqlcode=(-14024) then null;
        else raise; end if;
  end p_object_restore;

/*=====================================================================================================*/ 
  procedure p_index_restore
  ( ip_index in varchar2
  ) is
  csql_text clob;
  begin
    select prt_utl.get_parameter('i_index') into csql_text FROM dual;
    p_object_restore(csql_text);
  end p_index_restore;

/*=====================================================================================================*/ 
  procedure p_indexes_restore
  ( ip_table in varchar2
  , ip_table_from in varchar2
  ) is
  begin
    if ltrim(ip_table)is null then
       p_exception(0,'No table name is specified');
    end if;

    if not f_table_exists('some_owner', ip_table) then
       p_exception(0,'Table '||ip_table||' not exists');
    end if;

   /*for cur in
     (
      select t.object_name, t.object_type, t.table_name 
      from ddl_utils_store t
      where t.table_name = ip_table
        and t.object_type = 'INDEX'
        and not exists (select 1
                        from user_indexes u
                        where u.index_name = t.object_name)
      )
   loop
     p_object_restore(cur.object_name, cur.object_type,  cur.table_name);
   end loop;*/

  end p_indexes_restore;

/*=====================================================================================================*/ 
  procedure p_turn_intrvl_tbl_into_range
  ( ip_owner_nm   in     all_tables.owner%type
  , ip_table_nm   in     all_tables.table_name%type
  ) is
  v_sql              varchar2(32767 byte);
  begin
    v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||' SET INTERVAL ()';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);
  exception when others then 
   --ORA-14757: Table is already a range partitioned table
   if sqlcode=(-14757) then null;
   else raise; end if;
  
  end p_turn_intrvl_tbl_into_range;

/*=====================================================================================================*/   
  procedure p_turn_range_tbl_into_intrvl
  ( ip_owner_nm      in  all_tables.owner%type
  , ip_table_nm      in  all_tables.table_name%type
  , ip_interval_by   in  varchar2
  ) is
  v_interval_type    varchar2(100 byte);
  v_sql              varchar2(32767 byte);
  begin
    v_interval_type:=upper(regexp_replace(ip_interval_by, '[[:space:]]*',''));
           case when v_interval_type = 'YEAR'
              then v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||' SET INTERVAL(NUMTOYMINTERVAL(1,''YEAR''))';
           when v_interval_type = 'MONTH'
              then v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||' SET INTERVAL(NUMTOYMINTERVAL(1,''MONTH''))';
           when v_interval_type = 'DAY'
              then v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||' SET INTERVAL(NUMTODSINTERVAL(1,''DAY''))';
           when v_interval_type = 'HOUR'
              then v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||' SET INTERVAL(NUMTODSINTERVAL(1,''HOUR''))';
           else raise_application_error( -20666, 'Parameter [ip_interval_by] must be specified as interval type! Please choose another one like as year, month, day, hour.' );
           end case;
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);
  exception when others then raise;
  
  end p_turn_range_tbl_into_intrvl;

/*=====================================================================================================*/   
  --
  -- merge partition
  --
  procedure p_merge_partition
  ( ip_owner_nm             in     all_tab_partitions.table_owner%type
  , ip_table_nm             in     all_tab_partitions.table_name%type
  , ip_partition_from_nm    in     all_tab_partitions.partition_name%type
  , ip_partition_to_nm      in     all_tab_partitions.partition_name%type
  ) is
    v_sql varchar2(32767 byte);
  begin
    case
      when ( ip_owner_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_owner_nm] must be specified!' );
      when ( ip_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_table_nm] must be specified!' );
      when ( ip_partition_from_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_partition_from_nm] must be specified!' );
      else null;
    end case;

    v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||c_enter||
            ' MERGE PARTITIONS '||ip_partition_from_nm||c_enter||
            ' INTO PARTITION '||ip_partition_to_nm;
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);

  end p_merge_partition;
  
/*=====================================================================================================*/ 
  --
  -- split partition
  --
  procedure p_split_partition
  ( ip_owner_nm             in     all_tab_partitions.table_owner%type
  , ip_table_nm             in     all_tab_partitions.table_name%type
  , ip_partition_from_nm    in     all_tab_partitions.partition_name%type
  , ip_partition_to_nm      in     all_tab_partitions.partition_name%type
  ) is
    v_sql                   varchar2(32767 byte);
    v_date_from             date;
    v_date_to               date;
    v_cnt                   number:=0;
    v_partition_to_nm       varchar2(30 char);
    v_partition_lst_nm      varchar2(30 char);
  begin
    case
      when ( ip_owner_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_owner_nm] must be specified!' );
      when ( ip_table_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_table_nm] must be specified!' );
      when ( ip_partition_from_nm Is Null )
      then raise_application_error( -20666, 'Parameter [ip_partition_from_nm] must be specified!' );
      else null;
    end case;
    execute immediate 'select count(cnt) from( select to_char(reference_date, ''mm.yyyy'') as cnt '||c_enter||
                      ' from '||ip_owner_nm||'.'||ip_table_nm||' partition ('||ip_partition_from_nm||') group by to_char(reference_date, ''mm.yyyy''))' into v_cnt;
    --dbms_output.put_line(v_cnt);
    v_cnt:=v_cnt-2;
    execute immediate 'select trunc(min(reference_date),''mm''), trunc(max(reference_date),''mm'') from '||ip_owner_nm||'.'||ip_table_nm||' partition ('||ip_partition_from_nm||')' 
       into v_date_from, v_date_to;
    
    for i in 1..v_cnt loop
    v_partition_to_nm := 'M'||to_char(add_months(v_date_from,+i-1),'MM')||'_'||to_char(add_months(v_date_from,+i-1), 'YYYY');
    v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||c_enter||
            ' SPLIT PARTITION '||ip_partition_from_nm||' at(to_date('||c_quote||to_char(add_months(v_date_from,+i),'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
            ' INTO (PARTITION '||v_partition_to_nm||', PARTITION '||ip_partition_from_nm||')';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);    
    end loop;
    v_partition_to_nm := 'M'||to_char(add_months(v_date_to,-1), 'MM')||'_'||to_char(add_months(v_date_to,-1), 'YYYY');
    v_partition_lst_nm := 'M'||to_char(v_date_to,'MM')||'_'||to_char(v_date_to,'YYYY');
    v_sql:= 'ALTER TABLE '||ip_owner_nm||'.'||ip_table_nm||c_enter||
            ' SPLIT PARTITION '||ip_partition_from_nm||' at(to_date('||c_quote||to_char(v_date_to,'dd-mm-yyyy')||c_quote||',''dd-mm-yyyy''))'||c_enter||
            ' INTO (PARTITION '||v_partition_to_nm||', PARTITION '||v_partition_lst_nm||')';
    --dbms_output.put_line(v_sql);
    p_execute_immediate(v_sql);    
  end p_split_partition;

/*=====================================================================================================*/ 

end prt_utl;