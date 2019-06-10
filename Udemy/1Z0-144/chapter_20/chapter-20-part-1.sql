SELECT text 
from ALL_source
WHERE lower(name)='dbms_db_version'
order by line

begin
dbms_output.put_line(dbms_db_version.version);
dbms_output.put_line(dbms_db_version.release);
  if   dbms_db_version.ver_le_12  or   dbms_db_version.ver_le_12_1 
  or   dbms_db_version.ver_le_12_2  then
  dbms_output.put_line('it is 12c :)');
  end if;
  
end;

-----------------------
create or replace function get_sal
(p_emp_id number)
return number  $if dbms_db_version.version>=11 $then result_cache $end
is
v_sal number;
begin 
  select salary into v_sal
  from employees
  where employee_id=p_emp_id;
  
  return v_sal;
  
end;
------------------------
SELECT name, value
FROM v$parameter
WHERE name ='plsql_optimize_level' ;


begin
dbms_output.put_line($$plsql_Code_type);
dbms_output.put_line($$plsql_optimize_level);
dbms_output.put_line($$plsql_warnings);
end;

----------------------


create or replace procedure g_test
is
begin 
dbms_output.put_line('test');
end;


create or replace procedure g_test
is
begin 
  $if $$plsql_optimize_level <>3 $then
  $error 'it should be compiled with plsql_optimize_level=3 '  $end
  $end
dbms_output.put_line('test');
end;

alter session set plsql_optimize_level=3;

create or replace procedure g_test
is
begin 
  $if $$plsql_optimize_level <>3 $then
  $error 'it should be compiled with plsql_optimize_level=3 '  $end
  $end
dbms_output.put_line('test');
end;

