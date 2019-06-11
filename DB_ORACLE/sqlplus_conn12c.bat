rem Here is one way of doing it, with the help of an additional icon on your desktop. I guess you could move the script someone else if you wanted to only have a single icon on your desktop.
rem 1.Create a shortcut to your Powershell script on your desktop
rem 2.Right-click the shortcut and click Properties
rem 3.Click the Shortcut tab
rem 4.Click Advanced
rem 5.Select Run as Administrator
rem 
rem You can now run the script elevated by simple double-clicking the new shortcut on your desktop.


rem "C:\Progra~2\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
rem sqlplus HR/Zvagas44@ORA11EE
rem timeout /t 20 /nobreak
rem sqlplus system/Zvagas44@ORA12C as sysdba
rem sqlplus / as sysdba
rem timeout /t 5 /nobreak
set path=C:\app\product\12.1.0\dbhome_1\BIN;%path%;
c:
cd \
cd "C:\app\product\12.1.0\dbhome_1\BIN"
net start OracleOraDB12Home1TNSListener
net start OracleServiceORA12C

rem -----------------Starting and Shutting Down a Database Using Services-----------------
rem You can start or shut down Oracle Database by starting or stopping service OracleServiceSID in the Control Panel. 
rem Starting OracleServiceSID is equivalent to using the STARTUP command or manually entering:
rem C:\> oradim -STARTUP -SID SID [-STARTTYPE srvc | inst | srvc,inst] [-PFILE filename | -SPFILE]
rem Stopping OracleServiceSID is equivalent to using the SHUTDOWN command or manually entering:
rem C:\> oradim -SHUTDOWN -SID SID [-SHUTTYPE srvc | inst | srvc,inst] [-SHUTMODE normal | immediate | abort]

rem oradim -STARTUP -SID ORA12C


rem ----------------Oracle Administration Assistant for Windows---------------------------
rem To start or stop a database using Oracle Database services from Oracle Administration Assistant for Windows:
rem From the Start menu, select Programs, then select Oracle - HOME_NAME, then select Configuration and Migration Tools and then select Administration Assistant for Windows.
rem Right-click the SID.
rem where SID is a specific instance name, such as ORCL.
rem Choose Startup/Shutdown Options.
rem Choose the Oracle Instance tab.
rem Select Start up instance when service is started, Shut down instance when service is stopped, or both.


rem For connect sqlplus / as sysdba need to settings:remote_login_passwordfile= EXCLUSIVE and orapw
rem alter system set remote_login_passwordfile=EXCLUSIVE
rem when you set remote_login_passwordfile=none in the init.ora file, that means you ask your database to ignore the password file and let OS to uthenticate user.
rem alter system set remote_login_passwordfile=none scope=file  or alter system set remote_login_passwordfile=none scope=spfile
rem sqlplus / as sysdba
rem startup