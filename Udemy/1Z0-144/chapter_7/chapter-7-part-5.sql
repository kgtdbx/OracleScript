declare
type tab_no is table of varchar2(100)
index by pls_integer;

v_tab_no tab_no;
v_total number;

begin
v_tab_no(1):='khaled';
v_tab_no(2):='ahmed';
v_tab_no(3):='jad';
v_tab_no(6):='nader';
v_tab_no(5):='joan';

 for i in 1..10
 loop
    if v_tab_no.exists(i) then
    dbms_output.put_line('the element '||i||' is exist in the array and='||v_tab_no(i));
    else
    dbms_output.put_line('the element '||i||' is not exist in the array');
    end if;
 end loop;
 
 v_total:=v_tab_no.count;
dbms_output.put_line('the total elements in the array='||v_total);
dbms_output.put_line('the first element INDEX in the array='||v_tab_no.first);
dbms_output.put_line('the NEXT element INDEX AFTER INDEX 3='||v_tab_no.NEXT(3));
end;