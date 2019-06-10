
--alter session set container=orclpdb

select * from user_tab_columns;

select * 
from user_constraints oc
where oc.table_name = 'REGIONS'
and oc.column_name = 'REGION_ID';


set serveroutput on
declare 
v_region_id         REGIONS.region_id%type;
v_EMP_SALARY_MIN    EMPLOYEES.SALARY%type;
sysdate number:=0;
begin
v_region_id:=null;
v_EMP_SALARY_MIN:=-1;
DBMS_OUTPUT.put_line(v_region_id);
DBMS_OUTPUT.put_line(v_EMP_SALARY_MIN);
DBMS_OUTPUT.put_line(sysdate);
end;


declare
v_nimber number:=1;
begin
loop
 exit when v_nimber > 5;
 DBMS_OUTPUT.put_line(replace(v_nimber, '*'));
  v_nimber:=v_nimber+1;
end loop;
end;


declare
v_nimber number:=1;
begin
loop
 exit when v_nimber > 5;
  case v_nimber 
    when 1 then DBMS_OUTPUT.put_line('*');
    when 2 then DBMS_OUTPUT.put_line('**');
    when 3 then DBMS_OUTPUT.put_line('***');
    when 4 then DBMS_OUTPUT.put_line('****');
    else DBMS_OUTPUT.put_line('*****');
    end case;
  v_nimber:=v_nimber+1;
end loop;
end;


declare
v_nimber number:=1;
begin
while v_nimber <= 5
loop
  case v_nimber 
    when 1 then DBMS_OUTPUT.put_line('*');
    when 2 then DBMS_OUTPUT.put_line('**');
    when 3 then DBMS_OUTPUT.put_line('***');
    when 4 then DBMS_OUTPUT.put_line('****');
    else DBMS_OUTPUT.put_line('*****');
    end case;
  v_nimber:=v_nimber+1;
end loop;
end;

declare

begin
for i in 1..5
loop
  case i 
    when 1 then DBMS_OUTPUT.put_line('*');
    when 2 then DBMS_OUTPUT.put_line('**');
    when 3 then DBMS_OUTPUT.put_line('***');
    when 4 then DBMS_OUTPUT.put_line('****');
    else DBMS_OUTPUT.put_line('*****');
    end case;
end loop;
end;

declare
v_star varchar2(100);

begin
for i in 1..5
loop
  for j in 1..i
  loop
  v_star := v_star||'*';

  end loop;
  
    DBMS_OUTPUT.put_line(v_star);
    v_star :=null;
end loop;
end;



declare
v_star varchar2(100) :=':)';
begin
for i in 1..5
loop  
    DBMS_OUTPUT.put_line(i);   
    continue when i>=3; --this mean stop execte next statement(s) when i>=3
    DBMS_OUTPUT.put_line(i||v_star);
end loop;
end;




declare
type t_emp is record
(v_emp_id           employees.EMPLOYEE_ID%type,
 v_first_name       employees.FIRST_NAME%type,
 v_SALARY           employees.SALARY%type);
v_emp t_emp;

begin
select EMPLOYEE_ID, FIRST_NAME, SALARY
into v_emp
from employees
where EMPLOYEE_ID = 100;
DBMS_OUTPUT.put_line(v_emp.v_emp_id||' '||v_emp.v_first_name||' '||v_emp.v_SALARY);
end;


create table c_departments as
select * from desc departments where 1=2;



declare
t_dep departments%rowtype;

begin
select *
into t_dep
from departments
where DEPARTMENT_ID = 100;
DBMS_OUTPUT.put_line(t_dep.DEPARTMENT_ID||' '||t_dep.DEPARTMENT_NAME||' '||t_dep.MANAGER_ID);
end;

declare
t_dep departments%rowtype;

begin
select *
into t_dep
from departments
where DEPARTMENT_ID = 100;

insert into c_departments values t_dep;
--DBMS_OUTPUT.put_line(t_dep.DEPARTMENT_ID||' '||t_dep.DEPARTMENT_NAME||' '||t_dep.MANAGER_ID);
end;


declare
t_dep departments%rowtype;

