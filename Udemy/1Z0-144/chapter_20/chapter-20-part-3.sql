SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

SELECT name, value
FROM v$parameter
WHERE name ='plsql_code_type' ;

--the values in plsql_ccflags could be pls_integer,boolean, null
alter session set plsql_ccflags='language:1,language:null,plsql_code_type:10';

SELECT name, value
FROM v$parameter
WHERE name ='plsql_code_type' ;


begin
dbms_output.put_line($$language);
dbms_output.put_line($$plsql_code_type);
dbms_output.put_line($$plsql_warnings);
end;
