Altering Indexes

To alter an index, your schema must contain the index or you must have the ALTER ANY INDEX system privilege. With the ALTER INDEX statement, you can:

Rebuild or coalesce an existing index

Deallocate unused space or allocate a new extent

Specify parallel execution (or not) and alter the degree of parallelism

Alter storage parameters or physical attributes

Specify LOGGING or NOLOGGING

Enable or disable key compression

Mark the index unusable

Make the index invisible

Rename the index

Start or stop the monitoring of index usage

You cannot alter index column structure.

More detailed discussions of some of these operations are contained in the following sections:

Altering Storage Characteristics of an Index

Rebuilding an Existing Index

Making an Index Unusable

Making an Index Invisible

Monitoring Index Usage

See Also:
Oracle Database SQL Language Reference for details on the ALTER INDEX statement

Altering Storage Characteristics of an Index

Alter the storage parameters of any index, including those created by the database to enforce primary and unique key integrity constraints, using the ALTER INDEX statement. For example, the following statement alters the emp_ename index:

ALTER INDEX emp_ename
     STORAGE (PCTINCREASE 50);
The parameters INITIAL and MINEXTENTS cannot be altered. All new settings for the other storage parameters affect only extents subsequently allocated for the index.

For indexes that implement integrity constraints, you can adjust storage parameters by issuing an ALTER TABLE statement that includes the USING INDEX subclause of the ENABLE clause. For example, the following statement changes the storage options of the index created on table emp to enforce the primary key constraint:

ALTER TABLE emp
     ENABLE PRIMARY KEY USING INDEX;
See Also:
Oracle Database SQL Language Reference for syntax and restrictions on the use of the ALTER INDEX statement
Rebuilding an Existing Index

Before rebuilding an existing index, compare the costs and benefits associated with rebuilding to those associated with coalescing indexes as described in Table 21-1.

When you rebuild an index, you use an existing index as the data source. Creating an index in this manner enables you to change storage characteristics or move to a new tablespace. Rebuilding an index based on an existing data source removes intra-block fragmentation. Compared to dropping the index and using the CREATE INDEX statement, re-creating an existing index offers better performance.

The following statement rebuilds the existing index emp_name:

ALTER INDEX emp_name REBUILD;
The REBUILD clause must immediately follow the index name, and precede any other options. It cannot be used in conjunction with the DEALLOCATE UNUSED clause.

You have the option of rebuilding the index online. Rebuilding online enables you to update base tables at the same time that you are rebuilding. The following statement rebuilds the emp_name index online:

ALTER INDEX emp_name REBUILD ONLINE;
--To rebuild an index in a different user's schema online, the following additional system privileges are required:

CREATE ANY TABLE

CREATE ANY INDEX

Note:
Online index rebuilding has stricter limitations on the maximum key length that can be handled, compared to other methods of rebuilding an index. If an ORA-1450 (maximum key length exceeded) error occurs when rebuilding online, try rebuilding offline, coalescing, or dropping and recreating the index.
If you do not have the space required to rebuild an index, you can choose instead to coalesce the index. Coalescing an index is an online operation.

See Also:
"Creating an Index Online"

"Monitoring Space Use of Indexes"

Making an Index Unusable

When you make an index unusable, it is ignored by the optimizer and is not maintained by DML. When you make one partition of a partitioned index unusable, the other partitions of the index remain valid.

You must rebuild or drop and re-create an unusable index or index partition before using it.

The following procedure illustrates how to make an index and index partition unusable, and how to query the object status.

To make an index unusable: 

Query the data dictionary to determine whether an existing index or index partition is usable or unusable.

For example, issue the following query (output truncated to save space):

hr@PROD> SELECT INDEX_NAME AS "INDEX OR PART NAME", STATUS, SEGMENT_CREATED
  2  FROM   USER_INDEXES
  3  UNION ALL
  4  SELECT PARTITION_NAME AS "INDEX OR PART NAME", STATUS, SEGMENT_CREATED
  5  FROM   USER_IND_PARTITIONS;
 
INDEX OR PART NAME             STATUS   SEG
------------------------------ -------- ---
I_EMP_ENAME                    N/A      N/A
JHIST_EMP_ID_ST_DATE_PK        VALID    YES
JHIST_JOB_IX                   VALID    YES
JHIST_EMPLOYEE_IX              VALID    YES
JHIST_DEPARTMENT_IX            VALID    YES
EMP_EMAIL_UK                   VALID    NO
.
.
.
COUNTRY_C_ID_PK                VALID    YES
REG_ID_PK                      VALID    YES
P2_I_EMP_ENAME                 USABLE   YES
P1_I_EMP_ENAME                 UNUSABLE NO
 
