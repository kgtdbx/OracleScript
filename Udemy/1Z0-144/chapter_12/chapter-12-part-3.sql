--we can create package specification without body
--this used when we want to define global variable

create or replace package global_Measurement 
is

  c_mile_to_km   constant number:=1.6093;
  c_kilo_to_mile constant number:=0.6214;

end;

execute dbms_output.put_line('60 mile:='||60* global_Measurement.c_mile_to_km||' KM' );

execute dbms_output.put_line('100 KM:='||100* global_Measurement.c_kilo_to_mile||' Mile' );

-- now i can create function that read form this package

create or replace function get_mile_to_km
( p_value number )
return number
is
begin
  
  return p_value* global_Measurement.c_mile_to_km;
  
end;

select get_mile_to_km(100) from dual;

-----------------------------------------------------

--very good thing you should know
--you can define a procedure or function inside pl/sql block
--but this will be used only in this block

declare
  function get_sysdate 
  return date
  is 
  begin
  return sysdate;
  end;
  
begin

 dbms_output.put_line(get_sysdate);
 
end;



