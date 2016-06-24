set path=C:\app\product\11.2.0\dbhome_1\bin;%path%;
c:
cd \
cd "C:\app\product\11.2.0\dbhome_1\bin"
net start OracleVssWriterORCL11203
net start OracleJobSchedulerORCL11203
net start OracleMTSRecoveryService
net start OracleOraDb11g_home1ClrAgent
net start OracleOraDb11g_home1TNSListenerLISTENER11203
net start OracleRemExecServiceV2
net start OracleServiceORCL11203
sqlplus / as sysdba
