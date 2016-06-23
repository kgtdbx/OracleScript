DECLARE
  --:l_table_name varchar2(64);
--  :l_err_table  varchar2(64);
--  :l_field_id   varchar2(64);
  l_insert_field        clob;
  l_where_clause        clob;
  v_gt                  varchar2(4000);
  v_eol                 varchar2(10);
  l_insert0             clob;
  l_insert1             clob;
  l_insert2             clob;
  l_insert3             clob;
  l_insert4             clob;
  l_final_step          clob;

 
  CURSOR cur_fields IS                                                --  FIELDS LIST 
    SELECT lower(column_name)
      FROM user_tab_columns
     WHERE table_name = :l_table_name AND column_name <> 'EFFECTIVE_DT'
     ORDER BY column_id;

/*  CURSOR cur_insert_fields IS                                         --  FIELDS LIST WITH STRAGG
    SELECT stragg(COLUMN_NAME)
      FROM user_tab_columns
     where table_name = :l_table_name
     order by column_id;*/

  CURSOR cur_where_clause IS                                          --WHERE CLAUSE
    select 'or nvl (a.' || lower(c.COLUMN_NAME) || ', ' || case
             when c.DATA_TYPE = 'NUMBER' then
              '-1'
             when c.DATA_TYPE = 'DATE' then
              'to_date (''01.01.0001'', ''DD.MM.YYYY'')'
             else
              '''-1'''
           end || ') <> nvl (b.' || lower(c.COLUMN_NAME) || ', ' || case
             when c.DATA_TYPE = 'NUMBER' then
              '-1'
             when c.DATA_TYPE = 'DATE' then
              'to_date (''01.01.0001'', ''DD.MM.YYYY'')'
             else
              '''-1'''
           end || ')'
      from user_tab_columns c
     where c.table_name = :l_table_name and c.column_name not in ( 'EFFECTIVE_DT', 'CREATOR','CREATE_DATE', 'UPDATED_BY','UPDATE_DATE' )
     order by c.column_id;
  
