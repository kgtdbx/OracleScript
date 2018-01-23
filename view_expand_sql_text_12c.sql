SET SERVEROUTPUT ON 
DECLARE
  l_clob CLOB;
BEGIN
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => 'SELECT * FROM rl_run_statistics',
    output_sql_text => l_clob
  );

  DBMS_OUTPUT.put_line(l_clob);
END;
/