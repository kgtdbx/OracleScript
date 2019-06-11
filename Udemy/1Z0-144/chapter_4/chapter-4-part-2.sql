declare
v_global varchar2(100):='this is a global variable';
begin
    
     declare
     v_local varchar2(100):='this is a local variable';
     begin
     dbms_output.put_line(v_global);
     dbms_output.put_line(v_local);
     end;
 
dbms_output.put_line(v_global);
---dbms_output.put_line(v_local); you can not do this
      
end;
----------------------------------------------------------

declare
v_father_name varchar2(100):='khaled';
v_birthday date:='20-Jul-1981';
begin
      declare
      v_child  varchar2(100):='Layal';
      v_birthday  date:='5-Apr-2013';
      begin
      dbms_output.put_line('the father name is ' ||v_father_name);
      dbms_output.put_line('the father birthday is '||v_birthday);
      dbms_output.put_line('the child name is '||v_child);
      dbms_output.put_line('the child birthday is '||v_birthday);
      end;    
end;
-----------------------------------------------------------
begin <<outer>>
declare
v_father_name varchar2(100):='khaled';
v_birthday date:='26-Jul-1981';
begin
      declare
      v_child  varchar2(100):='Layal';
      v_birthday  date:='5-Apr-2013';
      begin
      dbms_output.put_line('the father name is ' ||v_father_name);
      dbms_output.put_line('the father birthday is '||outer.v_birthday);
      dbms_output.put_line('the child name is '||v_child);
      dbms_output.put_line('the child birthday is '||v_birthday);
      end;    
end;
end outer;

