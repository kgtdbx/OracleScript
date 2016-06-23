--user$	список пользователей	
select * from user$;	--вывести всех пользователей
select * from dba_users;

--v$parameter	информация о параметрах БД	
select name
, value
, display_value
, isses_modifiable
, issys_modifiable
from v$parameter
where name like 'sga%';	--имя параметра, его значение, отображаемое значение и указание возможности/невозможности модификации значения для сессии и системы

--dba_data_files	информация обо всех файлах БД	
select * from dba_data_files;	--выводит список всех файлов БД и информацию о них
----
select file_id
, file_name
, tablespace_name
, bytes/1024/1024 as mbytes
, status
from dba_data_files;	--выводит названия всех data-файлов, связаных с ними tablespace'ов, размеров и статусов
-----
select * from v$tablespace
####################################
ALTER SYSTEM SET DB_CREATE_FILE_DEST = '$ORACLE_HOME/rdbms/dbs';
--or
ALTER SYSTEM SET DB_CREATE_FILE_DEST = 'c:/app/oradata';
----
CREATE TABLESPACE BI_DATA;
-----------------default c:\app\product\11.2.0\dbhome_1\database\-----------------------
CREATE TABLESPACE IRDS_DATA_DEV 
   DATAFILE 'IRDS_DATA_DEV.dbf' SIZE 500M 
   ONLINE;    
CREATE TABLESPACE IRDS_INDEX_DEV 
   DATAFILE 'IRDS_INDEX_DEV.dbf' SIZE 500M 
   ONLINE; 
--------------------------------------- 
CREATE USER IRDS_PDM_DEV
    IDENTIFIED BY "IRDS_PDM_DEV"
    DEFAULT TABLESPACE IRDS_DATA_DEV
    QUOTA 100M ON EXAMPLE
    TEMPORARY TABLESPACE TEMP;
    --PROFILE DWH_USER;
	--ACCOUNT UNLOCK;
GRANT CONNECT, RESOURCE TO IRDS_PDM_DEV;
GRANT CREATE SESSION TO IRDS_PDM_DEV;
--GRANT UNLIMITED TABLESPACE TO IRDS_PDM_DEV;

GRANT CREATE TABLE TO IRDS_PDM_DEV;
GRANT CREATE PROCEDURE TO IRDS_PDM_DEV;
GRANT CREATE TRIGGER TO IRDS_PDM_DEV;
GRANT CREATE VIEW TO IRDS_PDM_DEV;
GRANT CREATE SEQUENCE TO IRDS_PDM_DEV;
GRANT CREATE ANY INDEX TO IRDS_PDM_DEV;
GRANT ALTER ANY TABLE TO IRDS_PDM_DEV;
GRANT ALTER ANY PROCEDURE TO IRDS_PDM_DEV;
GRANT ALTER ANY TRIGGER TO IRDS_PDM_DEV;
GRANT ALTER PROFILE TO IRDS_PDM_DEV;
GRANT DELETE ANY TABLE TO IRDS_PDM_DEV;
GRANT DROP ANY TABLE TO IRDS_PDM_DEV;
GRANT DROP ANY PROCEDURE TO IRDS_PDM_DEV;
GRANT DROP ANY TRIGGER TO IRDS_PDM_DEV;
GRANT DROP ANY VIEW TO IRDS_PDM_DEV;
GRANT DROP PROFILE TO IRDS_PDM_DEV;
GRANT DROP ANY INDEX TO IRDS_PDM_DEV;
GRANT INSERT ANY TABLE TO IRDS_PDM_DEV;
GRANT LOCK ANY TABLE TO IRDS_PDM_DEV;
GRANT EXECUTE ANY PROCEDURE TO IRDS_PDM_DEV; 

----------------------------------------------------

 
   

   