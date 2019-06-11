begin
for i in 1..30000
loop
dbms_output.put_line(lpad(i,7,0));
end loop;
end;

-----------------
begin
for i in 1..30000
loop
dbms_output.enable(1000000); --max 1,000,000
dbms_output.put_line(lpad(i,7,0));
end loop;
end;
-----------

--messages not sent untill the PLSQL completed
begin
dbms_output.put_line('test');
dbms_output.disable;
dbms_output.put_line('test2');
dbms_output.enable;
dbms_output.put_line('test3');
end;

-----------------

begin
dbms_output.put_line('welcome');
dbms_output.put('my ');
dbms_output.put('name ');
dbms_output.put('is ');
dbms_output.put('khaled ');
dbms_output.new_line; --you should use this after put
dbms_output.put_line('my name is khaled');
end;
--------------------
--get_line 
--we need 2 variables
DECLARE
buffer VARCHAR2(100);
status INTEGER;
begin
dbms_output.put_line('line 1');
dbms_output.put_line('line 2');
dbms_output.put_line('line 3');
--This procedure retrieves a single line of buffered information.
dbms_output.get_line(buffer, status); --both are out parameters
dbms_output.put_line('Buffer: ' || buffer);
dbms_output.put_line('Status: ' || status);
/*If the call completes successfully, 
then the status returns as 0. If there are no more 
lines in the buffer, then the status is 1.
*/
end;
----------------

DECLARE
buffer VARCHAR2(100);
status INTEGER;
v VARCHAR2(3000);
begin
dbms_output.put_line('line 1');
dbms_output.put_line('line 2');
dbms_output.put_line('line 3');
     for i in 1..3
     loop
    dbms_output.get_line(buffer, status);
    v:=v||buffer||chr(10);
    end loop;
dbms_output.put_line(v);
end;
---------------------

DECLARE
buffer DBMS_OUTPUT.CHARARR;
--  type chararr is table of varchar2(32767) index by binary_integer
v_line INTEGER;
begin

v_line:=10;
dbms_output.put_line('line 1');
dbms_output.put_line('line 2');
dbms_output.put_line('line 3');
dbms_output.put_line('line 4');
dbms_output.get_lines(buffer, v_line); --the first par is out, the second is in out
dbms_output.put_line( buffer(3) );
dbms_output.put_line( buffer(2) );
dbms_output.put_line( buffer(1 ));
dbms_output.put_line( buffer(4 ));

end;