BEGIN
  v_eol := CHR(10);
 -- OPEN cur_insert_fields;
  OPEN cur_where_clause;
  OPEN cur_fields;

  LOOP
    -- WHERE CLAUSE
  
    EXIT WHEN cur_where_clause%NOTFOUND;
   
 
    l_where_clause := l_where_clause || v_eol ||lpad(' ',15,' ') || v_gt;
   
         FETCH cur_where_clause
      INTO v_gt;

  END LOOP;
  
  v_gt :='1';

  LOOP
    --INSERT1
  
    EXIT WHEN cur_fields%NOTFOUND;
    
     IF v_gt = '1' then NULL; ELSE
    
    l_insert_field := l_insert_field||v_eol||lpad(' ',40,' ') ||v_gt||',';
  
    l_insert0 := l_insert0 || v_eol||lpad(' ',30,' ') || 'v_tt (indx).' || v_gt || ',' ;
      
    l_insert1 := l_insert1 || v_eol||lpad(' ',25,' ')||'v_tt (indx).' || v_gt ||lpad( ' as ',10,' ') || v_gt||',' ;
    
  IF v_gt not in ('creator','create_date') then  
   l_insert2 := l_insert2||v_eol ||lpad( ' ',25,' ') || 'a.' || v_gt || ' = b.' || v_gt || ',' ;
   else NULL; 
   END IF;
    
    l_insert3 := l_insert3 ||v_eol||lpad( ' ',25,' ') || 'b.' || v_gt || ',' ;
    
    l_insert4 := l_insert4 ||v_eol||lpad(' ',15, ' ')||'v_exceptions (i).'||v_gt||':= v_tt (v_indx).'||v_gt||';';
    end if;
   FETCH cur_fields
      INTO v_gt;
    
  
  END LOOP;
     l_where_clause :=ltrim(l_where_clause,'
               
               or');
     l_insert_field :=  rtrim(l_insert_field, ',');
     l_insert0 :=  rtrim(l_insert0, ',');
     l_insert1 :=  rtrim(l_insert1, ',');
     l_insert2 :=  rtrim(l_insert2, ',');
     l_insert3 :=  rtrim(l_insert3, ',');


  :l_final_step := 'procedure p_norm_'||:l_table_name||'_bl (ip_action in varchar2,
                                   ip_curr_row_num in number,
                                   iop_proc_stat_row in out pkg_feed_utils.t_process_stat_row)
  is
    v_sysdate date := sysdate;
           
    cursor cur (p_action in varchar2,
                p_curr_row_num in number)
    is
      select 
        fx0.id_object as bond_coupon_id,
        fx1.id_object as instrument_id,
        --!!!
        (select pkg_feed_common.f_get_clsfnctn_item_id (GC_CTC_COUPON_TYPE, v.bond_coupon_typ) from dual) as bond_coupon_typ_id,
        payment_frequency_no,
        (select pkg_feed_common.f_get_currency_id (v.payment_crncy) from dual) as payment_crncy_id,
        first_coupon_dt,
        previous_coupon_dt,
        next_coupon_dt,
        penultimate_coupon_dt,
        interest_accrual_dt,
        day_qy,
        estimated_coupon_in,
        ex_dividend_day_qy,
        floating_rate_in,
        rate_reset_index_ds,
        next_rate_reset_dt,
        last_rate_reset_dt,
        rate_reset_frequency_day_qy,
        floating_rate_calc_method_ds,
        reset_coupon_rt,
        floating_index_factor_rt,
        base_cpi_ratio_no,
        floating_rate_index_spread_no,
        coupon_rt,
        stepup_coupon_rt,
        stepup_coupon_dt,
        status_cd,
        effective_dt,                        
        -------
        user        as creator,
        v_sysdate   as create_date,
        user        as updated_by,
        v_sysdate   as update_date
      from 
        vw_stg_fi_bond_coupon v,
        fi_xref partition (BOND_COUPON) fx0,      
        fi_xref partition (FINANCIAL_INSTRUMENT) fx1
      WHERE     
         v.pack_id = gv_curr_pack_id and
         v.group_pack = gv_curr_group_pack and
         v.action = p_action and
         ''BOND_COUPON'' = fx0.base_object(+) and
         v.rowid_object = fx0.rowid_object(+) and
         ''FINANCIAL_INSTRUMENT'' = fx1.base_object(+) and
         v.bond_rowid = fx1.rowid_object(+) and
         v.stg_id between p_curr_row_num and p_curr_row_num + c_bulk_size - 1;

    type t_cursor is table of cur%rowtype index by pls_integer;

    v_tt t_cursor;

    procedure error_logging 
    is
      type vt_exception is table of err$_fi_bond_coupon%rowtype index by pls_integer;
      v_exceptions   vt_exception;
      v_indx         PLS_INTEGER;
      
      pragma autonomous_transaction;
    begin
      for i in 1 .. sql%bulk_exceptions.count 
      loop
        v_indx := sql%bulk_exceptions (i).error_index;
        v_exceptions (i).ora_err_number$ := sql%bulk_exceptions (i).error_code;
        v_exceptions (i).ora_err_mesg$ := sqlerrm (sql%bulk_exceptions (i).error_code * -1);
        v_exceptions (i).ora_err_optyp$ := ''U'';
        v_exceptions (i).ora_err_tag$ := gc_upd || '' ,PACK_ID='' || TO_CHAR (gv_curr_pack_id) || '' ,FEED_ID='' || TO_CHAR (gv_curr_feed_id); 
        '  ||l_insert4||'   
      end loop;

      iop_proc_stat_row.rejected := iop_proc_stat_row.rejected + v_exceptions.count;

      forall i in indices of v_exceptions
          insert into err$_fi_bond_coupon values v_exceptions (i);
      commit;
    end error_logging;

  begin
    
    open cur(ip_action, ip_curr_row_num);
    loop
      fetch cur bulk collect into v_tt limit c_bulk_limit_num;

      exit when v_tt.count = 0;

      iop_proc_stat_row.processed := iop_proc_stat_row.processed + v_tt.COUNT;

      gv_xref_in_queue_nt.delete ();

      if ip_action = GC_INS then
              forall indx in indices of v_tt
                 insert into ' || :l_table_name || '(' || l_insert_field || ')
                    VALUES (' || l_insert0 ||
              
              ')
                       log errors into '
              ||:l_err_table || '(''INSERT'' || '' ,PACK_ID='' || TO_CHAR (gv_curr_pack_id) || '' ,FEED_ID='' || TO_CHAR (gv_curr_feed_id)) REJECT LIMIT UNLIMITED;
 
 
              iop_proc_stat_row.inserted :=  iop_proc_stat_row.inserted  + sql%rowcount;
              iop_proc_stat_row.rejected :=  iop_proc_stat_row.processed - iop_proc_stat_row.inserted;

      elsif ip_action = GC_UPD then
        begin
          forall indx in indices of v_tt save exceptions
merge into ' || :l_table_name || ' a
            using (select ' || l_insert1 ||
              
              ' from dual) b
            on (a.' || :l_field_id || ' = b.' || :l_field_id||
              ')
            when matched then
              update set ' || l_insert2 ||
              '
                where ' ||  l_where_clause || '
                   
            when not matched then
                insert (' || l_insert_field || ')
                  values (' || l_insert3 || ');
                    exception
          when dml_errors then
            error_logging ();
        end;
      end if;

      pkg_xref_queue.push_in_queue_bulk (p_xref_in_queue_tt => gv_xref_in_queue_nt, p_priority => gv_curr_priority, p_pack_id => gv_curr_pack_id);

      commit;

      p_set_action_info (iop_proc_stat_row.processed);
    end loop;

    close cur;

    if ip_action = GC_UPD then
      iop_proc_stat_row.inserted := gv_row_count_insert;
      iop_proc_stat_row.updated :=  gv_row_count_update;
      iop_proc_stat_row.not_changed := iop_proc_stat_row.processed - gv_row_count_insert - gv_row_count_update - iop_proc_stat_row.rejected;
    end if;

  end;';

  CLOSE cur_where_clause;
  CLOSE cur_fields;
END;