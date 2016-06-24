set path=C:\app\11204\product\11.2.0\dbhome_2\bin;%path%;
c:
cd \
cd "C:\app\11204\product\11.2.0\dbhome_2\bin"
sqlplus / as sysdba
shutdown immediate
net stop OracleVssWriterORA11204
net stop OracleJobSchedulerORA11204
net stop OracleMTSRecoveryService
net stop OracleOraDb11g_home2ClrAgent
net stop OracleOraDb11g_home2TNSListenerLISTENER11204
net stop OracleRemExecServiceV2
net stop OracleServiceORA11204

