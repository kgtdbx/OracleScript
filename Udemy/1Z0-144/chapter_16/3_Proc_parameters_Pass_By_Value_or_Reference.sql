--1  IN parameter always passed by reference
create or replace procedure pass_by_ref
( p_id in number ) --p_id called formal parameter
is
begin
--p_id :=555; --this is not valid
dbms_output.put_line(p_id);
end;

execute pass_by_ref (10); 
--10 is called actual parameter
/* Pass By Reference:no temporary buffer is needed and 
no copy forward and copy back operations happen
*/
--------------------------------------------------------------------------------  
/*2 
out/in out parameters can be passed 
1-Pass By Value ( default) 
2-Pass By Reference using no copy

/*
Pass By Value : The default action is to create a temporary buffer (formal parameter), 
copy the data from the parameter variable (actual parameter) to that buffer and work 
on the temporary buffer during the lifetime of the procedure. 
On successful completion of the procedure, 
the contents of the temporary buffer are copied back into the parameter variable. 
In the event of an exception occurring, the copy back operation does not happen.
*/

create or replace procedure pass_by_value1
( P_id IN out number)
is
begin
P_id:=P_id*10;
  if P_id>100 then
  raise VALUE_ERROR;
  end if;
end;

declare
v number:=20;---try first 5 then 20
begin
pass_by_value1(V);
dbms_output.put_line('NO ISSUE '||v);
EXCEPTION
WHEN VALUE_ERROR THEN 
dbms_output.put_line('EXCEPTION '||v);
end;
---------------------------------------------

create or replace procedure pass_by_ref
( P_id IN out nocopy number)
is
begin
P_id:=P_id*10;
  if P_id>100 then
  raise VALUE_ERROR;
  end if;
end;

declare
v number:=20;
begin
pass_by_ref(V);
dbms_output.put_line('NO ISSUE '||v);
EXCEPTION
WHEN VALUE_ERROR THEN 
dbms_output.put_line('EXCEPTION '||v);
end;
---------------------------------------------------------------
--nocopy will have no effects
--case 1
create or replace procedure pass_by_value3
( P_id IN out nocopy number)
is
begin
P_id:=P_id*10;
  if P_id>100 then
  raise VALUE_ERROR;
  end if;
end;

declare
v number(10):=20; --if the actual has size(FOR NUMBER ONLY ),nocopy not working
begin
pass_by_value3(V);
dbms_output.put_line('NO ISSUE '||v);
EXCEPTION
WHEN VALUE_ERROR THEN 
dbms_output.put_line('EXCEPTION '||v);
end;
--------------------------------------------------------------
--case 2
create or replace procedure pass_by_value4
( P_id IN out nocopy number)
is
begin
P_id:=P_id*10;
  if P_id>100 then
  raise VALUE_ERROR;
  end if;
end;

declare
v number NOT NULL :=20; --if the actual NOT NULL,nocopy not working
begin
pass_by_value4(V);
dbms_output.put_line('NO ISSUE '||v);
EXCEPTION
WHEN VALUE_ERROR THEN 
dbms_output.put_line('EXCEPTION '||v);
end;
------------------------------------------
----case 3
create or replace procedure pass_by_value5
( P_id IN out nocopy VARCHAR2)
is
begin
P_id:=P_id*10;
  if P_id>100 then
  raise VALUE_ERROR;
  end if;
end;

declare
v number :=20; --if the actual NEED IMPLICIT CONV ,nocopy not working
begin
pass_by_value5(V);
dbms_output.put_line('NO ISSUE '||v);
EXCEPTION
WHEN VALUE_ERROR THEN 
dbms_output.put_line('EXCEPTION '||v);
end;

------------------------------------------------

create or replace package nocopy_test
is
type number_t is table of varchar2(32767) index by binary_integer;
procedure pass_by_vale(nums in out number_t);
procedure pass_by_refernce(nums in out nocopy number_t);
procedure init;
end;

------------
create or replace package body nocopy_test
is
 l_numbers number_t;
 c_array_size number:=1000000;
 c_it number:=20;
    procedure pass_by_vale(nums in out number_t)
    is
    indx pls_integer;
    begin
    indx:=nums.count;
    end;

    procedure pass_by_refernce(nums in out nocopy number_t)
    is
    indx pls_integer;
    begin
    indx:=nums.count;
    end;
    
    procedure init
    is
    begin
    l_numbers.delete;
    for i in 1..c_array_size
    loop
    l_numbers(i):='s'||i;
    end loop;
    dbms_output.put_line('start '||to_char(sysdate,'hh:mi:ss') );
    for i in 1..1000
        loop
        pass_by_vale(l_numbers);
        end loop;
      
      dbms_output.put_line('end '||to_char(sysdate,'hh:mi:ss') );
      dbms_output.put_line('start '||to_char(sysdate,'hh:mi:ss'));
    for i in 1..1000
        loop
        pass_by_refernce(l_numbers);
        end loop;
        dbms_output.put_line('end '||to_char(sysdate,'hh:mi:ss'));
    
    end;
    
end;
-----------------------------


begin
nocopy_test.init;
end;










