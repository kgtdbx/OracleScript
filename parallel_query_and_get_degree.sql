--Oracle Database - How to (enable|disable) parallel query and get (degree of parallelism|DOP) ?
--https://gerardnico.com/db/oracle/parallel_enable
/*
> Database
> Oracle Database
-Table of Contents
1 - About
2 - Articles Related
3 - Don't enable parallelism for small objects
4 - Type of execution
4.1 - Query
4.1.1 - Hint
4.1.2 - Session
4.1.3 - Table
4.2 - DML
5 - Documentation / Reference
1 - About
How to enable a parallel execution:

for a query
for a DML operation
2 - Articles Related
Oracle Database - (Degree|Degree of Parallelism (DOP))
Oracle Database - Parallel DML
Oracle Database - SQL Parallel Execution
3 - Don't enable parallelism for small objects
Small tables/indexes (up to thousands of records; up to 10s of data blocks) should never be enabled for parallel execution. Operations that only hit small tables will not benefit much from executing in parallel, whereas they would use parallel servers that you want to be available for operations accessing large tables.

Best practices when using object sizes as the main driving factor for parallelism are commonly aligning the DOP with some kind of step function for parallelism, e.g.

objects smaller than 200 MB will not use any parallelism
objects between 200 MB and 5GB are using a DOP of 4
objects beyond 5GB are getting a DOP of 32
Needless to say that your personal optimal settings may vary - either in size range or DOP - and highly depend on your target workload and business requirements only.

4 - Type of execution
4.1 - Query
You can enable parallel execution and determine the DOP in the following priority order:

hint
session
table
The DOP is limited by the Oracle Database Resource Manager (DBRM) settings. For example, if your resource plan has a policy of using a maximum DOP of 4 and you request a DOP of 16 via a hint, your SQL will run with a DOP of 4.

4.1.1 - Hint
Oracle will make use of Parallel Loading when “Parallel” hints is used in a query block SQL Statement. The requested DOP for this query is DEFAULT.
*/
SELECT /*+ parallel(c) parallel(s) */
c.state_province
, SUM(s.amount) revenue
FROM customers c
, sales s
WHERE s.customer_id = c.id
AND s.purchase_date
BETWEEN to_date('01-JAN-2007','DD-MON-YYYY')
AND to_date('31-DEC-2007','DD-MON-YYYY')
AND c.country = 'United States'
GROUP BY c.state_province
/
--This method is mainly useful for testing purposes, or if you have a particular statement or few statements that you want to execute in parallel, but most statements run in serial.

--The requested DOP for this query is 16 for the s table (sales)

SELECT /*+ parallel(s,16) */ COUNT(*)
FROM sales s ;
/*4.1.2 - Session
Reference: Oracle® Database SQL Reference - 10g Release 2 (10.2) - Alter Session

4.1.2.1 - Enable
The PARALLEL parameter determines whether all subsequent query statements in the session will be considered for parallel execution.

Force: If no parallel clause or hint is specified, then a DEFAULT degree of parallelism is used.
*/
ALTER SESSION force parallel query;
--This force method is useful if your application always runs in serial except for this particular session that you want to execute in parallel. A batch operation in an OLTP application may fall into this category.

ALTER SESSION enable parallel query;
--4.1.2.2 - Disable
ALTER session disable parallel query;
--4.1.2.3 - Get
SELECT DISTINCT px.req_degree "Req. DOP",
  px.degree "Actual DOP"
FROM v$px_session px
WHERE px.req_degree IS NOT NULL

/*
Req. DOP               Actual DOP             
---------------------- ---------------------- 
16                     16                    
4.1.3 - Table
4.1.3.1 - Enable*/
ALTER TABLE <table_name> PARALLEL 32;
ALTER TABLE <table_name> PARALLEL ( DEGREE 32 );
ALTER TABLE <table_name> PARALLEL ( DEGREE DEFAULT );
--Use this method if you generally want to execute operations accessing these tables in parallel.
/*
Tables and/or indexes in the select statement accessed have the parallel degree setting at the object level. If objects have a DEFAULT setting then the database determines the DOP value that belongs to DEFAULT.

For a query that processes objects with different DOP settings, the object with the highest parallel degree setting accessed in the query determines the requested DOP.

4.1.3.2 - Disable
*/
ALTER TABLE TABLE_NAME NOPARALLEL;
--4.1.3.3 - Get
SELECT TABLE_NAME, degree FROM user_tables WHERE TABLE_NAME='MyTableName';
--4.2 - DML
--To enable parallelization of Data Manipulation Language (DML) statements such as INSERT, UPDATE, and DELETE , execute the following statement.

ALTER SESSION enable parallel dml;
--To see the rule on parallel DML, see this article Oracle Database - Parallel DML
/*
5 - Documentation / Reference
Oracle SQL Parallel Execution - An Oracle White Paper - June 2008
db/oracle/parallel_enable.txt · Last modified: 2017/09/13 16:16 by gerardnico
*/


/*
Rules for Parallelizing Queries
A SQL query can only be executed in parallel under certain conditions.
A SELECT statement can be executed in parallel only if one of the following conditions is satisfied:
The query includes a statement level or object level parallel hint specification (PARALLEL or PARALLEL_INDEX).
The schema objects referred to in the query have a PARALLEL declaration associated with them.
Automatic Degree of Parallelism (Auto DOP) has been enabled.
Parallel query is forced using the ALTER SESSION FORCE PARALLEL QUERY statement.
In addition, the execution plan should have at least one of the following:

A full table scan

An index range scan spanning multiple partitions

An index fast full scan

A parallel table function
*/


/*
DDL Statements That Can Be Parallelized
You can execute DDL statements in parallel for tables and indexes that are nonpartitioned or partitioned.

The parallel DDL statements for nonpartitioned tables and indexes are:

CREATE INDEX

CREATE TABLE AS SELECT

ALTER TABLE MOVE

ALTER INDEX REBUILD

The parallel DDL statements for partitioned tables and indexes are:

CREATE INDEX

CREATE TABLE AS SELECT

ALTER TABLE {MOVE|SPLIT|COALESCE} PARTITION

ALTER INDEX {REBUILD|SPLIT} PARTITION

This statement can be executed in parallel only if the (global) index partition being split is usable.

All of these DDL operations can be performed in NOLOGGING mode for either parallel or serial execution.

The CREATE TABLE statement for an index-organized table can be executed in parallel either with or without an AS SELECT clause.

Parallel DDL cannot occur on tables with object columns. Parallel DDL cannot occur on nonpartitioned tables with LOB columns.
*/


--execute immediate 'ALTER SESSION FORCE parallel DML parallel 8';
--execute immediate 'ALTER SESSION FORCE parallel QUERY parallel 8';

--execute immediate 'ALTER SESSION DISABLE parallel DML';
--execute immediate 'ALTER SESSION DISABLE parallel QUERY';
    