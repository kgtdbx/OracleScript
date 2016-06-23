declare

--CREATE GLOBAL TEMPORARY TABLE TEST_SB(rd varchar2(100), codeapp varchar(20))  ON COMMIT PRESERVE ROWS; 

begin

for cur in (select rowid rd, rtrim(codeapp) codeapp
    from refapp)

loop
  insert into TEST_SB (rd, codeapp) values (cur.rd, cur.codeapp);
 end loop;
 
--delete from QUEUE_OPERAPP_ACS;
                  begin

                  for cur1 in (select rd, codeapp from TEST_SB)
                  loop
                   --insert into QUEUE_OPERAPP_ACS (codeapp) values (cur1.codeapp);
                   update refapp set codeapp = cur1.codeapp where rowid = cur1.rd;
                   end loop;
                   commit;
                   end;

 execute immediate  'alter table refapp modify codeapp CHAR(4)';

end;
