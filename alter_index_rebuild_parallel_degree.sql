Looking for a rule of thumb, yeah I know ROT. But we are planning for a generic procedure that will 
load to the tables of a data warehouse. We will alter the procedure for specific tables if tuning 
discovers the need. Our plan is to follow advice on the forum to:

1. disable constraints
2. set indexes unusable
3. load data
4. enable constraints
5. rebuild indexes parallel nologging
6. backup
7. set indexes to logging

Our question is ,should we set the indexes to noparallel after the load? Maybe you can't answer 
this without more info, but maybe you can give examples why you would or would not leave an index 
in parallel?

Thanks Tom, for this extremely valuable resource. 
Followup   March 28, 2006 - 8:01 pm UTC

I would set them back to noparallel - I like to use parallel hints.  But it depends on if you want 
them parallel enabled by default. '
--******************************************
SQL> alter index test_idx rebuild nologging parallel (degree 16 );

Index altered.

and 

SQL> alter index test_idx logging parallel 1; 

Index altered.
--******************************************

Tom, 

In order to tune the rebulding of an index I have experimented with the "REBUILD PARALLEL 
6" option while rebuilding an index on a large table; e.g.

"ALTER INDEX index_name REBUILD PARALLEL 6"

Are there any side affects to using the parallel option on the index structure (is it the 
same/as accurate - as if the parallel option was ommitted?) apart from increasing speed 
the processing speed?

Also the server which the database runs on has 6 CPU's.  Should I be using "REBUILD 
PARALLEL 6" or "REBUILD PARALLEL 3" in the clause as I read Oracle server uses an equal 
number of CPU's (or is it server processes?) to scan and build the new index.

Regards, 

Robin 
and we said...

I would "rebuild parallel 12" actually, with the NOLOGGING option if I could.

We'll work better where you have more processes then CPUs.  Especially with indexing.  
indexing is IO intensive.  We'll have lots of times where we are waiting on IO and not 
using the CPU.  Having more processes then CPUs will help utilize them fully.  This 
assumes of course you are doing this off hours.


The index will fundementally be the same after the parallel index rebuild. 


The index parallel degree was changed after rebuilding it parallel.  Here is my test with 8.1.7.0.0

SQL> select table_name,index_name,degree from dba_indexes
  2  where index_name='I_PLC_CUSTID_UK';

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
DEGREE
----------------------------------------
PLC                            I_PLC_CUSTID_UK
1


SQL> alter index loa_data.I_PLC_CUSTID_UK rebuild online;

Index altered.

Elapsed: 00:01:25.03

SQL> select table_name,index_name,degree from dba_indexes
  2  where index_name='I_PLC_CUSTID_UK';

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
DEGREE
----------------------------------------
PLC                            I_PLC_CUSTID_UK
1

SQL> alter index loa_data.I_PLC_CUSTID_UK rebuild online parallel 4;

Index altered.

Elapsed: 00:00:56.04
SQL> select table_name,index_name,degree from dba_indexes
  2  where index_name='I_PLC_CUSTID_UK';

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
DEGREE
----------------------------------------
PLC                            I_PLC_CUSTID_UK
4

 
Followup   November 08, 2002 - 12:56 pm UTC

easy enough to set it back. alter index iname parallel 1 


--*****************************************************************
I just wonder why I cannot use nologging with subpartition. Would you explain why?

18:04:01 ops$rms@rmsdev>   alter index PP_IDX1 
18:04:01   2  rebuild subpartition SYS_SUBP4469 nologging
18:04:01   3  /
rebuild subpartition SYS_SUBP4469 nologging
                                  *
ERROR at line 2:
ORA-14189: this physical attribute may not be specified for an index subpartition 
Followup   June 10, 2004 - 8:16 am UTC

those clauses are not supported for subpartitions.  (there is an enhancement request to permit it 
filed)

you can:

alter index pp_idx1 nologging;
rebuild the subpartitions
alter index pp_idx1 logging;

to achieve the same. 