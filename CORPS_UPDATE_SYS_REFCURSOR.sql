 declare 
    l_tab           varchar2(50) default 'CORPS_UPDATE';
    --p   constant varchar2(62) := 'mrg_utl.fill_'||l_tab;
    g_kf           	 varchar2(6) default '333368';
    v_count        pls_integer := 0;
    c_limit          pls_integer := 50000;
    cur_cru         sys_refcursor;
    c_n               PLS_INTEGER := 0;
    
   bulk_exceptions   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);
    
type t_corps_update_row is record(
  idupd      NUMBER(15),
  chgaction  CHAR(1),
  effectdate DATE,
  chgdate    DATE,
  doneby     NUMBER,
  rnk        NUMBER(38),
  nmku       VARCHAR2(250),
  ruk        VARCHAR2(70),
  telr       VARCHAR2(20),
  buh        VARCHAR2(70),
  telb       VARCHAR2(20),
  dov        VARCHAR2(35),
  bdov       DATE,
  edov       DATE,
  nlsnew     VARCHAR2(15),
  mainnls    VARCHAR2(15),
  mainmfo    VARCHAR2(12),
  mfonew     VARCHAR2(12),
  tel_fax    VARCHAR2(20),
  e_mail     VARCHAR2(100),
  seal_id    NUMBER(38),
  nmk        VARCHAR2(182));
 
   type t_cru is table of t_corps_update_row index by pls_integer;  
    
    v_cur_cru   t_corps_update_row;
    
    vv_cru t_cru;
  
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
         v_cur_exceptions (i).idupd := vv_cru (v_indx).idupd;
         v_cur_exceptions (i).rnk := vv_cru (v_indx).rnk;
         v_cur_exceptions (i).nmk := vv_cru (v_indx).nmk;
         v_cur_exceptions (i).effectdate := vv_cru (v_indx).effectdate;
      END LOOP;

      /* Load the exceptions into the exceptions table... */
      FORALL i IN INDICES OF v_cur_exceptions
         INSERT INTO ERR$_CORPS_UPDATE
              VALUES v_cur_exceptions (i);

      COMMIT;
   END error_logging;
    
  begin
    --
    ikf(g_kf);
    --
    bc.go(g_kf);
    --
    --mgr_utl.disable_all_policies;
    mgr_utl.disable_table_triggers(l_tab);
    mgr_utl.disable_foreign_keys(l_tab);
    
    mgr_utl.mantain_error_table('CORPS_UPDATE');
   --
  open cur_cru for
    'select 
  idupd+rownum      
  ,chgaction  
  ,effectdate 
  ,chgdate    
  ,doneby     
  ,mgr_utl.rukey(rnk) as rnk        
  ,nmku       
  ,ruk        
  ,telr       
  ,buh        
  ,telb       
  ,dov        
  ,bdov       
  ,edov       
  ,nlsnew     
  ,mainnls    
  ,mainmfo    
  ,mfonew     
  ,tel_fax    
  ,e_mail     
  ,seal_id    
  ,nmk
  from '||mgr_utl.pkf('corps_update');
        --
 --       while true
 loop
    fetch cur_cru bulk collect into vv_cru limit c_limit;
     exit when vv_cru.count = 0;
        
 begin  
  forall indx in indices of vv_cru SAVE EXCEPTIONS
    insert into bars.corps_update 
                  (idupd      
                    ,chgaction  
                    ,effectdate 
                    ,chgdate    
                    ,doneby     
                    ,rnk        
                    ,nmku       
                    ,ruk        
                    ,telr       
                    ,buh        
                    ,telb       
                    ,dov        
                    ,bdov       
                    ,edov       
                    ,nlsnew     
                    ,mainnls    
                    ,mainmfo    
                    ,mfonew     
                    ,tel_fax    
                    ,e_mail     
                    ,seal_id    
                    ,nmk)
                              values (
                                         vv_cru(indx).idupd
                                        ,vv_cru(indx).chgaction  
                                        ,vv_cru(indx).effectdate 
                                        ,vv_cru(indx).chgdate    
                                        ,vv_cru(indx).doneby     
                                        ,vv_cru(indx).rnk       
                                        ,vv_cru(indx).nmku       
                                        ,vv_cru(indx).ruk        
                                        ,vv_cru(indx).telr       
                                        ,vv_cru(indx).buh        
                                        ,vv_cru(indx).telb       
                                        ,vv_cru(indx).dov        
                                        ,vv_cru(indx).bdov       
                                        ,vv_cru(indx).edov       
                                        ,vv_cru(indx).nlsnew     
                                        ,vv_cru(indx).mainnls    
                                        ,vv_cru(indx).mainmfo    
                                        ,vv_cru(indx).mfonew     
                                        ,vv_cru(indx).tel_fax    
                                        ,vv_cru(indx).e_mail     
                                        ,vv_cru(indx).seal_id    
                                        ,vv_cru(indx).nmk );
  
  EXCEPTION
         WHEN bulk_exceptions THEN
            c_n := c_n + SQL%ROWCOUNT;
            error_logging (); 
 END;
  commit;
    v_count := v_count + c_limit;
    dbms_application_info.set_action('insert : ' || to_char(v_count)||'/'||to_char(sql%rowcount));
    dbms_application_info.set_client_info('insert : ' || to_char(v_count)||'/'||to_char(sql%rowcount));         
      
 end loop;
 close cur_cru; 
end;            
