  procedure fill_cc_docs
    is
    begin
      execute immediate 'ALTER SESSION FORCE PARALLEL DML PARALLEL 8';
      execute immediate 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8';
      mgr_utl.sync_table(p_table => 'cc_docs', p_stmt => 'insert /*+ APPEND NOLOGGING */ into cc_docs(id, nd, adds, version, state, text, comm, doneby)
      select  /*+ PARALLEL */ id, rukey(nd), adds, version, state, to_clob(to_nclob(text)), comm, ruuser(doneby)  from  '||pkf('CC_DOCS'), p_delete => false);
      end fill_cc_docs;
	  
	  
procedure fill_cc_docs
     is
        p                      constant varchar2(62) := G_PKG||'.fill_cc_docs';
        l_tab                 VARCHAR2(50) DEFAULT 'CC_DOCS';
        v_count             PLS_INTEGER := 0;
        c_limit               PLS_INTEGER := 50000;
        l_cur                 SYS_REFCURSOR;
        c_n                   PLS_INTEGER := 0;
        l_max_sqnc       cc_docs.id%TYPE;     
       
       /* "Exceptions encountered in FORALL" exception... */    
       bulk_exceptions   EXCEPTION;
       PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);
    	
        /*
         * Source data record and associative array type. Needed to
         * enable LIMIT-based fetching...
        */
           
         TYPE t_cc_docs_row IS RECORD(
                       id      VARCHAR2(35)
					  ,nd      NUMBER(38)
					  ,adds    NUMBER(10)
					  ,version DATE 
					  ,state   NUMBER(1)
					  ,text    CLOB
					  ,comm    VARCHAR2(254)
					  ,doneby  VARCHAR2(30)
					  ,kf      VARCHAR2(6));
           
       TYPE t_cur_cc_docs IS TABLE OF t_cc_docs_row INDEX BY PLS_INTEGER;  
        
       vv_cur_cc_docs t_cur_cc_docs;
    ---------------------------------------------------------------------------------
          /*local procedure for save error to err$table*/  
       PROCEDURE error_logging_cc_docs IS
          /* Associative array type of the exceptions table... */
          TYPE t_cur_exception IS TABLE OF ERR$_CC_DOCS%ROWTYPE INDEX BY PLS_INTEGER;

          v_cur_exceptions   t_cur_exception;

          v_indx          PLS_INTEGER;

          /* Emulate DML error logging behaviour... */
          PRAGMA AUTONOMOUS_TRANSACTION;
       BEGIN
          FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
             v_indx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;

             /* Populate as many values as available... */
             v_cur_exceptions (i).ora_err_number$        := SQL%BULK_EXCEPTIONS (i).ERROR_CODE;
             v_cur_exceptions (i).ora_err_mesg$           := SQLERRM (SQL%BULK_EXCEPTIONS (i).ERROR_CODE * -1);
             v_cur_exceptions (i).ora_err_tag$ 	            := 'FORALL ERROR LOGGING';
             v_cur_exceptions (i).ora_err_optyp$           := 'I';
             v_cur_exceptions (i).nd 		                        := vv_cur_cc_docs (v_indx).nd;
             v_cur_exceptions (i).kf 		 	                         := vv_cur_cc_docs (v_indx).kf;
             v_cur_exceptions (i).id 	                 := vv_cur_cc_docs (v_indx).id;
          END LOOP;

          /* Load the exceptions into the exceptions table... */
          FORALL i IN INDICES OF v_cur_exceptions
             INSERT INTO ERR$_CC_DOCS
                  VALUES v_cur_exceptions (i);

          COMMIT;
       END error_logging_cc_docs;
        
        
      begin
        --
        trace('%s: entry point', p);
        --
        bc.home();
        --
        select nvl(max(id),0)  into l_max_sqnc  from bars.cc_docs;
        
        --mgr_utl.reset_sequence('S_CCACCP_UPDATE', l_max_sqnc);
        --
        bc.go(g_kf);
        --
        mgr_utl.before_fill(l_tab);
        --
        mgr_utl.mantain_error_table(l_tab);
        
        begin
         
         --execute immediate 'ALTER INDEX xai_ccaccp_updateeffdat UNUSABLE'; 
         --execute immediate 'ALTER INDEX xai_ccaccp_updatepk UNUSABLE';     
            
          BEGIN  
               OPEN l_cur FOR
                  'select 
					 id, 
					 rukey(nd) as nd, 
					 adds, 
					 version, 
					 state, 
					 text, 
					 comm, 
					 ruuser(doneby) as doneby,
					 '''||g_kf||''' as kf          
                   from '||mgr_utl.pkf('cc_docs');
                      --
               LOOP
                 FETCH l_cur BULK COLLECT INTO vv_cur_cc_docs LIMIT c_limit;
                   EXIT WHEN vv_cur_cc_docs.COUNT = 0;
                      
               BEGIN  
                FORALL indx IN INDICES OF vv_cur_cc_docs SAVE EXCEPTIONS
                  INSERT INTO bars.cc_docs 
                                            VALUES vv_cur_cc_docs(indx);
                
                EXCEPTION
                       WHEN bulk_exceptions THEN
                          c_n := c_n + SQL%ROWCOUNT;
                          error_logging_cc_docs (); 
               END;
                COMMIT;
                  v_count := v_count + c_limit;
                dbms_application_info.set_action('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));
                dbms_application_info.set_client_info('INS: ' || to_char(v_count)||'/'||to_char(sql%rowcount)||'/ TBL: '||l_tab||' ERR: ' || to_char(c_n));   
                    
               END LOOP;
               CLOSE l_cur;
               -- Clear collection for vv_cur_cc_docs
              vv_cur_cc_docs.delete; 
         END;            
            --
            bc.home();
            
        exception
            when others then
                rollback;
                mgr_utl.save_error();
        end;
        --
         --execute immediate 'ALTER INDEX xai_ccaccp_updateeffdat REBUILD'; 
         --execute immediate 'ALTER INDEX xai_ccaccp_updatepk REBUILD'; 
        
        mgr_utl.finalize();
        --
        trace('%s: finished', p);
        
   end fill_cc_docs;	  