SELECT name, value
FROM v$parameter
WHERE name ='plsql_optimize_level' ;


alter session set PLSQL_OPTIMIZE_LEVEL = 0;

SELECT name, value
FROM v$parameter
WHERE name ='plsql_optimize_level' ;

DECLARE
 A NUMBER; 
 B NUMBER; 
 C NUMBER;
 BEGIN
 DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'hh:mi:ss'));
 FOR I IN 1..100000000
 LOOP
 A := 1;
 B := 1;
 C := A+1;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'hh:mi:ss'));

 END;
----------------

alter session set PLSQL_OPTIMIZE_LEVEL = 2;

SELECT name, value
FROM v$parameter
WHERE name ='plsql_optimize_level' ;

DECLARE
 A NUMBER; 
 B NUMBER; 
 C NUMBER;
 BEGIN
 DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'hh:mi:ss'));
 FOR I IN 1..100000000
 LOOP
 A := 1;
 B := 1;
 C := A+1;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'hh:mi:ss'));

 END;
 --------------
 

 
