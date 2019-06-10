
begin
dbms_output.put_line('Welcome');
end;

-- example i want you to print   Father's day
begin
dbms_output.put_line('Father''s day'); 
end;
-----------------------------

--when your string contains an apstrophe
-- it is recomnded to use the q' notation 

select 'today is the father''s day' 
from dual;

--using ? as delimiter   q'?your text?'
select q'?today is the father's day?'  
from dual;

--using * as delimiter   q'*your text*'
select q'*today is the father's day*'  
from dual;

--using ( as delimiter   q'(your text)'
select q'(today is the father's day)'  
from dual;

--using [ as delimiter   q'[your text]'
select q'[today is the father's day not the mother's day ]'  
from dual;

--------------------------
begin
dbms_output.put_line('Father''s day');
dbms_output.put_line( q'(Father's day)'  ) ;
end;
