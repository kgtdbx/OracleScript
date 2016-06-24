set path=C:\app\product\12.1.0\dbhome_1\BIN;%path%;
c:
cd \
cd "C:\app\product\12.1.0\dbhome_1\BIN"
sqlplus / as sysdba
shutdown immediate
net stop OracleOraDB12Home1TNSListener
net stop OracleServiceORA12C

