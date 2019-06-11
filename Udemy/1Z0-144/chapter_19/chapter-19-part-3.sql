--to see the curr value of plsql_warnings

--1 v$parameter
select name,value 
from v$parameter
where name='plsql_warnings'

--2 dbms_warning.get_warning_setting_string()
declare
s varchar2(100);
begin
s:= dbms_warning.get_warning_setting_string();
dbms_output.put_line(s);
end;

--now the status is plsql_warnings	DISABLE:ALL
--let us do this
--it will compile without any warning

drop PROCEDURE P11;

CREATE OR REPLACE PROCEDURE P11
(p OUT  VARCHAR2) 
IS
  BEGIN
    p := 'test';
END;



select * from user_plsql_object_settings
where name ='P11'

--now see the warning
ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';

CREATE OR REPLACE PROCEDURE P11
(p OUT  VARCHAR2) 
IS
  BEGIN
    p := 'test';
END;
 
select * from user_errors
where name='P11'

select * from user_plsql_object_settings
where name ='P11'

alter PROCEDURE  P11 compile PLSQL_WARNINGS='DISABLE:ALL';

select * from user_plsql_object_settings
where name ='P11'



