set verify off
ACCEPT sysPassword CHAR PROMPT 'Enter new password for SYS: ' HIDE
ACCEPT systemPassword CHAR PROMPT 'Enter new password for SYSTEM: ' HIDE
host C:\app\product\12.1.0\dbhome_1\bin\orapwd.exe file=C:\app\product\12.1.0\dbhome_1\database\PWDORA12C.ora force=y format=12
@D:\Install\WORK\DB_ORACLE\CloneRmanRestore.sql
@D:\Install\WORK\DB_ORACLE\cloneDBCreation.sql
@D:\Install\WORK\DB_ORACLE\postScripts.sql
@D:\Install\WORK\DB_ORACLE\lockAccount.sql
@D:\Install\WORK\DB_ORACLE\postDBCreation.sql
