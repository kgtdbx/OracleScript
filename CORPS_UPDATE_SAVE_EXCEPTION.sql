DECLARE
  
    l_tab varchar2(50) default 'CORPS_UPDATE';
    --p   constant varchar2(62) := 'mrg_utl.fill_'||l_tab;
    g_kf varchar2(6) default '333368';
    v_count pls_integer := 0;
    c_limit pls_integer := 50000;
 
 /*
    * Source data cursor and associative array type. Needed to
    * enable LIMIT-based fetching...
    */
   CURSOR cur IS
      SELECT to_number(idupd||) as idupd,chgaction,effectdate,chgdate,doneby,mgr_utl.rukey(rnk) as rnk,nmku,ruk,telr,buh,telb,dov,bdov,edov,nlsnew,mainnls,mainmfo,mfonew,tel_fax,e_mail,seal_id,nmk 
      --FROM mgr_utl.pkf('CORPS_UPDATE');
      FROM KF333368.CORPS_UPDATE;

   TYPE t_cur IS TABLE OF cur%ROWTYPE
                  INDEX BY PLS_INTEGER;

   v_cur                t_cur;

   c_n                 PLS_INTEGER := 0;

   /* "Exceptions encountered in FORALL" exception... */
   bulk_exceptions   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);

   /* FORALL error-logging... */
   PROCEDURE error_logging IS
      /* Associative array type of the exceptions table... */
      TYPE t_cur_exception IS TABLE OF ERR$_CORPS_UPDATE%ROWTYPE
                               INDEX BY PLS_INTEGER;

      v_cur_exceptions   t_cur_exception;

      v_indx          PLS_INTEGER;

      /* Emulate DML error logging behaviour... */
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
         v_indx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;

         /* Populate as many values as available... */
         v_cur_exceptions (i).ora_err_number$ :=
            SQL%BULK_EXCEPTIONS (i).ERROR_CODE;
         v_cur_exceptions (i).ora_err_mesg$ :=
            SQLERRM (SQL%BULK_EXCEPTIONS (i).ERROR_CODE * -1);
         v_cur_exceptions (i).ora_err_tag$ := 'FORALL ERROR LOGGING';
         v_cur_exceptions (i).ora_err_optyp$ := 'I';
         v_cur_exceptions (i).idupd := v_cur (v_indx).idupd;
         v_cur_exceptions (i).rnk := v_cur (v_indx).rnk;
         v_cur_exceptions (i).nmk := v_cur (v_indx).nmk;
         v_cur_exceptions (i).effectdate := v_cur (v_indx).effectdate;
      END LOOP;

      /* Load the exceptions into the exceptions table... */
      FORALL i IN INDICES OF v_cur_exceptions
         INSERT INTO ERR$_CORPS_UPDATE
              VALUES v_cur_exceptions (i);

      COMMIT;
   END error_logging;
BEGIN
      --
    ikf(g_kf);
    --
    bc.go(g_kf);
    --
    mgr_utl.mantain_error_table('CORPS_UPDATE');  
    --mgr_utl.disable_all_policies;
    mgr_utl.disable_table_triggers(l_tab);
    mgr_utl.disable_foreign_keys(l_tab); 
   
   OPEN cur;

   LOOP
      FETCH cur
      BULK COLLECT INTO v_cur
      LIMIT c_limit;

      EXIT WHEN v_cur.COUNT = 0;

      BEGIN
         FORALL i IN INDICES OF v_cur SAVE EXCEPTIONS
            INSERT INTO bars.corps_update
                 VALUES v_cur (i);
      EXCEPTION
         WHEN bulk_exceptions THEN
            c_n := c_n + SQL%ROWCOUNT;
            error_logging ();
      END;

      COMMIT;
   END LOOP;

   CLOSE cur;

   DBMS_OUTPUT.put_line (c_n || ' rows inserted.');
END;
/
