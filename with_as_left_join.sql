with a as
(select g.id_object opt from stg_c_gr_opt_contr_alt_id_upd s,
gmld_xref partition(OPTION_CONTRACT) g
where s.xchng_trdd_opt_cntrct_id = g.rowid_object
and s.pack_id = 1638300
and s.group_pack = 992)
, b as (select x.pdm_id opt
from xref_in_queue x
where x.pack_id = 1638300
and x.pdm_table_name = 'etd_option_contract')

select * from a, b
where a.opt = b.opt(+)
and b.opt is null

/*Note the use of the Oracle undocumented “materialize” hint in the “WITH clause”.  The Oracle materialize hint is used to ensure that the Oracle cost-based optimizer materializes the temporary tables that are created inside the “WITH” clause.  This is not necessary in Oracle10g, but it helps ensure that the tables are only created one time.

(Note:  You may find a faster execution plan by using Global Temporary tables, depending on your release of Oracle)
*/

WITH
   subquery_name
AS
  (the aggregation SQL statement)
SELECT /*+ materialize */
  (query naming subquery_name);
  



with 
pack as (
  select * from gmld_pack_upload g where g.pack_id = 1662561/*1642441*/),
  
feed as 
  (select * from feed_log f where f.subsystem_type_cd = 'CD_LD' and f.pack_id in (select pack_id from pack)),
  
v_begin as
  (
   select 
     min(fl.feed_log_id) feed_log_id, fl.operation, min(fl.created_date) created_date
   from 
     feed fl
   where 
    substr(fl.descr, 1,5) = 'Begin'
   group by fl.operation
), 

v_finish  as
  (
  select 
    max(fl.feed_log_id) feed_log_id, fl.operation, max(fl.created_date) created_date
  from 
    feed fl
  where 
    fl.descr = 'Finished'
  group by fl.operation
), 

v_operation as
(
select 
  ip.*  
from 
  irds_operation ip,
  irds_group_operation g,
  Irds_Process p
where 
  p.process_cd = 'LD_FEED_NORM' and
  p.process_cd = g.process_cd and
  g.group_operation_cd = ip.group_operation_cd

),

