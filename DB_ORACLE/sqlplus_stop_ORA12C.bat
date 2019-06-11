set path=C:\app\product\12.1.0\dbhome_1\BIN;%path%;
c:
cd \
cd "C:\app\product\12.1.0\dbhome_1\BIN"
rem sqlplus / as sysdba 
rem shutdown immediate

rem -------------Starting and Shutting Down a Database Using Services--------------
rem You can start or shut down Oracle Database by starting or stopping service OracleServiceSID in the Control Panel. 
rem Starting OracleServiceSID is equivalent to using the STARTUP command or manually entering:
rem C:\> oradim -STARTUP -SID SID [-STARTTYPE srvc | inst | srvc,inst] [-PFILE filename | -SPFILE]
rem Stopping OracleServiceSID is equivalent to using the SHUTDOWN command or manually entering:
rem C:\> oradim -SHUTDOWN -SID SID [-SHUTTYPE srvc | inst | srvc,inst] [-SHUTMODE normal | immediate | abort]
rem oradim -SHUTDOWN -SID ORA12C

net stop OracleOraDB12Home1TNSListener
net stop OracleServiceORA12C
timeout /t 15 /nobreak

