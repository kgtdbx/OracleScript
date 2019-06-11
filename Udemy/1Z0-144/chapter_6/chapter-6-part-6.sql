begin
  for i in 1..3

  loop
  dbms_output.put_line('welcome '||i);
  end loop;

end;
------------------------
begin
  for i in 1..1

  loop
  dbms_output.put_line('welcome '||i);
  end loop;

end;
--------------------
begin
  for i in 3..5

  loop
  dbms_output.put_line('welcome '||i);
  end loop;

end;
----------------

begin
  for i in reverse 1..3 

  loop
  dbms_output.put_line('welcome '||i);
  end loop;

end;
-------------------------

begin
  for i in 1..9/2

  loop
  dbms_output.put_line('welcome '||i);
  end loop;

end;
------------------------------------------------

declare
v_name varchar2(200);
begin
for i in 100..102
    loop
        select first_name||' '||last_name
        into v_name
        from
        employees
        where employee_id=i;
        
        dbms_output.put_line(i||':'||v_name);
        
    end loop;
end;



/*
try to do print this 

*
**
***
****
*****

*/


  


