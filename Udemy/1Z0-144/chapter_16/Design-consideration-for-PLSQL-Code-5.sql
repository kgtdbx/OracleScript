select * from employees
where employee_id in (100,101,102);

create or replace procedure update_sal_withoutbulk
( p_amount number )
is
type emp_table_type is table of number index by binary_integer;
emp_table emp_table_type;
begin
emp_table(1):=100;
emp_table(2):=101;
emp_table(3):=102;
  for i in emp_table.first..emp_table.last
  loop
  update employees
  set salary=salary+p_amount
  where employee_id =emp_table(i);
  end loop;
  commit;
end;

execute update_sal_withoutbulk(10);

select * from employees
where employee_id in (100,101,102);
-------------------------------------------------------------
--here with bulk using  forall
--no need for the loop
create or replace procedure update_sal_withbulk
( p_amount number )
is
type emp_table_type is table of number index by binary_integer;
emp_table emp_table_type;
begin
emp_table(1):=100;
emp_table(2):=101;
emp_table(3):=102;
  forall i in emp_table.first..emp_table.last
  update employees
  set salary=salary+p_amount
  where employee_id =emp_table(i);
  commit;
end;

execute update_sal_withbulk(10);

select * from employees
where employee_id in (100,101,102);
-------------------------------------------------------------------

desc employees;

drop table ename;

create table ename
as select distinct first_name from employees;

select first_name  
from ename;
 

declare
type ename_t  is table of varchar2(100);
ename_table ename_t:=ename_t();
c number:=0;
begin
for i in (select * from ename )
  loop
  c:=c+1;
  ename_table.extend;
  ename_table(c):=i.first_name;
  end loop;

  for i in ename_table.first.. ename_table.last
  loop
   ---begin
  update ename
  set first_name=first_name||' to be added:)' --14 char
  where first_name=ename_table(i);
  --exception
  ---end
  end loop;
  exception 
  when others
  then null;

end;

select * from ename
----------------------------

drop table ename;

create table ename
as select distinct first_name from employees;

select first_name  
from ename;
 

declare
type ename_t  is table of varchar2(100);
ename_table ename_t:=ename_t();
c number:=0;
begin
for i in (select * from ename )
  loop
  c:=c+1;
  ename_table.extend;
  ename_table(c):=i.first_name;
  end loop;

  forall i in ename_table.first.. ename_table.last save exceptions
  update ename
  set first_name=first_name||' to be added:)' --14 char
  where first_name=ename_table(i);

  exception 
  when others
  then null;

end;

select * from ename





