DECLARE    
    l_tab                   VARCHAR2(30) DEFAULT 'OPER';
    g_kf                    VARCHAR2(6) DEFAULT '300465';
    p                       CONSTANT VARCHAR2(62) := 'fill_'||l_tab;
    v_count                 PLS_INTEGER := 0;
    c_limit                 PLS_INTEGER := 50000;
    l_cur                   SYS_REFCURSOR;
    c_n                     PLS_INTEGER := 0;
    l_date                  DATE;
    l_date_end              DATE;
    l_migration_start_time  date default sysdate;
    l_start_time            timestamp default current_timestamp;
    l_end_time              timestamp default current_timestamp;
    l_rowcount              number default 0;
    l_time_duration         interval day(3) to second(3);

   /* "Exceptions encountered in FORALL" exception... */
   bulk_exceptions   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);

  /*
   * Source data record and associative array type. Needed to
   * enable LIMIT-based fetching...
  */

    TYPE t_oper_row IS TABLE OF oper%ROWTYPE;
    vv_cur_oper t_oper_row;
---------------------------------------------------------------------------------
      /*local procedure for save error to err$table*/
   PROCEDURE error_logging_oper IS
      /* Associative array type of the exceptions table... */
      TYPE t_cur_exception IS TABLE OF ERR$_OPER%ROWTYPE INDEX BY PLS_INTEGER;

      v_cur_exceptions   t_cur_exception;

      v_indx          PLS_INTEGER;

      /* Emulate DML error logging behaviour... */
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
         v_indx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;

         /* Populate as many values as available... */
         v_cur_exceptions (i).ora_err_number$        := SQL%BULK_EXCEPTIONS (i).ERROR_CODE;
         v_cur_exceptions (i).ora_err_mesg$          := SQLERRM (SQL%BULK_EXCEPTIONS (i).ERROR_CODE * -1);
         v_cur_exceptions (i).ora_err_tag$           := 'FORALL ERROR LOGGING';
         v_cur_exceptions (i).ora_err_optyp$         := 'I';
         v_cur_exceptions (i).ref                    := vv_cur_oper (v_indx).ref;
         v_cur_exceptions (i).kf                     := vv_cur_oper (v_indx).kf;
         v_cur_exceptions (i).pdat                   := vv_cur_oper (v_indx).pdat;
      END LOOP;

      /* Load the exceptions into the exceptions table... */
      FORALL i IN INDICES OF v_cur_exceptions
         INSERT INTO ERR$_OPER
              VALUES v_cur_exceptions (i);

      COMMIT;
   END error_logging_oper;

    --
    BEGIN
    l_migration_start_time := sysdate;
    l_start_time := current_timestamp;

    ikf(g_kf);
    --
    bc.go(g_kf);

    mgr_utl.before_fill(l_tab);

    --mgr_utl.mantain_error_table(l_tab);
             --
            OPEN l_cur FOR
              'select
                       rukey(ref) as ref
                      ,deal_tag
                      ,tt
                      ,vob
                      ,nd
                      ,pdat
                      ,vdat
                      ,kv
                      ,dk
                      ,s
                      ,sq
                      ,sk
                      ,datd
                      ,datp
                      ,nam_a
                      ,nlsa
                      ,mfoa
                      ,nam_b
                      ,nlsb
                      ,mfob
                      ,nazn
                      ,d_rec
                      ,id_a
                      ,id_b
                      ,id_o
                      ,sign
                      ,sos
                      ,vp
                      ,chk
                      ,s2
                      ,kv2
                      ,kvq
                      ,rukey(refl) as refl
                      ,prty
                      ,sq2
                      ,currvisagrp
                      ,nextvisagrp
                      ,ref_a
                      ,tobo
                      ,otm
                      ,signed
                      ,branch
                      ,ruuser(userid) as userid
                      ,ruuser(respid) as respid
                      ,'''||g_kf||'''
                      ,bis
                      ,sos_tracker
                      ,next_visa_branches
                      ,sos_change_time
                      ,odat
                      ,bdat
                      ,sign_id
              from '||mgr_utl.pkf('oper')||' op_kf 
              where exists 
                          (select null 
                           from (select substr(ref,1,length(ref)-2) AS ref 
                                 from bars.cp_deal cd 
                                 where not exists (select null 
                                                   from bars.oper op 
                                                   where op.ref = cd.ref)
                                 )nex 
                           where nex.ref = op_kf.ref
                           )';
                  --
           LOOP
             FETCH l_cur BULK COLLECT INTO vv_cur_oper LIMIT c_limit;
               EXIT WHEN vv_cur_oper.COUNT = 0;

           BEGIN
            FORALL indx IN INDICES OF vv_cur_oper SAVE EXCEPTIONS
              INSERT INTO bars.oper
                                        VALUES vv_cur_oper(indx);

            EXCEPTION
                   WHEN bulk_exceptions THEN
                      c_n := c_n + SQL%ROWCOUNT;
                      error_logging_oper ();
           END;
            COMMIT;
              v_count := v_count + c_limit;
            dbms_application_info.set_action('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));
            dbms_application_info.set_client_info('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));
           END LOOP;
           CLOSE l_cur;
         l_end_time := current_timestamp;
         l_time_duration:= (l_end_time - l_start_time);
         mgr_log.p_save_log_info_mesg(ip_migration_id                   => g_kf
                                      ,ip_migration_start_time          => l_migration_start_time
                                      ,ip_table_name                    => l_tab
                                      ,ip_operation                     => p
                                      ,ip_row_count                     => l_rowcount
                                      ,ip_task_start_time               => l_start_time
                                      ,ip_task_end_time                 => l_end_time
                                      ,ip_time_duration                 => l_time_duration
                                      ,ip_log_message                   => 'Done'
                                       );
        EXCEPTION
              WHEN OTHERS THEN
                   --mgr_utl.save_error();
          mgr_log.p_save_log_error(ip_migration_id                      => g_kf
                                  ,ip_migration_start_time              => l_migration_start_time
                                  ,ip_table_name                        => l_tab
                                  ,ip_operation                         => p
                                  ,ip_row_count                         => l_rowcount
                                  ,ip_task_start_time                   => l_start_time
                                  ,ip_task_end_time                     => l_end_time
                                  ,ip_time_duration                     => l_time_duration
                                  ,ip_log_message                       => 'Error'
                                  );
           -- Clear collection for vv_cur_oper
           vv_cur_oper.delete;
END;           
