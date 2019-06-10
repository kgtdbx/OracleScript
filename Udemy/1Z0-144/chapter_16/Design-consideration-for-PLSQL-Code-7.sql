drop table ename2;

create table ename2
as select employee_id, first_name
from employees;

select * from ename2;

declare
type emp_t is table of varchar2(100) index by binary_integer;
emp_table emp_t;
c number:=0;
begin
    for i in (select  employee_id, first_name from ename2)
    loop
    c:=c+1;
    emp_table(c):=i.first_name;
    end loop;
    
    for i in emp_table.first..emp_table.last
    loop
    dbms_output.put_line(emp_table(i));
    end loop;

end;
----------------------------

declare
type emp_t is table of varchar2(100) index by binary_integer;
emp_table emp_t;
begin
    select first_name bulk collect into emp_table
    from ename2;
    
   for i in emp_table.first..emp_table.last
    loop
    dbms_output.put_line(emp_table(i));
    end loop;

end;



