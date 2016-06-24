connect target sys/&1;
 
CATALOG START WITH   'C:\app\product\12.1.0\dbhome_1\assistants\dbca\templates\\Seed_Database.dfb'  NOPROMPT  ;

RUN {  

set newname for datafile 3 to  'C:\app\oradata\ORA12C\SYSAUX01.DBF' ; 

set newname for datafile 1 to  'C:\app\oradata\ORA12C\SYSTEM01.DBF' ; 

set newname for datafile 6 to  'C:\app\oradata\ORA12C\USERS01.DBF' ; 

set newname for datafile 5 to  'C:\app\oradata\ORA12C\UNDOTBS01.DBF' ; 

restore datafile 3; 

restore datafile 1; 

restore datafile 6; 

restore datafile 5; }
