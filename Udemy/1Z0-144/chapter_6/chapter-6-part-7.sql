/*
try to do print this 

*
**
***
****
*****

*/

declare
v_star varchar2(100);
begin
for i in 1..5
  loop
        for j in 1..i
        loop
        v_star:=v_star||'*';
    
        end loop;
  dbms_output.put_line(v_star); 
  v_star:=null;
  end loop;
end;
--------------------------------


declare
v_star varchar2(100);
begin
<<outer_loop>>
for i in 1..5
  loop
        <<inner_loop>>
        for j in 1..i
        loop
        v_star:=v_star||'*';
    
        end loop inner_loop;
  dbms_output.put_line(v_star); 
  v_star:=null;
  end loop outer_loop;
end;
-----------------------------------------

declare
v_star varchar2(100);
begin
<<outer_loop>>
for i in 1..5
  loop
        <<inner_loop>>
        for j in 1..i
        loop
        v_star:=v_star||'*';
        exit;
        end loop inner_loop;
  dbms_output.put_line(v_star); 
  v_star:=null;
  end loop outer_loop;
end;

-------------------

declare
v_star varchar2(100);
begin
<<outer_loop>>
for i in 1..5
  loop
        <<inner_loop>>
        for j in 1..i
        loop
        v_star:=v_star||'*';
        exit outer_loop when i=3 ;
        end loop inner_loop;
  dbms_output.put_line(v_star); 
  v_star:=null;
  end loop outer_loop;
end;


