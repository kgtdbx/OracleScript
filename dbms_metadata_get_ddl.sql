Dbms_Metadata Package : To Extract all DDL

There  are various method available to extract the DDL from the oracle database . We can extract the DDL either by  export/import utility , dbms_metadata package ,or by using others third party tools . The best ways to extract the DDL is by using the DBMS_METADATA pacakage if don't have any tools . Here we will discuss the various DDL extracting method to extract the DDL from the Oracle .

The DBMS_METADATA package provides a way to retrieve metadata from the database dictionary as XML or  DDL . We can retrive either a particular object type (such as a table, index, or procedure) or a heterogeneous collection of object types that form a logical unit (such as a database export or schema export) 

One of the very useful function i.e, GET_xxxx functions are used to extract the DDL .  The following GET_xxxx functions fetches the metadata for objects with a single call . They encapsulate calls to OPEN, SET_FILTER, and so on. The function we use depends on the characteristics of the object type and on whether we want XML or DDL.

1.) GET_DDL( )   :  This function is used to fetch named objects, especially schema objects (tables, views). They can also be used with nameless objects, such as resource_cost .

Snytax   :
DBMS_METADATA.GET_DDL (
object_type     IN VARCHAR2,
name            IN VARCHAR2,
schema          IN VARCHAR2 DEFAULT NULL,
version         IN VARCHAR2 DEFAULT 'COMPATIBLE',
model           IN VARCHAR2 DEFAULT 'ORACLE',
transform       IN VARCHAR2 DEFAULT 'DDL')
RETURN CLOB;

Example  : Here we will extract the DDL for the "employees"  table .

SQL> select dbms_metadata.get_ddl('TABLE', 'EMP')   from dual ;

DBMS_METADATA.GET_DDL('TABLE','EMP')
--------------------------------------------------------------------------------
   CREATE TABLE "ALEX"."EMP"
   (    "EMPNO" NUMBER(4,0),
        "ENAME" VARCHAR2(10),
        "JOB" VARCHAR2(9),
        "MGR" NUMBER(4,0),
        "HIREDATE" DATE,
        "SAL" NUMBER(7,2),
        "COMM" NUMBER(7,2),
        "DEPTNO" NUMBER(2,0),
         CONSTRAINT "EMP_DEPT_FK" FOREIGN KEY ("DEPTNO")
          REFERENCES "ALEX"."DEPT" ("DEPTNO") ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"

Similary , we also extract the DDL of others objects like tablespace,views,sequence and others .

If we want only the DDL  not the storage clause and constraints ,then we need to modify some transformation parameters as

SQL> begin
  2     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'STORAGE',false);
  3     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'TABLESPACE',false);
  4     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', false);
  5     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'REF_CONSTRAINTS', false);
  6     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'CONSTRAINTS', false);
  7  end;
  8  /
 PL/SQL procedure successfully completed.

Now on running the same above statements give the following results .

SQL> select dbms_metadata.get_ddl ('TABLE', 'EMP')  from dual ;
 DBMS_METADATA.GET_DDL('TABLE','EMP')
--------------------------------------------------------------------------------
   CREATE TABLE "ALEX"."EMP"
   (    "EMPNO" NUMBER(4,0),
        "ENAME" VARCHAR2(10),
        "JOB" VARCHAR2(9),
        "MGR" NUMBER(4,0),
        "HIREDATE" DATE,
        "SAL" NUMBER(7,2),
        "COMM" NUMBER(7,2),
        "DEPTNO" NUMBER(2,0)
   )

One of the nice things is that we don't need to modify all the transformation parameters again to go back to the default. They made it really easy to return to the default settings:

SQL> begin
  2     dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'DEFAULT');
  3  end;
  4  /
 PL/SQL procedure successfully completed.

2.) GET_DEPENDENT_DDL( ) : This function is used to fetch dependent objects (audits, object grants).
 Syntax : 
DBMS_METADATA.GET_DEPENDENT_DDL (
object_type         IN VARCHAR2,
base_object_name    IN VARCHAR2,
base_object_schema  IN VARCHAR2 DEFAULT NULL,
version             IN VARCHAR2 DEFAULT 'COMPATIBLE',
model               IN VARCHAR2 DEFAULT 'ORACLE',
transform           IN VARCHAR2 DEFAULT 'DDL',
object_count        IN NUMBER   DEFAULT 10000)
RETURN CLOB ;

Example :   In this example, we will extract the reference constraints which is dependent on another tables .

SQL > select dbms_metadata.get_dependent_ddl( 'REF_CONSTRAINT', table_name) DDL
              FROM USER_TABLES WHERE table_name = 'EMPLOYEES' ;
ALTER  TABLE  "HR"."EMPLOYEES" ADD CONSTRAINT  "EMP_DEPT_FK"  FOREIGN KEY ("DEPARTMENT_ID")    REFERENCES  "HR"."DEPARTMENTS"  ("DEPARTMENT_ID") ENABLE

ALTER  TABLE "HR"."EMPLOYEES"  ADD  CONSTRAINT "EMP_JOB_FK"  FOREIGN KEY ("JOB_ID") REFERENCES  "HR"."JOBS"  ("JOB_ID") ENABLE

ALTER TABLE "HR"."EMPLOYEES" ADD CONSTRAINT "EMP_MANAGER_FK" FOREIGN KEY ("MANAGER_ID")   REFERENCES "HR"."EMPLOYEES" ("EMPLOYEE_ID") ENABLE

3.) GET_GRANTED_DDL( ) : This function  is used to fetch granted objects (system grants, role grants ) to the users of the database .

Syntax : 


DBMS_METADATA.GET_GRANTED_DDL (
object_type     IN VARCHAR2,
grantee         IN VARCHAR2 DEFAULT NULL,
version         IN VARCHAR2 DEFAULT 'COMPATIBLE',
model           IN VARCHAR2 DEFAULT 'ORACLE',
transform       IN VARCHAR2 DEFAULT 'DDL',
object_count    IN NUMBER   DEFAULT 10000)
RETURN CLOB;

Example :  Here we will extract the "system grant" assigned to the user "SYSTEM "

SQL> select dbms_metadata.get_granted_ddl('SYSTEM_GRANT','SYSTEM') from dual;

DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','SYSTEM')
--------------------------------------------------------------------------------
  GRANT GLOBAL QUERY REWRITE TO "SYSTEM"
  GRANT CREATE MATERIALIZED VIEW TO "SYSTEM"
  GRANT SELECT ANY TABLE TO "SYSTEM"
  GRANT CREATE TABLE TO "SYSTEM"
  GRANT UNLIMITED TABLESPACE TO "SYSTEM" WITH ADMIN OPTION

To extract all the grants to all the user we can use the below statements  .

SQL> SELECT DBMS_METADATA.GET_GRANTED_DDL(‘ROLE_GRANT’, USERNAME) || ‘/’ DDL FROM DBA_USERS where exists (select ‘x’ from dba_role_privs drp where drp.grantee = dba_users.username)
UNION ALL
SELECT DBMS_METADATA.GET_GRANTED_DDL(‘SYSTEM_GRANT’, USERNAME) || ‘/’ DDL FROM DBA_USERS where exists (select ‘x’ from dba_role_privs drp where drp.grantee = dba_users.username)
UNION ALL
SELECT DBMS_METADATA.GET_GRANTED_DDL(‘OBJECT_GRANT’, USERNAME) || ‘/’ DDL FROM  DBA_USERS where exists (select ‘x’ from dba_tab_privs dtp where  dtp.grantee = dba_users.username);


Enjoy   :-) 