begin
t_dep.DEPARTMENT_ID := '11';
t_dep.MANAGER_ID := '1001';
t_dep.DEPARTMENT_NAME := 'aaaa';

update c_departments set
--DEPARTMENT_ID= t_dep.DEPARTMENT_ID, MANAGER_ID = t_dep.MANAGER_ID;
row=t_dep;
end;


select * from c_departments;


declare

type t_arrey is table of varchar2(100)
index by PLS_INTEGER;
v_arrey t_arrey;
begin
v_arrey(1):='Serhii';
v_arrey(5):='Anastasiia';
v_arrey(2):='Anna';

DBMS_OUTPUT.put_line(v_arrey(1)||' '||v_arrey(5)||' '||v_arrey(2));

end;


declare

type t_arrey is table of departments%rowtype
index by PLS_INTEGER;
v_arrey t_arrey;
begin
v_arrey(1).DEPARTMENT_ID:=1;
v_arrey(1).MANAGER_ID:=100;
v_arrey(1).DEPARTMENT_NAME:='A';

v_arrey(2).DEPARTMENT_ID:=3;
v_arrey(2).MANAGER_ID:=200;
v_arrey(2).DEPARTMENT_NAME:='B';


DBMS_OUTPUT.put_line(v_arrey(1).DEPARTMENT_ID||' '||v_arrey(1).MANAGER_ID||' '||v_arrey(1).DEPARTMENT_NAME);
DBMS_OUTPUT.put_line(v_arrey(2).DEPARTMENT_ID||' '||v_arrey(2).MANAGER_ID||' '||v_arrey(2).DEPARTMENT_NAME);

end;

declare
type t_arrey is table of departments%rowtype
index by PLS_INTEGER;
v_arrey t_arrey;
begin
for i in 200..201
loop
--if v_arrey.exists(i) then 
select * into v_arrey(i)
from departments
where MANAGER_ID = i;
--else DBMS_OUTPUT.put_line(v_arrey(i).DEPARTMENT_ID||' does not exist');
--end if;
end loop;

for i in v_arrey.first..v_arrey.last
loop
DBMS_OUTPUT.put_line(v_arrey(i).DEPARTMENT_ID||' '||v_arrey(i).MANAGER_ID||' '||v_arrey(i).DEPARTMENT_NAME);
end loop;
exception when no_data_found then null;
end;


select * 
from employees ee
where ee.department_id = 30;


declare
cursor cu_emp_dep_30
is
select employee_id, first_name 
from employees ee
where ee.department_id = 30;

v_emp_id        employees.employee_id%type;
v_first_name    employees.first_name%type; 

begin
open cu_emp_dep_30;
    loop
    fetch cu_emp_dep_30 into v_emp_id, v_first_name;
        exit when cu_emp_dep_30%notfound;
        DBMS_OUTPUT.put_line(v_emp_id||'  '|| v_first_name);
    end loop;
close cu_emp_dep_30;
end;

declare
cursor cu_emp_dep_30
is
select *
from employees ee
where ee.department_id = 30;

v_emp        employees%rowtype;

begin
open cu_emp_dep_30;
    loop
    fetch cu_emp_dep_30 into v_emp;
        exit when cu_emp_dep_30%notfound;
        DBMS_OUTPUT.put_line(v_emp.employee_id);
    end loop;
close cu_emp_dep_30;
end;

declare
cursor cu_emp_dep_30
is
select employee_id
from employees ee
where ee.department_id = 30;

v_emp        cu_emp_dep_30%rowtype;

begin

case when cu_emp_dep_30%isopen
     then close cu_emp_dep_30;
     else open cu_emp_dep_30;
end case;

    loop
    fetch cu_emp_dep_30 into v_emp.employee_id;
        exit when cu_emp_dep_30%notfound;
        update employees set first_name = first_name||100
        where employee_id=v_emp.employee_id;
    end loop;
--commit;
close cu_emp_dep_30;
end;


declare
cursor cu_emp_dep_30
is
select employee_id, first_name 
from employees ee;

v_emp_id        employees.employee_id%type;
v_first_name    employees.first_name%type; 

