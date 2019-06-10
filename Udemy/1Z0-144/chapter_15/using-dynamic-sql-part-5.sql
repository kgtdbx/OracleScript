--we can also use dynamic sql to execute anonymous-block

declare
     v_code varchar2(100):=
    'begin
    dbms_output.put_line(''welcome'');
    end;
    ';
begin
execute immediate v_code;
end;
-----------------------

-- we can do this statement to compile a procedure
alter procedure ADD_ROWS compile;

--we can do this statement to compile a function
alter function GET_SAL compile;

-- we can do this statement to compile a package specification
alter package AREA compile specification;

-- we can do this statement to compile a package body
alter package AREA compile body;
---------------------------------------------
create or replace procedure compile_any_plsql
(p_name varchar2, p_type varchar2, p_option varchar2 default null)
is
 v_comp_code varchar2(1000):=
 'alter '||p_type||'  '||p_name||' compile '||p_option;
begin
execute immediate v_comp_code;
 end;
 
execute compile_any_plsql ('AREA','package','specification');
execute compile_any_plsql ('AREA','package','body');
execute compile_any_plsql ('ADD_ROWS','procedure');
execute compile_any_plsql ('GET_SAL','function');




