procedure fill_oper_visa_frl
   is
   p                        CONSTANT VARCHAR2(62) := G_PKG||'.fill_oper_visa_frl';
   l_tab                    VARCHAR2(50) DEFAULT 'OPER_VISA';
   v_count                  PLS_INTEGER := 0;
   c_limit                  PLS_INTEGER := 200000;
   l_cur                    SYS_REFCURSOR;
   c_n                      PLS_INTEGER := 0;
   l_max_sqnc               oper_visa.sqnc%TYPE;
   l_migration_start_time   date default sysdate;
   l_start_time             timestamp default current_timestamp;
   l_end_time               timestamp default current_timestamp;
   l_rowcount               number default 0;
   l_time_duration          interval day(3) to second(3);

   /* "Exceptions encountered in FORALL" exception... */
   bulk_exceptions   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);

   TYPE t_cur_oper_visa IS TABLE OF oper_visa%ROWTYPE;

   vv_cur_oper_visa t_cur_oper_visa;
---------------------------------------------------------------------------------
      /*local procedure for save error to err$table*/
   PROCEDURE error_logging_oper_visa IS
      /* Associative array type of the exceptions table... */
      TYPE t_cur_exception IS TABLE OF ERR$_OPER_VISA%ROWTYPE INDEX BY PLS_INTEGER;

      v_cur_exceptions      t_cur_exception;

      v_indx                PLS_INTEGER;

      /* Emulate DML error logging behaviour... */
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
         v_indx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;

         /* Populate as many values as available... */
         v_cur_exceptions (i).ora_err_number$           := SQL%BULK_EXCEPTIONS (i).ERROR_CODE;
         v_cur_exceptions (i).ora_err_mesg$             := SQLERRM (SQL%BULK_EXCEPTIONS (i).ERROR_CODE * -1);
         v_cur_exceptions (i).ora_err_tag$              := 'FORALL ERROR LOGGING';
         v_cur_exceptions (i).ora_err_optyp$            := 'I';
         v_cur_exceptions (i).ref                       := vv_cur_oper_visa (v_indx).ref;
         v_cur_exceptions (i).dat                       := vv_cur_oper_visa (v_indx).dat;
         v_cur_exceptions (i).userid                    := vv_cur_oper_visa (v_indx).userid;
         v_cur_exceptions (i).groupid                   := vv_cur_oper_visa (v_indx).status;
         v_cur_exceptions (i).status                    := vv_cur_oper_visa (v_indx).userid;
         v_cur_exceptions (i).sqnc                      := vv_cur_oper_visa (v_indx).sqnc;
         v_cur_exceptions (i).passive                   := vv_cur_oper_visa (v_indx).passive;
         v_cur_exceptions (i).keyid                     := vv_cur_oper_visa (v_indx).keyid;
         v_cur_exceptions (i).sign                      := vv_cur_oper_visa (v_indx).sign;
         v_cur_exceptions (i).username                  := vv_cur_oper_visa (v_indx).username;
         v_cur_exceptions (i).usertabn                  := vv_cur_oper_visa (v_indx).usertabn;
         v_cur_exceptions (i).groupname                 := vv_cur_oper_visa (v_indx).groupname;
         v_cur_exceptions (i).f_in_charge               := vv_cur_oper_visa (v_indx).f_in_charge;
         v_cur_exceptions (i).check_ts                  := vv_cur_oper_visa (v_indx).check_ts;
         v_cur_exceptions (i).check_code                := vv_cur_oper_visa (v_indx).check_code;
         v_cur_exceptions (i).check_msg                 := vv_cur_oper_visa (v_indx).check_msg;
         v_cur_exceptions (i).kf                        := vv_cur_oper_visa (v_indx).kf;
         v_cur_exceptions (i).passive_reasonid          := vv_cur_oper_visa (v_indx).passive_reasonid;
         
      END LOOP;

      /* Load the exceptions into the exceptions table... */
      FORALL i IN INDICES OF v_cur_exceptions
         INSERT INTO ERR$_OPER_VISA
              VALUES v_cur_exceptions (i);

      COMMIT;
   END error_logging_oper_visa;


  begin
    l_migration_start_time := sysdate;
    l_start_time := current_timestamp;
    --
    trace('%s: entry point', p);
    --
    --bc.home();
    --
    --select nvl(max(sqnc),0)  into l_max_sqnc  from bars.oper_visa;
    --
    bc.go(g_kf);
    --
    mgr_utl.before_fill(l_tab);
    --
    -- mantain_error_table - создает/очищает таблицу ошибок err$_<p_table>
    mgr_utl.mantain_error_table(l_tab);
    begin
     --execute immediate 'ALTER INDEX i1_opervisa UNUSABLE';

      BEGIN

      OPEN l_cur FOR
              'select
                   rukey(ref) as ref
                   ,dat
                   ,ruuser(userid) as userid
                   ,groupid
                   ,status
                   ,rukey(sqnc) as sqnc
                   ,passive
                   ,keyid
                   ,sign
                   ,ruuser(username)  as username
                   ,usertabn
                   ,groupname
                   ,f_in_charge
                   ,check_ts
                   ,check_code
                   ,check_msg
                   ,'''||g_kf||''' as kf
                   ,passive_reasonid
               from '||pkf('oper_visa');
                  --
           LOOP
             FETCH l_cur BULK COLLECT INTO vv_cur_oper_visa LIMIT c_limit;
               EXIT WHEN vv_cur_oper_visa.COUNT = 0;

           BEGIN
            FORALL indx IN INDICES OF vv_cur_oper_visa SAVE EXCEPTIONS
              INSERT INTO bars.oper_visa
                                        VALUES vv_cur_oper_visa(indx);

            EXCEPTION
                   WHEN bulk_exceptions THEN
                      c_n := c_n + SQL%ROWCOUNT;
                      error_logging_oper_visa ();
           END;
            COMMIT;
              v_count := v_count + c_limit;
            dbms_application_info.set_action('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));
            dbms_application_info.set_client_info('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));

           END LOOP;
           l_rowcount := l_cur%rowcount;
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
          -- Clear collection for vv_cur_oper_visa
          vv_cur_oper_visa.delete;
        END;
        --
        bc.home();
        --
        select trunc(nvl(max(sqnc / 100), 0)) + 1 into l_max_sqnc  from bars.oper_visa;

        mgr_utl.reset_sequence('S_VISA', l_max_sqnc);
        --
        --trace('собираем статистику');
        --
        --mgr_utl.gather_table_stats('bars', 'oper_visa', cascade=>true);
        --
    exception
        when others then
            rollback;
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
    end;
    --
    bc.home();
    --
    --execute immediate 'ALTER INDEX    i1_opervisa REBUILD';

    mgr_utl.finalize();
    --
    trace('%s: finished', p);
    --
  end fill_oper_visa_frl;