begin
    case when cu_emp_dep_30%isopen
         then close cu_emp_dep_30;
         else open cu_emp_dep_30;
    end case;
                DBMS_OUTPUT.put_line(cu_emp_dep_30%rowcount);
        loop
        fetch cu_emp_dep_30 into v_emp_id, v_first_name;
            exit when cu_emp_dep_30%notfound or cu_emp_dep_30%rowcount>10;
            DBMS_OUTPUT.put_line(v_emp_id||'  '|| v_first_name);
        end loop;
              DBMS_OUTPUT.put_line(cu_emp_dep_30%rowcount);      
close cu_emp_dep_30;
end;


declare
cursor cu_emp_dep_30
is
select employee_id, first_name 
from employees ee
where ee.department_id = 100;

v_cu_emp_dep_30 cu_emp_dep_30%rowtype;

begin
    case when cu_emp_dep_30%isopen
         then close cu_emp_dep_30;
         else open cu_emp_dep_30;
    end case;
loop
fetch cu_emp_dep_30 into v_cu_emp_dep_30.employee_id, v_cu_emp_dep_30.first_name;
exit when cu_emp_dep_30%notfound;
  DBMS_OUTPUT.put_line(v_cu_emp_dep_30.employee_id||'  '|| v_cu_emp_dep_30.first_name);
end loop;
close cu_emp_dep_30;  
end;



declare
cursor cu_emp_dep_30
is
select employee_id, first_name 
from employees ee
where ee.department_id = 100;

begin
 for i in cu_emp_dep_30
        loop
            DBMS_OUTPUT.put_line(i.employee_id||'  '|| i.first_name);
        end loop;
end;


declare
begin
 for i in (select employee_id, first_name 
            from employees ee
            where ee.department_id = 100)
        loop
            DBMS_OUTPUT.put_line(i.employee_id||'  '|| i.first_name);
        end loop;
end;


declare
cursor cu_emp_dep_30(v_dep_id number)
is
select employee_id, first_name 
from employees ee
where ee.department_id = v_dep_id;

begin
DBMS_OUTPUT.put_line('for dep 100:');   
 for i in cu_emp_dep_30(100)
        loop
            DBMS_OUTPUT.put_line(i.employee_id||'  '|| i.first_name);
        end loop;
DBMS_OUTPUT.put_line('for dep 90:');          
 for i in cu_emp_dep_30(90)
        loop
            DBMS_OUTPUT.put_line(i.employee_id||'  '|| i.first_name);
        end loop;        
end;

declare
cursor cu_emp_dep_30
is
select employee_id, first_name 
from employees ee
where ee.department_id = 100
for update;

begin
 for i in cu_emp_dep_30
        loop
            --DBMS_OUTPUT.put_line(i.employee_id||'  '|| i.first_name);
            update employees set
            first_name = i.first_name||'100'
            where current of cu_emp_dep_30;       
        end loop;
 --   commit;
end;


declare
v_first_name varchar2(100);
begin
select first_name into v_first_name
from employees ee
where ee.department_id = 'ss';
DBMS_OUTPUT.put_line(v_first_name);
exception
when too_many_rows  then DBMS_OUTPUT.put_line('Query return more then one rows');
when no_data_found  then DBMS_OUTPUT.put_line('Query dose not return any row');
when others  then DBMS_OUTPUT.put_line('Other error');
end;


create or replace procedure test_1(p_value1 in VARCHAR2 default 'sss', p_value2 out number default 1)
is
begin
DBMS_OUTPUT.put_line('hello I am a test_1 proc'||p_value1);
end test_1;

var value2 number;
exec test_1('rere', :value2);
print value2

sho err

select * from user_errors;

--------------

declare

v_char varchar2(200 := standard.to_char(100); 

begin 
--select standard.to_char(100) into v_char from dual; --error
DBMS_OUTPUT.PUT_LINE(v_char);
end;

select standard.to_char(100) from dual; --error

--------------

create or replace package xx 
is
c_number number :=null;
end xx;

create or replace package body xx
is
begin
DBMS_OUTPUT.PUT_LINE(c_number);
end;

drop  package xx; --it drop spec and body of pkg

--------------


