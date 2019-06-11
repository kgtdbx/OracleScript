--dynamic sql with single row query
declare
v_ename varchar2(100);
begin
execute immediate 'select first_name from employees where employee_id=100'
into v_ename;
DBMS_OUTPUT.put_line(v_ename);
end;


declare
v_ename varchar2(100);
vno number:=200;
begin
execute immediate 'select first_name from employees where employee_id=:c' 
into v_ename using vno; --note: the into should be first then the using
DBMS_OUTPUT.put_line(v_ename);
end;

--------------------------------------------------

create or replace function get_emp
(p_id number)
return employees%rowtype
is
emp_rec employees%rowtype;
begin
  select * into emp_rec
  from employees
  where employee_id=p_id;
  
  return emp_rec;
end;

--you can not use this function in select, cz i retrive %rowtype
select get_emp(100) from dual;


declare
emp_rec employees%rowtype;
begin
emp_rec:=get_emp(100);
dbms_output.put_line(emp_rec.employee_id||' '||emp_rec.first_name );
end;
--------------------------------------------------------------
--dynamic sql with single row query
create or replace function get_emp2
(p_id number)
return employees%rowtype
is
emp_rec employees%rowtype;
v_query varchar2(1000);
begin
  v_query:='select * from employees where employee_id=:1';
  execute immediate v_query into emp_rec using p_id;
  return emp_rec;
end;


declare
emp_rec employees%rowtype;
begin
emp_rec:=get_emp2(105);
dbms_output.put_line(emp_rec.employee_id||' '||emp_rec.first_name );
end;

