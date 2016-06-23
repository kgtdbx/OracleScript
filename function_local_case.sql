declare 
--p_key         varchar2(256) := null; 
--g_kf           VARCHAR2(6) DEFAULT '333368'; 
v_key          varchar2(256) := null; 

  function l_rukey(p_key varchar2)
  return varchar2 --deterministic
  is
 begin
  case
   when p_key <=0 then return p_key;
   when p_key is null then return null;
   else return p_key||mgr_utl.get_ru();
  end case;
 end l_rukey;

begin 
 --select l_rukey(null) into v_key from dual;
 v_key := l_rukey(15);
    dbms_output.put_line (v_key);
 end;