v_oper_table as (         
  select 
    fl.operation_cd,
    decode( fl.operation_cd, 
            'P_CROSS_CONTRACTS'                    ,'STG_C_GR_CONTRACT',
            'P_CROSS_CONTRACT_ALT_ID'              ,'STG_C_GR_CONTRACT_ALT_ID',
            'P_CROSS_FUTURE_CONTRACT'              ,'STG_C_GR_FUTURE_CONTRACT',
            'P_CROSS_FUT_CNTR_ALT_ID'              ,'STG_C_GR_FUT_CONTR_ALT_ID_UPD',
            'P_CROSS_OPTION_CONTRACT'              ,'STG_C_GR_OPTION_CONTRACT',
            'P_CROSS_OPT_CNTR_ALT_ID'              ,'STG_C_GR_OPT_CONTR_ALT_ID_UPD',
            'P_CROSS_FUT_UNDRLR_ID'                ,'STG_C_GR_FUT_UNDRLR_IDNTFCTN',
            'P_CROSS_OPT_UNDRLR_ID'                ,'STG_C_GR_OPT_UNDRLR_IDNTFCTN',
            'P_CROSS_EXECUTION_VENUE'              ,'STG_C_GR_EXECUTION_VENUE',
            'P_CROSS_EXECUTION_VENUE_RLTSH'        ,'STG_C_GR_XCTN_VENUE_RLTSHP',
            'P_CROSS_VENUE_ALT_ID'                 ,'STG_C_GR_XCTN_VENUE_ALT_ID',
            'P_CROSS_EXECUTION_VENUE_SS'           ,'STG_C_GR_CNTRCT_XCTN_VEN_SSSN',
            'P_CROSS_OPT_LISTING'                  ,'STG_C_GR_OPTION_LISTING',
            'P_CROSS_FUT_LISTING'                  ,'STG_C_GR_FUTURE_LISTING',
            'P_CROSS_FOW_MPF'                      ,'STG_C_GR_FOW_MPF',
            'P_CROSS_ETD_CSPEC_XCTN_VEN'           ,'STG_C_GR_CNTRCT_XCTN_VEN',
            'P_CROSS_CNTR_VEN_HOLIDAY'             ,'STG_C_GR_CNTRCT_VEN_HOLIDAY',
            'P_DO_NORM_EXEC_VENUE_UPD'             ,'STG_C_GR_EXECUTION_VENUE',
            'P_DO_NORM_EXEC_VENUE_ALT_UPD'         ,'STG_C_GR_XCTN_VENUE_ALT_ID',
            'P_DO_NORM_EXEC_VENUE_RLT_UPD'         ,'STG_C_GR_XCTN_VENUE_RLTSHP',
            'P_DO_NORM_FNCL_UPD'                   ,'STG_C_GR_CONTRACT',
            'P_DO_NORM_ETD_CONTR_UPD'              ,'STG_C_GR_CONTRACT',
            'P_DO_NORM_ETD_CONTR_PRFCT_UPD'        ,'STG_C_GR_FOW_MPF',
            'P_DO_NORM_FUT_CONTR_UPD'              ,'STG_C_GR_FUTURE_CONTRACT',
            'P_DO_NORM_OPT_CONTR_UPD'              ,'STG_C_GR_OPTION_CONTRACT',
            'P_DO_NORM_OPTION_LISTING'             ,'STG_C_GR_OPTION_LISTING',
            'P_DO_NORM_FUTURE_LISTING'             ,'STG_C_GR_FUTURE_LISTING',
            'P_DO_FUT_CNTR_ALT_IDT_UPD'            ,'STG_C_GR_FUT_CONTR_ALT_ID_UPD',
            'P_DO_NORM_FUTURE_UNDRLR_ID'           ,'STG_C_GR_FUT_UNDRLR_IDNTFCTN',
            'P_DO_NORM_CSPEC_ALT_ID_UPD'           ,'STG_C_GR_CONTRACT_ALT_ID',
            'P_DO_NORM_CSPEC_XCTN_VEN_UPD'         ,'STG_C_GR_CNTRCT_XCTN_VEN',
            'P_DO_N_CSPEC_XCTN_VEN_SN_UPD'         ,'STG_C_GR_CNTRCT_XCTN_VEN_SSSN',
            'P_DO_NORM_CNTR_VEN_HOLIDAY'           ,'STG_C_GR_CNTRCT_VEN_HOLIDAY' ) table_name
  from v_operation fl
),

v_oper_table_pre as (
    select
      v.operation_cd,
      c.table_name,
      c.cnt
    from
      (
      select 
         t.*,
         extractvalue(dbms_xmlgen.getxmltype('select count(1) cnt FROM ' || table_name ||' where pack_id = '||(select pack_id from pack)), '/ROWSET/ROW/CNT') cnt
      from  
         (select distinct table_name from v_oper_table where table_name is not null) t
      ) c,
      v_oper_table v
    where
      c.table_name = v.table_name  
),

