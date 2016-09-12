-----------------------------
/*
CREATE USER sidney 
    IDENTIFIED BY out_standing1 
    DEFAULT TABLESPACE example 
    QUOTA 10M ON example 
    TEMPORARY TABLESPACE temp
    QUOTA 5M ON system 
    PROFILE app_user 
    PASSWORD EXPIRE;

The user sidney has the following characteristics:
The password out_standing1
Default tablespace example, with a quota of 10 megabytes
Temporary tablespace temp
Access to the tablespace SYSTEM, with a quota of 5 megabytes
Limits on database resources defined by the profile app_user (which was created in "Creating a Profile: Example")
An expired password, which must be changed before sidney can log in to the database
*/

/*
Examples

Creating a Profile: Example 
The following statement creates the profile new_profile:

CREATE PROFILE new_profile
  LIMIT PASSWORD_REUSE_MAX 10
        PASSWORD_REUSE_TIME 30;
		
Setting Profile Resource Limits: Example 
The following statement creates the profile app_user:

CREATE PROFILE app_user LIMIT 
   SESSIONS_PER_USER          UNLIMITED 
   CPU_PER_SESSION            UNLIMITED 
   CPU_PER_CALL               3000 
   CONNECT_TIME               45 
   LOGICAL_READS_PER_SESSION  DEFAULT 
   LOGICAL_READS_PER_CALL     1000 
   PRIVATE_SGA                15K
   COMPOSITE_LIMIT            5000000; 

If you assign the app_user profile to a user, the user is subject to the following limits in subsequent sessions:
The user can have any number of concurrent sessions.
In a single session, the user can consume an unlimited amount of CPU time.
A single call made by the user cannot consume more than 30 seconds of CPU time.
A single session cannot last for more than 45 minutes.
In a single session, the number of data blocks read from memory and disk is subject to the limit specified in the DEFAULT profile.
A single call made by the user cannot read more than 1000 data blocks from memory and disk.
A single session cannot allocate more than 15 kilobytes of memory in the SGA.
In a single session, the total resource cost cannot exceed 5 million service units. 
The formula for calculating the total resource cost is specified by the ALTER RESOURCE COST statement.
Since the app_user profile omits a limit for IDLE_TIME and for password limits, 
the user is subject to the limits on these resources specified in the DEFAULT profile.

Setting Profile Password Limits: Example 
The following statement creates the app_user2 profile with password limits values set:

CREATE PROFILE app_user2 LIMIT
   FAILED_LOGIN_ATTEMPTS 5
   PASSWORD_LIFE_TIME 60
   PASSWORD_REUSE_TIME 60
   PASSWORD_REUSE_MAX 5
   PASSWORD_VERIFY_FUNCTION verify_function
   PASSWORD_LOCK_TIME 1/24
   PASSWORD_GRACE_TIME 10;

This example uses the default Oracle Database password verification function, verify_function. 
Please refer to Oracle Database Security Guide for information on using this verification function provided or designing your own verification function.
*/

/*
Follow the below steps for creating a user in Oracle.
--Connect as System user
CONNECT <USER-NAME>/<PASSWORD>@<DATABASE NAME>;

--Create user query
CREATE USER <USER NAME> IDENTIFIED BY <PASSWORD>;

--Provide roles
GRANT CONNECT,RESOURCE,DBA TO <USER NAME>;

--Provide privileges
GRANT CREATE SESSION GRANT ANY PRIVILEGE TO <USER NAME>;
GRANT UNLIMITED TABLESPACE TO <USER NAME>;

--Provide access to tables.
GRANT SELECT,UPDATE,INSERT ON <TABLE NAME> TO <USER NAME>;
*/

/*

CONNECT <<username>>/<<password>>@<<DatabaseName>>; -- connect db with username and password, ignore if you already connected to database.
CREATE USER <<username>> IDENTIFIED BY <<password>>; -- create user with password
GRANT CONNECT,RESOURCE,DBA TO <<username>>; -- grant DBA,Connect and Resource permission to this user(not sure this is necessary if you give admin option)
GRANT CREATE SESSION TO <<username>> WITH ADMIN OPTION; --Give admin option to user
GRANT UNLIMITED TABLESPACE TO <<username>>; -- give unlimited tablespace grant

EDIT: If you face a problem about oracle ora-28001 the password has expired also this can be useful run

select * from dba_profiles;-- check PASSWORD_LIFE_TIME 
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED; -- SET IT TO UNLIMITED
*/


CREATE USER BI
    IDENTIFIED BY "Zvagas77"
    DEFAULT TABLESPACE BI_DATA
    QUOTA 100M ON EXAMPLE
    QUOTA 500M ON BI_DATA
    TEMPORARY TABLESPACE TEMP
    PROFILE DWH_USER;
	--ACCOUNT UNLOCK ;
GRANT CONNECT, RESOURCE TO BI;
GRANT CREATE SESSION TO BI;
GRANT UNLIMITED TABLESPACE TO BI;

GRANT SELECT, UPDATE, INSERT, ALTER ON TABLE_TEST TO BI;
GRANT ALL PRIVILEGES ON TABLE_TEST TO BI;

GRANT CREATE TABLE TO BI;
GRANT CREATE PROCEDURE TO BI;
GRANT CREATE TRIGGER TO BI;
GRANT CREATE VIEW TO BI;
GRANT CREATE SEQUENCE TO BI;
GRANT CREATE ANY INDEX TO BI;
GRANT ALTER ANY TABLE TO BI;
GRANT ALTER ANY PROCEDURE TO BI;
GRANT ALTER ANY TRIGGER TO BI;
GRANT ALTER PROFILE TO BI;
GRANT DELETE ANY TABLE TO BI;
GRANT DROP ANY TABLE TO BI;
GRANT DROP ANY PROCEDURE TO BI;
GRANT DROP ANY TRIGGER TO BI;
GRANT DROP ANY VIEW TO BI;
GRANT DROP PROFILE TO BI;
GRANT DROP ANY INDEX TO BI;
GRANT INSERT ANY TABLE TO BI;
GRANT LOCK ANY TABLE TO BI;
GRANT EXECUTE ANY PROCEDURE TO BI;


REVOKE SELECT ON SYSTEM.EMP FROM BI;

GRANT DBA TO BI;
