rem set path=C:\app\product\11.2.0\dbhome_1\bin;%path%;
rem c:
rem cd \
rem cd "C:\app\product\11.2.0\dbhome_1\bin"

rem sqlplus system/Oracle12G2020@ORCL11203 as sysdba
rem timeout /t 10 /nobreak
rem sqlplus / as sysdba rem shu immediate

rem net start OracleOraDb11g_home1TNSListenerLISTENER11203
rem net start OracleServiceORCL11203
net start OracleOraDb11g_home2TNSListenerLISTENER11204
net start OracleServiceORA11204

timeout /t 10 /nobreak
set path=C:\app\11204\product\11.2.0\dbhome_2\bin;%path%;
c:
cd \
cd "C:\app\11204\product\11.2.0\dbhome_2\bin"
sqlplus / as sysdba

