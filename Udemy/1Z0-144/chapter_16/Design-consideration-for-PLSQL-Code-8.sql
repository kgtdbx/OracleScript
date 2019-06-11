--using bulk colelct in cursor

--------without bulk-------------
declare
type emp_t is table of employees%rowtype;
emp_table emp_t;
cursor emp_c is select * from employees;
c number:=0;
begin
emp_table:=emp_t();
open emp_c;
    loop
    emp_table.extend;
    c:=c+1;
    fetch emp_c into emp_table(c);
     exit when emp_c%notfound;
    dbms_output.put_line(emp_table(c).first_name);
     end loop;
     close emp_c;
end;
--------------------------------

-----------with bulk collect-----------
declare
type emp_t is table of employees%rowtype;
emp_table emp_t;
cursor emp_c is select * from employees;
begin
open emp_c;
fetch emp_c bulk collect into emp_table;

for i in emp_table.first..emp_table.last
loop
dbms_output.put_line(emp_table(i).first_name);
end loop;

end;
------------------------------------

---------with bulk and limit------------------
declare
type emp_t is table of employees%rowtype;
emp_table emp_t;
cursor emp_c is select * from employees;
begin
open emp_c;
fetch emp_c bulk collect into emp_table limit 5;

for i in emp_table.first..emp_table.last
loop
dbms_output.put_line(emp_table(i).first_name);
end loop;

end;
----------------------------



