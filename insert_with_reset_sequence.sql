PROMPT ===========================================
PROMPT Load data into REPORT_DEFS
PROMPT ===========================================

 declare
 l_max_report_id mimir.report_defs.report_id%type;

 procedure reset_sequence (seq_name in varchar2, startvalue in number)
    is
        cval   number;
        inc_by varchar2(25);
    begin

      execute immediate 'ALTER SEQUENCE ' ||seq_name||' MINVALUE 0';

      execute immediate 'SELECT ' ||seq_name ||'.NEXTVAL FROM DUAL'
      into cval;

      cval := cval - startvalue + 1;
      if cval < 0 then
        inc_by := ' INCREMENT BY ';
        cval:= abs(cval);
      else
        inc_by := ' INCREMENT BY -';
      end if;

      if cval=0
      then
        return;
      end if;

      execute immediate 'ALTER SEQUENCE ' || seq_name || inc_by ||
      cval;

      execute immediate 'SELECT ' ||seq_name ||'.NEXTVAL FROM DUAL'
      into cval;

      execute immediate 'ALTER SEQUENCE ' || seq_name ||
      ' INCREMENT BY 1';

    end reset_sequence;

    begin
        select nvl(max(report_id), 0) + 1 into l_max_report_id
          from mimir.report_defs;
        --
        reset_sequence('REPORT_ID_SEQ', l_max_report_id);
        --
        insert into mimir.report_defs (report_id, report_name, created_date, version, pkg, functionname, in_use)
            values(mimir.report_id_seq.nextval, 'Large exposure report', sysdate, '1.0', 'crd_large_exposure', 'reporttablepopulate', 'Y');
        commit;
        /*
        exception when dup_val_on_index 
            then raise_application_error( -20001, 'Caution unique constraint mimir.report_defs_uq violated! Please enter enother report_name or version and try again!' );
         */   
        exception
            when others
                then
                    case sqlcode
                        when -1
                        then
                            raise_application_error( -20001, 'Caution unique constraint mimir.report_defs_uq violated! Please enter enother report_name or version and try again!' );
                        else
                            raise;
                    end case;
    end;
/