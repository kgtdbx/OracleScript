--Script  ''How did I get here?'' DBMS_UTILITY.FORMAT_CALL_STACK
--Statement 1

CREATE OR REPLACE PROCEDURE proc1 
IS 
BEGIN 
   DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack); 
END; 

--Statement 2
CREATE OR REPLACE PACKAGE pkg1 
IS 
   PROCEDURE proc2; 
END pkg1; 

--Statement 3
CREATE OR REPLACE PACKAGE BODY pkg1 
IS 
   PROCEDURE proc2 
   IS 
   BEGIN 
      proc1; 
   END; 
END pkg1; 


--Statement 4
CREATE OR REPLACE PROCEDURE proc3 
IS 
BEGIN 
   FOR indx IN 1 .. 1000 
   LOOP 
      NULL; 
   END LOOP; 
 
   pkg1.proc2; 
END; 


--Statement 5
CALL proc3

/*****
----- PL/SQL Call Stack -----
  object      line  frame       object
  handle    number  size        name
0x4eabcf870         4          80  procedure SQL_ZCJCCNHJLXJQCXSZONHPCYQJX.PROC1
0x95e036580         6          24  package body SQL_ZCJCCNHJLXJQCXSZONHPCYQJX.PKG1.PROC2
0x7e43a90a0         9          24  procedure SQL_ZCJCCNHJLXJQCXSZONHPCYQJX.PROC3
0x7749b0bf0         1          24  anonymous block
0x9ee742398      1721          88  package body SYS.DBMS_SQL.EXECUTE
0x9fe89e628      1368        4848  package body LIVESQL.ORACLE_SQL_EXEC.RUN_BLOCK
0x9fe89e628      1462         960  package body LIVESQL.ORACLE_SQL_EXEC.RUN_SQL
0x9fe89e628      1792        4744  package body LIVESQL.ORACLE_SQL_EXEC.IMITATE_SQLPLUS_CMD
0x9fe89e628      1894        5008  package body LIVESQL.ORACLE_SQL_EXEC.RUN_STATEMENTS
0x9fe89e628      2019        2528  package body LIVESQL.ORACLE_SQL_EXEC.RUN_STMTS
0x996637720      2320        3712  package body LIVESQL.ORACLE_SQL_SCHEMA.RUN_SAVED_SESSION
0x9f6817280       341         112  package body LIVESQL.ORACLE_SQL_SCHEMA_PUB.RUN_SAVED_SESSION
0x7b4eecbd8        22        1616  anonymous block
0x9ee742398      1721          88  package body SYS.DBMS_SQL.EXECUTE
0x9de9e49a0      1880         936  package body APEX_050100.WWV_FLOW_DYNAMIC_EXEC.RUN_BLOCK5
0x9de9e49a0       936         168  package body APEX_050100.WWV_FLOW_DYNAMIC_EXEC.EXECUTE_PLSQL_CODE
0x9e724dca8        71         256  package body APEX_050100.WWV_FLOW_PROCESS_NATIVE.PLSQL
0x9e724dca8      1132        4544  package body APEX_050100.WWV_FLOW_PROCESS_NATIVE.EXECUTE_PROCESS
0x9fede7878      2399        2744  package body APEX_050100.WWV_FLOW_PLUGIN.EXECUTE_PROCESS
0x996a4cba8       200        2376  package body APEX_050100.WWV_FLOW_PROCESS.PERFORM_PROCESS
0x996a4cba8       443       11744  package body APEX_050100.WWV_FLOW_PROCESS.PERFORM
0x9eec01c30      4857          40  pac

*/

