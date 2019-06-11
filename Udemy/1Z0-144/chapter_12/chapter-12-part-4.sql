create or replace package p_test
is
c_var1 constant number:=10;
c_var2 varchar2(100):='welcome';

procedure print;
end;
------------
create or replace package body p_test
is
c_var3 varchar2(100):='hi there'; 
 procedure print
 is 
 c_var4 varchar2(100):='hi';
 begin
 dbms_output.put_line('this variable came from package spec. '||c_var1);
 dbms_output.put_line('this variable came from package spec. '||c_var2);
 dbms_output.put_line('this variable came from package body. '||c_var3);
  dbms_output.put_line('this variable came from print Proc. '||c_var4);
 end;

end;

execute p_test.print;

---------------------------------------------------------------

--note that we can update the package body without compile the spec.
create or replace package body p_test
is
c_var3 varchar2(100):='hi there'; 
 procedure print
 is 
 c_var4 varchar2(100):='hi';
 begin
 dbms_output.put_line('this variable came from package spec. '||c_var1);
 dbms_output.put_line('this variable came from package spec. '||c_var2);
 dbms_output.put_line('this variable came from package body. '||c_var3);
  dbms_output.put_line('this variable came from print Proc. '||c_var4);
 end;
 
 begin
dbms_output.put_line('this is optional');
end;

execute p_test.print;
----------------------------------------------------

--now let us try to change the package spec
--not a major change
create or replace package p_test
is
c_var1 constant number:=10;
c_var2 varchar2(100):='welcome';
p_n number;
procedure print;
end;

execute p_test.print;

--now let us try to change the package spec again
--a major change/ add new subprogram
create or replace package p_test
is
c_var1 constant number:=10;
c_var2 varchar2(100):='welcome';
p_n number;
procedure print;
function get_name (p number) return varchar2;
end;

execute p_test.print;
-----------------------------------------

select * from user_objects
where oBject_name='P_TEST'

SELECT * FROM USER_SOURCE
WHERE NAME='P_TEST'
AND TYPE='PACKAGE';

SELECT * FROM USER_SOURCE
WHERE NAME='P_TEST'
AND TYPE='PACKAGE BODY';

--to drop package specification and body   

drop package p_test;

--to drop only package body 

drop package body p_test;

