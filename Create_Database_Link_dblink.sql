Create Database Link

Connected User Link	
CREATE [SHARED] [PUBLIC] DATABASE LINK <link_name>
CONNECT TO CURRENT_USER
USING '<service_name>';
-- create tnsnames entry for conn_link
conn_link =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = perrito2)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orabase)
    )
  )


conn uwclass/uwclass

CREATE DATABASE LINK conn_user
USING 'conn_link';

desc user_db_links

set linesize 121
col db_link format a20
col username format a20
col password format a20
col host format a20

SELECT * FROM user_db_links;

SELECT * FROM all_db_links;

SELECT table_name, tablespace_name FROM user_tables@conn_user;

Current User Link	
CREATE [PUBLIC] DATABASE LINK <link_name>
CONNECT TO CURRENT_USER
USING '<service_name>';
CREATE DATABASE LINK curr_user
CONNECT TO CURRENT_USER
USING 'conn_link';

desc user_db_links

set linesize 121
col db_link format a20
col username format a20
col password format a20
col host format a20

SELECT * FROM user_db_links;

SELECT * FROM all_db_links;

SELECT table_name, tablespace_name FROM user_tables@curr_user;

-- The user who issues this statement must be a global user 
-- registered with the LDAP directory service.

Fixed User Link	
CREATE [PUBLIC] DATABASE LINK <link_name>
CONNECT TO <user_name>
IDENTIFIED BY <password>
USING '<service_name>';
CREATE DATABASE LINK fixed_user
CONNECT TO hr IDENTIFIED BY hr
USING 'conn_link';

SELECT * FROM all_db_links;

desc gv$session_connect_info

set linesize 121
set pagesize 60
col authentication_type format a10
col osuser format a25
col network_service_banner format a50 word wrap

SELECT DISTINCT sid
FROM gv$mystat;

SELECT authentication_type, osuser, network_service_banner
FROM gv$session_connect_info
WHERE sid = 143;

SELECT table_name, tablespace_name FROM user_tables@fixed_user;

Shared Link	
CREATE SHARED DATABASE LINK <link_name>
AUTHENTICATED BY <schema_name> IDENTIFIED BY <password>
USING '<service_name>';
conn uwclass/uwclass

CREATE SHARED DATABASE LINK shared
CONNECT TO scott IDENTIFIED BY tiger
AUTHENTICATED BY uwclass IDENTIFIED BY uwclass
USING 'conn_link';

SELECT * FROM user_db_links;

SELECT table_name, tablespace_name FROM user_tables@shared;

Public Link	
CREATE PUBLIC DATABASE LINK <link_name>
USING '<service_name>';
conn / as sysdba

CREATE PUBLIC DATABASE LINK publink
USING 'conn_link';

SELECT * FROM dba_db_links;

conn scott/tiger

SELECT table_name, tablespace_name FROM user_tables@publink;

conn sh/sh

SELECT table_name, tablespace_name FROM user_tables@publink;

conn uwclass/uwclass

SELECT table_name, tablespace_name FROM user_tables@publink;
 
Close Database Link
Close Link	
ALTER SESSION CLOSE DATABASE LINK <link_name>;
ALTER SESSION CLOSE DATABASE LINK curr_user;
 
Drop Database Link
Drop Standard Link	DROP DATABASE LINK <link_name>;
DROP DATABASE LINK test_link;
Drop Public Link	DROP PUBLIC DATABASE LINK <link_name>;
DROP PUBLIC DATABASE LINK test_link;
 
Database Link Security

Fixed User Caution In earlier versions	set linesize 121
col db_link format a45
col username format a15
col password format a15
col host format a15

SELECT db_link, username, password, host, created
FROM user_db_links;

conn / as sysdba

desc link$

col name format a20
col authpwdx format a40

SELECT name, userid, authpwdx
FROM link$;
 
Querying Across Database Links
Hint	By default Oracle selects the site, local or remote, on which to perform the operation. A specific site can be selected by the developer using the DRIVING_SITE hint.
Test Link	
BEGIN
  ALTER SESSION CLOSE DATABASE LINK remove_db;

  SELECT table_name
  INTO i
  FROM all_tables@remote_db
  WHERE rownum = 1;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20999, 'No Connection');
END;

--**************************************
-- Create database link 
CREATE DATABASE LINK BASA 
CONNECT TO test IDENTIFIED BY "test123"
USING --'BASA32'
'(DESCRIPTION= 
      (ADDRESS= (PROTOCOL=TCP)(HOST=10.0.1.32)(PORT=1521)) 
      (CONNECT_DATA= (SERVER = DEDICATED)(SERVICE_NAME=BASA))
  )';
--**************************************
-- Create database link 
CREATE DATABASE LINK ORAW2K8 
CONNECT TO ITC IDENTIFIED BY "ITC"
USING
'(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.62.254)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORAW2K8)
    )
  )';  