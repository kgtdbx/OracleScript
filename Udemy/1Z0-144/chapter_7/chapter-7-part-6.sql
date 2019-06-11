declare
type tab_no is table of employees%rowtype
index by pls_integer;

v_tab_no tab_no;
v_total number;

begin
v_tab_no(1).employee_id:=1;
v_tab_no(1).first_name:='ahmed';
v_tab_no(1).last_name:='jad';

v_tab_no(2).employee_id:=2;
v_tab_no(2).first_name:='khaled';
v_tab_no(2).last_name:='yaser';

dbms_output.put_line(v_tab_no(1).employee_id||' '||v_tab_no(1).first_name||' '||v_tab_no(1).last_name);
dbms_output.put_line(v_tab_no(2).employee_id||' '||v_tab_no(2).first_name||' '||v_tab_no(2).last_name);

end;
----------------------------

declare
type tab_no is table of employees%rowtype
index by pls_integer;

v_tab_no tab_no;

begin
 for i in 100..104
 loop
 select * into v_tab_no(i)
 from
 employees 
 where employee_id=i;
 dbms_output.put_line(v_tab_no(i).employee_id||' '||
                      v_tab_no(i).first_name||' '||v_tab_no(i).last_name  
                     );
 end loop;
 

end;
-------------------------------------

declare
type tab_no is table of employees%rowtype
index by pls_integer;

v_tab_no tab_no;

begin
 for i in 100..104
   loop
   select * into v_tab_no(i)
   from
   employees 
   where employee_id=i;
  
   end loop;
 
 for i in v_tab_no.first..v_tab_no.last
   loop
    dbms_output.put_line(v_tab_no(i).employee_id);
    dbms_output.put_line(v_tab_no(i).first_name);
    dbms_output.put_line(v_tab_no(i).last_name);
    dbms_output.put_line(v_tab_no(i).salary);
   end loop;
 
end;

