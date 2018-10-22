 SET SERVEROUTPUT ON
 DECLARE 
 l_owner varchar2(30 char);
 l_table_name varchar2(30 char);
   
     FUNCTION is_table_partitioned (ip_owner varchar2, ip_table_name varchar2)
     return boolean
      IS
         bexist boolean := false;
         nexist number(1);
        begin
            l_owner :=upper(dbms_assert.qualified_sql_name(ip_owner));
            l_table_name :=upper(dbms_assert.qualified_sql_name(ip_table_name));
            
            begin
              select 1
              into nexist
              from all_tables at
              where 1=1
              and at.owner = l_owner
              and at.table_name = l_table_name
              and at.partitioned = 'YES';
              bexist := true;
            exception
              when no_data_found then
                bexist := false;
            end;
            return bexist;
          end;
  
BEGIN
if is_table_partitioned('EXTSTG', '||RB_TDC_ZVD40_ARC') then DBMS_OUTPUT.put_line ('TRUE');
ELSE DBMS_OUTPUT.put_line ('FALSE');
END IF;
END;