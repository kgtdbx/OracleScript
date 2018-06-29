Todays let‘s have look at the query which we use to resolve this issue ” How to Flush Single SQL Plan out of Shared Pool”. 

Find the address and the hash value

SQL> select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID='495fdyn7cd34r';

ADDRESS          HASH_VALUE
---------------- ----------
00000005ODJD9BC0 247122679

SQL> select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID='495fdyn7cd34r';
 
ADDRESS          HASH_VALUE
---------------- ----------
00000005ODJD9BC0 247122679


Execute the purge procedure
SQL> exec DBMS_SHARED_POOL.PURGE ('00000005ODJD9BC0,247122679','C');

PL/SQL procedure successfully completed.

SQL> exec DBMS_SHARED_POOL.PURGE ('00000005ODJD9BC0,247122679','C');
 
PL/SQL procedure successfully completed.
