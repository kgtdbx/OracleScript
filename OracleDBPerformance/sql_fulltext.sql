SET HEA ON LIN 500 PAGES 100 TAB OFF FEED OFF ECHO OFF VER OFF TRIMS ON TRIM ON TI OFF TIMI OFF;
SET LONG 5000 LONGC 200;

PRO 1. Enter SQL_ID
DEF sql_id = '&1.';

rem COL sql_text FOR A200;
SET SERVEROUTPUT ON 
DECLARE
  l_clob CLOB;
BEGIN
  SELECT SQL_FULLTEXT into l_clob
  FROM v$sql WHERE sql_id = '&&sql_id' AND ROWNUM = 1;
  DBMS_OUTPUT.put_line(l_clob);
  EXCEPTION 
    WHEN NO_DATA_FOUND 
        THEN raise_application_error (-20001,'No data found for entered sql_id. Try another one.');
    WHEN OTHERS 
        THEN RAISE;
END;
/

UNDEF 1 sql_id
