create or replace package Persistent_state
is
g_var number:=10;
procedure update_g_var ( p_no number); 
end;
----
create or replace package body Persistent_state
is
      procedure update_g_var ( p_no number)
      is 
      begin 
      g_var:=p_no;
      dbms_output.put_line(g_var);
      end;
end;
----
execute Persistent_state.update_g_var(80);
variable test number;
execute :test:=Persistent_state.g_var;

print test

declare
x number;
begin
x:=Persistent_state.g_var;
dbms_output.put_line (x);
end;

-----------------------------------------------------------------------------------

--using PRAGMA SERIALLY_REUSABLE;
create or replace package Persistent_state
is
PRAGMA SERIALLY_REUSABLE;
g_var number:=10;

procedure update_g_var ( p_no number); 

end;

----
create or replace package body Persistent_state
is
 PRAGMA SERIALLY_REUSABLE;
      procedure update_g_var ( p_no number)
      is 
     
      begin 
      g_var:=p_no;
      dbms_output.put_line(g_var);
      end;

end;
----

execute Persistent_state.update_g_var(90);

variable test number;

execute :test:=Persistent_state.g_var;

print test