v_oper_table_action as (
      select 
         t.*,
         extractvalue(dbms_xmlgen.getxmltype('select count(1) cnt FROM ' || table_name ||' where pack_id = '||(select pack_id from pack)||' and action = '''||t.action||''''), '/ROWSET/ROW/CNT') cnt
      from  
        (select 'P_DO_NORM_OPT_CNTR_ALT_ID_UPD' operation_cd,  'STG_C_GR_OPT_CONTR_ALT_ID_UPD' table_name, 'UPD' action from dual
         union all 
         select 'P_DO_NORM_OPT_CNTR_ALT_ID_INS' operation_cd,  'STG_C_GR_OPT_CONTR_ALT_ID_UPD' table_name, 'INS' action from dual
         union all 
         select 'P_DO_NORM_OPTION_UNDRLR_ID_UPD' operation_cd,  'STG_C_GR_OPT_UNDRLR_IDNTFCTN' table_name, 'UPD' action from dual
         union all 
         select 'P_DO_NORM_OPTION_UNDRLR_ID_INS' operation_cd,  'STG_C_GR_OPT_UNDRLR_IDNTFCTN' table_name, 'INS' action from dual         
        ) t

),

v_perform_xref_cnt as (
    select
      'P_DO_PERFORM_XREF' operation_cd,
      sum(vo.cnt) cnt
    from 
      (
      select 
         t.*,
         extractvalue(dbms_xmlgen.getxmltype('select count(1) cnt FROM ' || table_name ||' where pack_id = '||(select pack_id from pack)), '/ROWSET/ROW/CNT') cnt
      from  
         (select 'STG_C_GR_OPTION_CONTRACT', 'STG_C_GR_CONTRACT', 'STG_C_GR_FUTURE_CONTRACT' table_name from dual) t
      ) vo
),

v_oper_table_cnt as (
  select 
    o.operation_cd, 
    case when p.cnt is not null then to_number(p.cnt)
         when x.cnt is not null then to_number(x.cnt) 
         when a.cnt is not null then to_number(a.cnt) 
         else null 
    end cnt
from 
   v_operation o,
   v_oper_table_pre p, 
   v_perform_xref_cnt x,
   v_oper_table_action a 
 where o.operation_cd = p.operation_cd(+) and
       o.operation_cd = x.operation_cd(+) and
       o.operation_cd = a.operation_cd(+)
)

select
  p.pack_id,
  o.operation_cd,
  b.created_date real_begin_date,
  f.created_date real_finish_date,
  case 
    --finished
    when f.created_date is not null then 100
    --not started
    when f.created_date is null and f.operation <> p.last_operation_cd then 0    
    --xref progress
    when f.created_date is null and p.last_operation_cd = 'P_DO_PERFORM_XREF' and p.is_tgt_load = 0 then
         round(((select count(ruid) total 
                   from xref_in_queue t 
                     where t.pack_id = p.pack_id and t.pdm_table_name in ('etd_option_contract','etd_future_contract','execution_venue','etd_contract_specification'))
                     /c.cnt)*100
               ,1)
    --other opretion      
    when f.created_date is null and o.operation_cd = p.last_operation_cd then decode(p.last_row_num, 0,0, round((p.last_row_num/c.cnt)*100,1))
  end progress,
  
  case 
    --finished
    when f.created_date is not null then regexp_substr(f.created_date - b.created_date, '....:..:..')
    --current
    when f.created_date is null and  o.operation_cd = p.last_operation_cd then regexp_substr(sysdate - b.created_date, '....:..:..') 
  end real_durauin,
  c.cnt volume,
  
  regexp_substr(NUMTODSINTERVAL (round(c.cnt/(case when o.operation_cd = 'P_DO_PERFORM_XREF' then 20000
                                                   when o.operation_cd in ('P_DO_NORM_OPTION_UNDRLR_ID_INS','P_DO_NORM_OPT_CNTR_ALT_ID_INS') then 2000000
                                                   when o.operation_cd like 'P_CROSS_%' then 1500000
                                                   else 300000 end)
                                              ,2)*60,'MINUTE'),'....:..:..') ETA,

  case 
    --current
    when f.created_date is null and  o.operation_cd = p.last_operation_cd and p.last_row_num <> 0 then 
      regexp_substr(NUMTODSINTERVAL (round(c.cnt/(p.last_row_num/(f_interval_to_second(sysdate-b.created_date)/60/60))
                                              ,2)*60,'MINUTE'),'....:..:..')      
    else
      null
                                              
  end current_ETA,
  
  case 
    --current
    when f.created_date is null and  o.operation_cd = p.last_operation_cd then 
         round (p.last_row_num/(f_interval_to_second(sysdate-b.created_date)/60/60)) 
    else
      null
  end curr_velocity
  

from
  pack p,
  v_operation o,
  v_oper_table_cnt c,
  v_begin b,
  v_finish f
where
  o.operation_cd = c.operation_cd(+)  and        
  o.operation_cd = b.operation(+) and
  o.operation_cd = f.operation(+) 
order by o.operation_order

