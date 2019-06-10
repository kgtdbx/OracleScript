select name,value 
from v$parameter
where name='plsql_warnings';

ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';

create or replace function test_f
return number
is
v number:=0;
begin
return v;
v:=v+1; --THIS CODE WILL NEVER BE EXECUTED

end;

--now when you do this, this mean SEVERE&PERFORMANCE also will be disabled
--because oracle understand that you need to do new setting, and disable is the default
--so SEVERE&PERFORMANCE also will be disabled
ALTER SESSION SET PLSQL_WARNINGS='DISABLE:INFORMATIONAL';

select name,value 
from v$parameter
where name='plsql_warnings';

ALTER SESSION SET PLSQL_WARNINGS='DISABLE:INFORMATIONAL, ENABLE:SEVERE,ENABLE:PERFORMANCE';

select name,value 
from v$parameter
where name='plsql_warnings';

create or replace function test_f
return number
is
v number:=0;
begin
return v;
v:=v+1;

end;
------
--Warning(1,1): PLW-05018
ALTER SESSION SET PLSQL_WARNINGS='DISABLE:INFORMATIONAL, 
                                  ENABLE:SEVERE,ENABLE:PERFORMANCE,
                                  ERROR:05018';
select name,value 
from v$parameter
where name='plsql_warnings';

create or replace function test_f
return number
is
v number:=0;
begin
return v;
v:=v+1;

end;

