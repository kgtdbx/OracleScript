--select * from global_name

/*
Names for Database Links 
Typically, a database link has the same name as the global database name of the remote database it references. For example, if the global database name of a database is SALES.US.ORACLE.COM, then the database link is also called 
SALES.US.ORACLE.COM. 
When you set the initialization parameter GLOBAL_NAMES to TRUE, Oracle ensures that the name of the database link is the same as the global database name of the remote database. For example, if the global database name for HQ is 
HQ.ACME.COM, and GLOBAL_NAMES is TRUE, then the link name must be called HQ.ACME.COM. Note that Oracle checks the domain part of the global database name as stored in the data dictionary, not the DB_DOMAIN setting in the init.ora file (see Oracle8i Distributed Database Systems). 
If you set the initialization parameter GLOBAL_NAMES to FALSE, you are not required to use global naming. You can then name the database link whatever you want. For example, you can name a database link to HQ.ACME.COM as FOO. 
Note: Oracle Corporation recommends that you use global 
naming because many useful features, including Oracle Advanced Replication, require global naming be enforced. 
*/

create public database link <LinkName>
connect to <UserName>
identified by <pwd>
using '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = <ip_address>)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = <SID>)
    )
  )'


