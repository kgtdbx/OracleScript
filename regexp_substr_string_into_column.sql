select upper(trim(token)) atable
                from ( select regexp_substr('customer, customerw, customer_update','[^,]+', 1, level) token
                         from dual
                      connect by regexp_substr('customer, customerw, customer_update', '[^,]+', 1, level) is not null
                     )
               where upper(trim(token)) is not null
			   
-----------example---------------			   
 procedure before_fill(p_tables in varchar2)
  is
  begin
    --
    --
    if g_operation is not null
    then
        raise_application_error(-20000, 'Нарушена последовательность вызова служебных процедур.'
                             ||chr(10)||'Выполните SQL> exec mgr_utl.finalize;');
    end if;
    --
    g_operation := C_OPERATION_FILL;
    g_tables    := p_tables;
    --
    clean_error();
    --
    for c in (select upper(trim(token)) atable
                from ( select regexp_substr(g_tables,'[^,]+', 1, level) token
                         from dual
                      connect by regexp_substr(g_tables, '[^,]+', 1, level) is not null
                     )
               where upper(trim(token)) is not null
             )
    loop
        disable_table_triggers (c.atable);
        disable_foreign_keys (c.atable);
        
    end loop;
    --
  end before_fill;			   