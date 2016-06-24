mkdir C:\app
mkdir C:\app\admin\ORA12C\adump
mkdir C:\app\admin\ORA12C\dpdump
mkdir C:\app\admin\ORA12C\pfile
mkdir C:\app\audit
mkdir C:\app\cfgtoollogs\dbca\ORA12C
mkdir C:\app\oradata\ORA12C
mkdir C:\app\product\12.1.0\dbhome_1\database
set PERL5LIB=%ORACLE_HOME%/rdbms/admin;%PERL5LIB%
set ORACLE_SID=ORA12C
set PATH=%ORACLE_HOME%\bin;%ORACLE_HOME%\perl\bin;%PATH%
C:\app\product\12.1.0\dbhome_1\bin\oradim.exe -new -sid ORA12C -startmode manual -spfile 
C:\app\product\12.1.0\dbhome_1\bin\oradim.exe -edit -sid ORA12C -startmode auto -srvcstart system 
C:\app\product\12.1.0\dbhome_1\bin\sqlplus /nolog @D:\Install\WORK\DB_ORACLE\ORA12C.sql
