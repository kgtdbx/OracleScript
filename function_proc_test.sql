drop function get_name;

create or replace function get_name(v_name varchar2) return varchar2
as
l_name varchar2(100);
begin
l_name:=v_name;
return l_name;
end;
/


set serveroutput on
declare
v_stmt varchar(4000):=deposits.get_name(v_name=>'default');

procedure dbmsoutput(ip_stmt varchar)
is
begin
SYS.dbms_output.put_line(ip_stmt);
end;

begin
dbmsoutput(v_stmt);
end;
/


set serveroutput on
declare
v_stmt varchar(4000);

procedure dbmsoutput(ip_stmt varchar)
is
begin
SYS.dbms_output.put_line(ip_stmt);
end;

begin
dbmsoutput( get_name(v_name=>'default2'));
end;
/




set serveroutput on
declare
v_stmt varchar(4000):='dafault';

procedure dbmsoutput(ip_stmt varchar)
is
begin
SYS.dbms_output.put_line(ip_stmt);
end;
begin
dbmsoutput(v_stmt);
end;
/
