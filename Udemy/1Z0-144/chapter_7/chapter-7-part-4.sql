declare

type tab_no is table of varchar2(100)
index by pls_integer;

v_tab_no tab_no;

begin

v_tab_no(1):='khaled';
v_tab_no(6):='ahmed';
v_tab_no(4):='jad';

dbms_output.put_line(v_tab_no(1));
dbms_output.put_line(v_tab_no(6));
dbms_output.put_line(v_tab_no(4));
end;
-------------------------

declare

type tab_no is table of number
index by varchar2(100);

v_tab_no tab_no;

begin

v_tab_no('khaled'):=1;
v_tab_no('ahmed'):=6;
v_tab_no('jad'):=4;

dbms_output.put_line(v_tab_no('khaled'));
dbms_output.put_line(v_tab_no('ahmed'));
dbms_output.put_line(v_tab_no('jad'));
end;
--------------------------

declare
type tab_emp is table of varchar2(100)
index by pls_integer;

v_tab_emp tab_emp;
v_name varchar2(100);
begin
for i in 100..110
loop
 select first_name||' '||last_name into v_name
 from employees
 where employee_id=i;
  v_tab_emp(i):=v_name;
end loop;
  
  for i in 100..110
  loop
  dbms_output.put_line( v_tab_emp(i));
  end loop;

end;





