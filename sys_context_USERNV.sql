SELECT 
  SYS_CONTEXT ( 'userenv', 'AUTHENTICATION_TYPE' ) authent
, SYS_CONTEXT ( 'userenv', 'CURRENT_SCHEMA' )      curr_schema
, SYS_CONTEXT ( 'userenv', 'CURRENT_USER' )        curr_user
, SYS_CONTEXT ( 'userenv', 'DB_NAME' )             db_name
, SYS_CONTEXT ( 'userenv', 'DB_DOMAIN' )           db_domain
, SYS_CONTEXT ( 'userenv', 'HOST' )                host
, SYS_CONTEXT ( 'userenv', 'IP_ADDRESS' )          ip_address
, SYS_CONTEXT ( 'userenv', 'OS_USER' )             os_user
FROM dual
;

begin
 dbms_output.put_line(sys_context('USERENV', 'TERMINAL'));
 dbms_output.put_line(sys_context('USERENV', 'SID')); 
end;

/* 
FUNCTION f_get_spid
  RETURN VARCHAR2 AS
  v_spid VARCHAR2(255);

  BEGIN
    SELECT SUBSTR(tracefile,INSTR(tracefile,'/',-1)+1)
      INTO v_spid
      FROM v$process
     WHERE addr=(SELECT paddr FROM v$session WHERE sid=(SELECT sys_context('userenv','SID') FROM DUAL));
     RETURN v_spid;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_get_spid;
  */
