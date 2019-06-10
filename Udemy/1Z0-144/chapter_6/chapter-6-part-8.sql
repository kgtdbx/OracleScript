
begin

for i in 1..10 
  loop
  dbms_output.put_line (i);
  
  end loop;

end;

--i want to print under the number the Symbol :) only for 1,2,3,4,5
--there are many methods
--method 1 
declare
v_sym varchar2(100);
begin

for i in 1..10 
  loop
      if i between 1 and 5 then
      v_sym:=i||chr(10)||':)';
      else
      v_sym:=i;
      end if;
  
  dbms_output.put_line (v_sym);
  
  end loop;

end;
---------------------------------------

--method 2
begin
for i in 1..10 
  loop
  dbms_output.put_line (i);
  continue when i>5; --this mean stop execte next statement(s) when i>5
  dbms_output.put_line (':)');
  end loop;

end;
