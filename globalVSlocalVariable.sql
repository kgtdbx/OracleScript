any variable defined outside of a procedure/function is a global variable and maintains its state for the duration of the session.
when using packages you can put variables in the specification (global, public) or in the body (global, private) or in the local procedures/functions themselves (local, not global, private)
--
variables defined outside of procedures or funtions in packages by definition are initialized only once. 

Just like variables in any language. They maintain a state, they are valid from call to call to the database. They are global variables, persistent for the life of your session. 

--to test it
/*
It is an optimization in 10gr2

it is recognizing that the code is bit for bit, byte for byte "the same", it did nothing therefore.

Add a newline to the second package spec, it will change the behavior.


as far as the database is concerned - you didn't create or replace anything.

If we query out last_ddl_time, we can see this:
*/
ops$tkyte@ORA10GR2> set serveroutput on
ops$tkyte@ORA10GR2> select object_type, last_ddl_time from user_objects where object_name = 'MY_PAK';

OBJECT_TYPE         LAST_DDL_TIME
------------------- --------------------
PACKAGE             15-jan-2006 15:29:13
PACKAGE BODY        15-jan-2006 15:29:13

ops$tkyte@ORA10GR2> begin
  2    dbms_output.put_line('global variable '|| my_pak.g_day);
  3    my_pak.set_day('SUN');
  4    dbms_output.put_line('global variable '|| my_pak.g_day);
  5  end;
  6  /
global variable SAT
global variable SUN

PL/SQL procedure successfully completed.

ops$tkyte@ORA10GR2> exec dbms_lock.sleep(3);

PL/SQL procedure successfully completed.

ops$tkyte@ORA10GR2> 
create or replace package my_pak as
 g_day   varchar2(5) := 'SAT';
 procedure set_day(p_day in varchar2);
end;
/

Package created.

ops$tkyte@ORA10GR2> 
create or replace package body my_pak as
  procedure set_day(p_day in varchar2) is
  begin
     g_day := p_day;
  end set_day;
 end;
 /

Package body created.

ops$tkyte@ORA10GR2> set serveroutput on
ops$tkyte@ORA10GR2> alter session set nls_date_format = 'dd.mm.yyyy hh24:mi:ss';
ops$tkyte@ORA10GR2> select object_type, last_ddl_time from user_objects where object_name = 'MY_PAK';

OBJECT_TYPE         LAST_DDL_TIME
------------------- --------------------
PACKAGE             15-jan-2006 15:29:13
PACKAGE BODY        15-jan-2006 15:29:13

ops$tkyte@ORA10GR2> 
begin
  dbms_output.put_line('global variable '|| my_pak.g_day);
  my_pak.set_day('SUN');
  dbms_output.put_line('global variable '|| my_pak.g_day);
end;
/
global variable SUN
global variable SUN

PL/SQL procedure successfully completed.

<b>see, it did "nothing", but if we just:</b>

ops$tkyte@ORA10GR2> select object_type, last_ddl_time from user_objects where object_name = 'MY_PAK';

OBJECT_TYPE         LAST_DDL_TIME
------------------- --------------------
PACKAGE             15-jan-2006 15:30:57
PACKAGE BODY        15-jan-2006 15:30:57

ops$tkyte@ORA10GR2> begin
  2    dbms_output.put_line('global variable '|| my_pak.g_day);
  3    my_pak.set_day('SUN');
  4    dbms_output.put_line('global variable '|| my_pak.g_day);
  5  end;
  6  /
global variable SAT
global variable SUN

PL/SQL procedure successfully completed.

ops$tkyte@ORA10GR2> exec dbms_lock.sleep(3);

PL/SQL procedure successfully completed.

ops$tkyte@ORA10GR2> 
create or replace package my_pak as
 g_day   varchar2(5) := 'SAT';

 procedure set_day(p_day in varchar2);
end;
/

Package created.

<b>Note the additional newline, nothing else...</b>

ops$tkyte@ORA10GR2> 
create or replace package body my_pak as
 procedure set_day(p_day in varchar2) is
 begin
    g_day := p_day;
 end set_day;
end;
/

Package body created.

ops$tkyte@ORA10GR2> set serveroutput on
ops$tkyte@ORA10GR2> select object_type, last_ddl_time from user_objects where object_name = 'MY_PAK';

OBJECT_TYPE         LAST_DDL_TIME
------------------- --------------------
PACKAGE             15-jan-2006 15:31:00
PACKAGE BODY        15-jan-2006 15:31:00

ops$tkyte@ORA10GR2> begin
  2    dbms_output.put_line('global variable '|| my_pak.g_day);
  3    my_pak.set_day('SUN');
  4    dbms_output.put_line('global variable '|| my_pak.g_day);
  5  end;
  6  /
global variable SAT
global variable SUN

PL/SQL procedure successfully completed.


--even after compile command gv initialized again
alter package my_pak compile package;
alter package my_pak compile body;

ops$tkyte@ORA10GR2> begin
  2    dbms_output.put_line('global variable '|| my_pak.g_day);
  3    my_pak.set_day('SUN');
  4    dbms_output.put_line('global variable '|| my_pak.g_day);
  5  end;
  6  /
global variable SAT
global variable SUN

PL/SQL procedure successfully completed.

--############################################--


if you use a connection pool, you flip flop from session to session. global temporary tables are session or transaction specific. 

You either have to retain this state 

a) in a database table (like I do), with a sessionid to identify the rows for your session 
b) in a global application context 
</code> http://asktom.oracle.com/pls/ask/search?p_string=%22global+application+context%22 <code>
c) in your middle tier 
d) in your cookies. 