22 rows selected.
The preceding output shows that only index partition p1_i_emp_ename is unusable.

Make an index or index partition unusable by specifying the UNUSABLE keyword.

The following example makes index emp_email_uk unusable:

hr@PROD> ALTER INDEX emp_email_uk UNUSABLE;
 
Index altered.
The following example makes index partition p2_i_emp_ename unusable:

hr@PROD> ALTER INDEX i_emp_ename MODIFY PARTITION p2_i_emp_ename UNUSABLE;
 
Index altered.
Optionally, query the data dictionary to verify the status change.

For example, issue the following query (output truncated to save space):

hr@PROD> SELECT INDEX_NAME AS "INDEX OR PARTITION NAME", STATUS, 
  2  SEGMENT_CREATED
  3  FROM   USER_INDEXES
  4  UNION ALL
  5  SELECT PARTITION_NAME AS "INDEX OR PARTITION NAME", STATUS, 
  6  SEGMENT_CREATED
  7  FROM   USER_IND_PARTITIONS;
 
INDEX OR PARTITION NAME        STATUS   SEG
------------------------------ -------- ---
I_EMP_ENAME                    N/A      N/A
JHIST_EMP_ID_ST_DATE_PK        VALID    YES
JHIST_JOB_IX                   VALID    YES
JHIST_EMPLOYEE_IX              VALID    YES
JHIST_DEPARTMENT_IX            VALID    YES
EMP_EMAIL_UK                   UNUSABLE NO
.
.
.
COUNTRY_C_ID_PK                VALID    YES
REG_ID_PK                      VALID    YES
P2_I_EMP_ENAME                 UNUSABLE NO
P1_I_EMP_ENAME                 UNUSABLE NO
 
22 rows selected.
A query of space consumed by the i_emp_ename and emp_email_uk segments shows that the segments no longer exist:

hr@PROD> SELECT SEGMENT_NAME, BYTES
  2  FROM   USER_SEGMENTS
  3  WHERE  SEGMENT_NAME IN ('I_EMP_ENAME', 'EMP_EMAIL_UK');
 
no rows selected
See Also:
"Understand When to Use Unusable or Invisible Indexes"

"Creating an Unusable Index"

Oracle Database SQL Language Reference for more information about the UNUSABLE keyword, including restrictions

Making an Index Invisible

An invisible index is ignored by the optimizer unless you explicitly set the OPTIMIZER_USE_INVISIBLE_INDEXES initialization parameter to TRUE at the session or system level. Making an index invisible is an alternative to making it unusable or dropping it. You cannot make an individual index partition invisible. Attempting to do so produces an error.

To make an index invisible: 

Submit the following SQL statement:

ALTER INDEX index INVISIBLE;
To make an invisible index visible again: 

Submit the following SQL statement:

ALTER INDEX index VISIBLE;
To determine whether an index is visible or invisible: 

Query the dictionary views USER_INDEXES, ALL_INDEXES, or DBA_INDEXES.

For example, to determine if the index ind1 is invisible, issue the following query:

SELECT INDEX_NAME, VISIBILITY FROM USER_INDEXES
   WHERE INDEX_NAME = 'IND1';

INDEX_NAME   VISIBILITY
----------   ----------
IND1         VISIBLE
See Also:
"Understand When to Use Unusable or Invisible Indexes"

"Creating an Invisible Index"

Renaming an Index

To rename an index, issue this statement:

ALTER INDEX index_name RENAME TO new_name;
Monitoring Index Usage

Oracle Database provides a means of monitoring indexes to determine whether they are being used. If an index is not being used, then it can be dropped, eliminating unnecessary statement overhead.

To start monitoring the usage of an index, issue this statement:

ALTER INDEX index MONITORING USAGE;
Later, issue the following statement to stop the monitoring:

ALTER INDEX index NOMONITORING USAGE;
The view V$OBJECT_USAGE can be queried for the index being monitored to see if the index has been used. The view contains a USED column whose value is YES or NO, depending upon if the index has been used within the time period being monitored. The view also contains the start and stop times of the monitoring period, and a MONITORING column (YES/NO) to indicate if usage monitoring is currently active.

Each time that you specify MONITORING USAGE, the V$OBJECT_USAGE view is reset for the specified index. The previous usage information is cleared or reset, and a new start time is recorded. When you specify NOMONITORING USAGE, no further monitoring is performed, and the end time is recorded for the monitoring period. Until the next ALTER INDEX...MONITORING USAGE statement is issued, the view information is left unchanged.

