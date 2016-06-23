 declare 
    l_tab varchar2(50) default 'CUSTOMERW_UPDATE';
    --p   constant varchar2(62) := 'mrg_utl.fill_'||l_tab;
    g_kf varchar2(6) default '333368';
    v_count pls_integer := 0;
    c_limit pls_integer := 50000;
    errors NUMBER;
    dml_errors EXCEPTION;
   PRAGMA EXCEPTION_INIT(dml_errors, -24381);

   cursor cur_cwu is
    select mgr_utl.rukey(rnk) as rnk
             ,tag      
             ,value     
             ,case when coalesce(isp,0) = 0
              then isp 
                else to_number(mgr_utl.ruuser(isp))  
                  end as isp
             ,chgdate    
             ,chgaction 
             ,doneby    
             ,idupd     
             ,effectdate
     from kf333368.customerw_update;
 
  type t_cur_cwu is table of cur_cwu%rowtype index by pls_integer;    
  v_cur_cwu t_cur_cwu;  
  
  begin
    --
    ikf(g_kf);
    --
    bc.go(g_kf);
    --
    --mgr_utl.disable_all_policies;
    mgr_utl.disable_table_triggers(l_tab);
    mgr_utl.disable_foreign_keys(l_tab);
    
    mgr_utl.mantain_error_table('CUSTOMERW_UPDATE');
   --
   open cur_cwu;
    loop
      
     fetch cur_cwu bulk collect into v_cur_cwu limit c_limit;
     exit when v_cur_cwu.count = 0;
        
    forall indx in indices of v_cur_cwu --SAVE EXCEPTIONS
    insert into bars.customerw_update values v_cur_cwu(indx)
    log errors into ERR$_CUSTOMERW_UPDATE ('insert : ' || to_char(v_count)||'/') reject limit unlimited;
  
   commit;
    v_count := v_count + c_limit;
    dbms_application_info.set_action('insert : ' || to_char(v_count)||'/'||to_char(sql%rowcount));
    dbms_application_info.set_client_info('insert : ' || to_char(v_count)||'/'||to_char(sql%rowcount));         
      
 end loop;
/* 
  EXCEPTION  WHEN dml_errors THEN 
   errors := SQL%BULK_EXCEPTIONS.COUNT;
   DBMS_OUTPUT.PUT_LINE('Number of statements that failed: ' || errors);
   FOR indx IN 1..errors LOOP
      DBMS_OUTPUT.PUT_LINE('Error #' || indx || ' occurred during '|| 
         'iteration #' || SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX); 
          DBMS_OUTPUT.PUT_LINE('Error message is ' ||
          SQLERRM(-SQL%BULK_EXCEPTIONS(indx).ERROR_CODE));
   END LOOP;*/
 
 close cur_cwu; 
--mgr_utl.enable_all_policies;
--mgr_utl.enable_table_triggers(l_tab);
--mgr_utl.enable_foreign_keys(l_tab);
--mgr_utl.validate_foreign_keys(l_tab);

end;            
