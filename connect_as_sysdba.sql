
Question:  I am attempting to add an entry to my orapwd file and I get this error:
SQL> grant sysdba to xxx; grant sysdba to xxx * 

ERROR at line 1: 
ORA-01994: GRANT failed: password file missing or disabled 
What does the ORA-01994 error mean?
Answer:  The ORA-01994 error happens when you forget to use the orapwd command, and it critical to note that the name of the file must be orapwsid, and you must supply the full path name when using the orapwd command.  
The docs note this on the ORA-01994 error:
ORA-01994: GRANT failed: password file missing or disabled

Cause: The operation failed either because the INIT.ORA parameter REMOTE_LOGIN_PASSWORDFILE was set to NONE or else because the password file was missing.

Action: Create the password file using the orapwd tool and set the INIT.ORA parameter REMOTE_LOGIN_PASSWORDFILE to EXCLUSIVE.
We use the orapwd utility to grant SYSDBA and SYSOPER privileges to other database users.  
The orapwd utility helps granting SYSDBA and SYSOPER  privileges to other administrative users like the OS oracle user.  Creating a password file via orapwd enables remote users to connect with administrative privileges through SQL*Net . 
 
The SYSOPER privilege allows instance startup, shutdown, mount, and dismount.  It allows the DBA to perform general database maintenance without viewing user data.  The SYSDBA privilege is the same as connect internal was in prior versions.  It provides the ability to do everything, unrestricted. 
 
If orapwd has not yet been executed, attempting to grant SYSDBA or SYSOPER privileges will result in the following error:
 
SQL> grant sysdba to scott;  

ORA-01994: GRANT failed: cannot add users to public password file
 
Rampant author Dave Moore gives this excellent example of fixing the ORA-01994 error and shows the steps can be performed to grant other users SYSDBA privileges: 
STEP 1.   Create the password file.  
This is done by executing the following command: 

$ orapwd file=filename  password=password entries=max_users
 
The orapwd filename is the name of the file that will hold the password information.  The orapwd file location will default to the current directory unless the full path is specified.  For security, the contents of the orapwd file are encrypted and are unreadable. The password required is the one for the SYS user of the database. 
 
The max_users is the number of database users that can be granted SYSDBA or SYSOPER.  This parameter should be set to a higher value than the number of anticipated users to prevent having to delete and recreate the password file.  
 
STEP 2.   Edit the init.ora parameter remote_login_passwordfile.  
This parameter must be set to either SHARED or EXCLUSIVE.  When set to SHARED, the password file can be used by multiple databases, yet only the SYS user is recognized.  When set to EXCLUSIVE, the orapwd file can be used by only one database, yet multiple users can exist in the file.  

SQL> show parameter password
 
NAME                                 TYPE        VALUE
------------------------------------ ----------- ----------remote_login_passwordfile            string      EXCLUSIVE
alter system set remote_login_passwordfile=exclusive scope=both;
 
STEP 3.   Grant SYSDBA or SYSOPER to users.  
--When SYSDBA or SYSOPER privileges are granted to a user, that user's name and privilege information are added to the password file. 

SQL> grant sysdba to scott;
 
Grant succeeded.
 
STEP 4.   Confirm that the user is listed in the orapwd password file. 
 
SQL> select * from v$pwfile_users;
 
USERNAME                       SYSDBA SYSOPER
------------------------------ ------ -------
SYS                            TRUE   TRUE
SCOTT                          TRUE   FALSE

STEP 5.  Test the connectivity
Now the user SCOTT can connect as SYSDBA.  Administrative users can be connected and authenticated to a local or remote database by using the SQL*Plus connect command.  They must connect using their username and password, and with the AS SYSDBA or AS SYSOPER clause:
 
SQL> connect scott/tiger as sysdba;

Connected.

---##########################################################3

rem For connect sqlplus / as sysdba need to settings:remote_login_passwordfile= EXCLUSIVE and orapw
rem alter system set remote_login_passwordfile=EXCLUSIVE
rem when you set emote_login_passwordfile=none in the init.ora file, that means you ask your database to ignore the password file and let OS to authenticate user.
rem alter system set remote_login_passwordfile=none scope=file  or alter system set remote_login_passwordfile=none scope=file
sqlplus / as sysdba


when you set emote_login_passwordfile=none in the init.ora file, that means you ask your database to ignore the password file and let OS to authenticate user.

so you have to set this in the SQLNET.ORA file in windows under the same folder as LISTENER.ORA file .

SQLNET.AUTHENTICATION_SERVICES= (NTS)

then you should be able to start the Database. 