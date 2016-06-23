begin
  for indx in (select d.DB_LINK from user_db_links d)
     loop
       dbms_output.put_line('select * from dual@'||indx.db_link||';');
       end loop;
  end;
