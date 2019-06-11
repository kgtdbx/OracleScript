--assume the lenght for tel is 12 
--example 971505914988
--we need a procedure to format the 971505914988 to 971(50)5914988 
create or replace procedure formate_tel
(p_tel in out varchar2)
is
begin
p_tel:=substr(p_tel,1,3)||'('||substr(p_tel,4,2)||')'||substr(p_tel,7);

end;
----------------

variable b_telephone varchar2(20);

execute :b_telephone:='971505914988';

execute formate_tel(:b_telephone);

print b_telephone;
------------------------------------------------------------------------

--another way

declare
v_tel varchar2(100):='971505914988';
begin
formate_tel(v_tel);
dbms_output.put_line(v_tel);
end;



