rem "C:\Progra~2\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
rem sqlplus HR/Zvagas44@ORA11EE
rem timeout /t 20 /nobreak
rem sqlplus system/Zvagas44@ORA12C/ as sysdba
rem sqlplus / as sysdba
rem timeout /t 5 /nobreak
set path=C:\app\product\12.1.0\dbhome_1\BIN;%path%;
c:
cd \
cd "C:\app\product\12.1.0\dbhome_1\BIN"
net start OracleOraDB12Home1TNSListener
net start OracleServiceORA12C
sqlplus / as sysdba
