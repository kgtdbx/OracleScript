set path=C:\app\11204\product\11.2.0\dbhome_2\bin;%path%;
c:
cd \
cd "C:\app\11204\product\11.2.0\dbhome_2\bin"
net start OracleVssWriterORA11204
net start OracleJobSchedulerORA11204
net start OracleMTSRecoveryService
net start OracleOraDb11g_home2ClrAgent
net start OracleOraDb11g_home2TNSListenerLISTENER11204
net start OracleRemExecServiceV2
net start OracleServiceORA11204
sqlplus / as sysdba