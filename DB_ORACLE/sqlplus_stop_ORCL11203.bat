set path=C:\app\product\11.2.0\dbhome_1\bin;%path%;
c:
cd \
cd "C:\app\product\11.2.0\dbhome_1\bin"
sqlplus / as sysdba
shutdown immediate
net stop OracleVssWriterORCL11203
net stop OracleJobSchedulerORCL11203
net stop OracleMTSRecoveryService
net stop OracleOraDb11g_home1ClrAgent
net stop OracleOraDb11g_home1TNSListenerLISTENER11203
net stop OracleRemExecServiceV2
net stop OracleServiceORCL11203

