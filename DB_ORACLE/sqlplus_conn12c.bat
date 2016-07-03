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
rem For connect sqlplus / as sysdba need to settings:remote_login_passwordfile= EXCLUSIVE and orapw
sqlplus / as sysdba