---

Well, thats not like a static variable in a java program -- the analogy would be that if I changed a static variabe in java -- every program running out there would see the same value! 

PLSQL, just like java, runs in a VM. Every user runs their own copy. A PLSQL global is just like a Java global in this regards. Every package (class) that access it in the same session ( process) will see the same value. 

So, plsql and java are alike in this case. 

Your solution will be to use a database table: 

create table global_value ( x int ); 
insert into global_value values ( 0 ); 


create or replace package get_global 
as 
function val return number; 
procedure set_val( p_x in number ); 
end; 
/ 

create or replace package body get_global 
as 

function val return number 
as 
l_x number; 
begin 
select x into l_x from global; 
return l_x; 
end; 

procedure set_val( p_x in number ) 
as 
pragma autonomous_transaction; 
begin 
update global set x = p_x; 
commit; 
end; 

end; 
/ 

You need the locking and concucrrency controls afforded by the database, you need to use the database to share the information.



----------------------------------------------------------------------
Hi Tom, 
We have a similar requirement to have global values accesible across multiple sessions. 
We are currently in the process of upgrading to 9i, and was thinking of using the global context feature to do that. 
Can you provide us with a simple example to do this on 9i using global context? 

----------------------------------------------------------------------
ops$tkyte@ORA920> create or replace context App_Ctx using My_pkg
  2  ACCESSED GLOBALLY
  3  /

Context created.

ops$tkyte@ORA920>
ops$tkyte@ORA920> create or replace package my_pkg
  2  as
  3          procedure set_ctx( p_name       in varchar2,
  4                                             p_value      in varchar2 );
  5
  6          procedure init;
  7  end;
  8  /

Package created.

ops$tkyte@ORA920>
ops$tkyte@ORA920> create or replace package body my_pkg
  2  as
  3          g_session_id number := 1234;
  4
  5          procedure init
  6          is
  7          begin
  8                  null;  -- elaboration code does it all
  9          end;
 10
 11          procedure set_ctx( p_name       in varchar2,
 12                                             p_value      in varchar2 )
 13          as
 14          begin
 15                  dbms_session.set_context
 16                  ( 'App_Ctx', p_name, p_value, NULL, g_session_id );
 17          end;
 18  begin
 19                  dbms_session.set_identifier( g_session_id );
 20  end;
 21  /

Package body created.

ops$tkyte@ORA920> pause

ops$tkyte@ORA920>
ops$tkyte@ORA920> exec my_pkg.set_ctx( 'Var1', 'Val1' );

PL/SQL procedure successfully completed.

ops$tkyte@ORA920> exec my_pkg.set_ctx( 'Var2', 'Val2' );

PL/SQL procedure successfully completed.

ops$tkyte@ORA920>
ops$tkyte@ORA920> select sys_context( 'app_ctx', 'var1' ) var1,
  2         sys_context( 'app_ctx', 'var2' ) var2
  3    from dual
  4  /

VAR1       VAR2
---------- ----------
Val1       Val2

ops$tkyte@ORA920>
ops$tkyte@ORA920> connect /
Connected.
ops$tkyte@ORA920>
ops$tkyte@ORA920> select sys_context( 'app_ctx', 'var1' ) var1,
  2         sys_context( 'app_ctx', 'var2' ) var2
  3    from dual
  4  /

VAR1       VAR2
---------- ----------


ops$tkyte@ORA920>
ops$tkyte@ORA920> exec my_pkg.init

PL/SQL procedure successfully completed.

ops$tkyte@ORA920>
ops$tkyte@ORA920> select sys_context( 'app_ctx', 'var1' ) var1,
  2         sys_context( 'app_ctx', 'var2' ) var2
  3    from dual
  4  /

VAR1       VAR2
---------- ----------
Val1       Val2


g_session_id is just some arbitrary session id that all sessions that wish to shared this context must use. 
I showed "another program" using the same number -- i logged out / back in -- that is "another program" 
if you want to share the context, the key is 1234 in this example. 



----------------------------------------------------------------
to use dbms_session.set_context, you have to be in the procedure, function or package that was bound to the context when you created it:

in the following ONLY P can set the context, no one else (that is what is magic about them)

ops$tkyte@ORA9IR2> create or replace context my_ctx using p
  2  /
 
Context created.
 
ops$tkyte@ORA9IR2>
ops$tkyte@ORA9IR2> create or replace procedure p
  2  as
  3  begin
  4          dbms_session.set_context( 'my_ctx', 'x', 5 );
  5  end;
  6  /
 
Procedure created.
 
ops$tkyte@ORA9IR2>
ops$tkyte@ORA9IR2> create or replace procedure p2
  2  as
  3  begin
  4          dbms_session.set_context( 'my_ctx', 'x', 5 );
  5  end;
  6  /
 
Procedure created.
 
ops$tkyte@ORA9IR2> exec dbms_session.set_context( 'my_ctx', 'x', 5 );
BEGIN dbms_session.set_context( 'my_ctx', 'x', 5 ); END;
 
*
ERROR at line 1:
ORA-01031: insufficient privileges
ORA-06512: at "SYS.DBMS_SESSION", line 78
ORA-06512: at line 1
 
 
ops$tkyte@ORA9IR2> exec p2
BEGIN p2; END;
 
*
ERROR at line 1:
ORA-01031: insufficient privileges
ORA-06512: at "SYS.DBMS_SESSION", line 78
ORA-06512: at "OPS$TKYTE.P2", line 4
ORA-06512: at line 1
 
 
ops$tkyte@ORA9IR2> exec p
 
PL/SQL procedure successfully completed.
 