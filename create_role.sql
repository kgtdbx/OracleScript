CREATE ROLE

Create a user role.

Syntax:

Create role without a password:
   CREATE ROLE role NOT IDENTIFIED

Create role with a password:
   CREATE ROLE role IDENTIFIED BY password

Create an application role:
   CREATE ROLE role IDENTIFIED USING [schema.]package

Create role authorised by the OS:
   ALTER ROLE role IDENTIFIED EXTERNALLY

Create role authorised by Directory Service:
   ALTER ROLE role IDENTIFIED GLOBALLY

Example
--Create the role
CREATE ROLE MY_ORACLE_ROLE

--Assign all object rights from the current user schema (user_objects)

spool GrantRights.sql

SELECT
decode(
object_type,
'TABLE','GRANT SELECT, INSERT, UPDATE, DELETE , REFERENCES ON'||&OWNER||'.',
'VIEW','GRANT SELECT ON '||&OWNER||'.',
'SEQUENCE','GRANT SELECT ON '||&OWNER||'.',
'PROCEDURE','GRANT EXECUTE ON '||&OWNER||'.',
'PACKAGE','GRANT EXECUTE ON '||&OWNER||'.',
'FUNCTION','GRANT EXECUTE ON'||&OWNER||'.' )||object_name||' TO MY_ORACLE_ROLE ;' 
FROM user_objects 
WHERE
OBJECT_TYPE IN ( 'TABLE', 'VIEW', 'SEQUENCE', 'PROCEDURE', 'PACKAGE','FUNCTION'
)
ORDER BY OBJECT_TYPE

spool off

@GrantRights.sql


--###########################################################

--загрантовать bars от sys-а для SBON-в

GRANT CREATE ROLE TO bars;
GRANT EXECUTE ON sbon.sto_sbon_api  TO bars WITH GRANT OPTION;
GRANT SELECT ON sbon.v_sb_dov_org TO bars WITH GRANT OPTION;
GRANT SELECT ON sbon.v_sb_post_plat TO bars WITH GRANT OPTION;

GRANT SELECT ANY TABLE TO bars WITH ADMIN OPTION;  

--от bars-а
procedure grant_sto_sbon
     is
    begin
     init();
      
      begin
              execute immediate 'CREATE ROLE SBON_ROLE';
            exception
              when others then
                --"ORA-01921: role name 'x' conflicts with another user or role name"
                if sqlcode = -01921 then 
                  null;
                else
                  raise;
                end if;
      end;
      
      execute immediate 'GRANT EXECUTE ON SBON.STO_SBON_API TO SBON_ROLE';
      execute immediate 'GRANT SELECT ON SBON.V_SB_DOV_ORG TO SBON_ROLE';
      execute immediate 'GRANT SELECT ON SBON.V_SB_POST_PLAT TO SBON_ROLE';
      execute immediate 'GRANT SBON_ROLE TO SBON'||g_ru;
      
    end grant_sto_sbon;

