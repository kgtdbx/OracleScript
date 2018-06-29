alter session set nls_date_format='dd/mm/yy';
set serveroutput on
declare
l_count number;
l_date date := date'2018-06-28';
l_stmt varchar2(3900 char);

procedure output_result(ip_table_name varchar2)
is
--v_table_name extstg.rb_gagnatorg_load_tables.table_name_arc%type;
begin
  l_stmt:= 'select count(1) from '||ip_table_name||' where reference_date = :l_date';
  execute immediate l_stmt into l_count using l_date;
  dbms_output.put_line('For table : ' || ip_table_name || ' count = '||l_count);
exception when others then
if sqlcode=-942 then dbms_output.put_line('table '||ip_table_name||' does not exist');
else raise;
end if;
end;

begin 
 for cus in (select table_name_arc
               from rb_gagnatorg_load_tables lt where lt.load_batch_name = 'TDC')
 loop
    output_result(cus.table_name_arc);
 end loop;
end;
/


--another version with cursor

alter session set nls_date_format='dd/mm/yy';
set serveroutput on
declare
l_count number;
l_date date := date'2018-06-28';
l_stmt varchar2(3900 char);
cursor c is
    select table_name_arc
      from rb_gagnatorg_load_tables lt/*, user_tables ut*/ 
     where /*ut.table_name = lt.table_name_arc
       and*/ lt.load_batch_name = 'TDC';
procedure output_result
is
v_table_name extstg.rb_gagnatorg_load_tables.table_name_arc%type;
begin
loop
  fetch c into v_table_name;
  exit when c%notfound;
  l_stmt:= 'select count(1) from '||v_table_name||' where reference_date = :l_date';
  execute immediate l_stmt into l_count using l_date;
  --dbms_output.put_line(l_count);
  dbms_output.put_line('For table : ' || v_table_name || ' count = '||l_count);
end loop;
exception when others then
if sqlcode=-942 then dbms_output.put_line('table '||v_table_name||' does not exist');
else raise;
end if;
end;

begin 
 open c;
     for cus in (select table_name_arc
                     from rb_gagnatorg_load_tables lt where lt.load_batch_name = 'TDC')
     loop
          output_result();
     end loop;
 close c;
end;
/
