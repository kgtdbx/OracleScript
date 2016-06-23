/*virtual columns in 11g

Oracle has supported stored expressions for many years, in views and function-based indexes. Most commonly, views enable us to store and modularise computations and expressions based on their underlying tables' columns. In more recent versions (since around the 8i timeframe), we have been able to index expressions using function-based indexes. Now, with the release of 11g, Oracle enables us to store expressions directly in the base tables themselves as virtual columns.

As we will see in this article, virtual columns are more flexible than any of their prior alternatives. We will examine their basic usage and also consider some of the performance aspects of the new feature.

creating a virtual column

We will begin by creating a simple table with a single virtual column, as follows.
*/
SQL> CREATE TABLE t
  2  ( n1 INT
  3  , n2 INT
  4  , n3 INT GENERATED ALWAYS AS (n1 + n2) VIRTUAL
  5  );

Table created.
/*
We can see that the virtual column is generated from a simple expression involving the other columns in our table. Note that the VIRTUAL keyword is optional and is included for what Oracle calls "syntactic clarity".

Virtual column values are not stored on disk. They are generated at runtime using their associated expression (in our example, N1 + N2). This has some implications for the way we insert data into tables with virtual columns, as we can see below.
*/
SQL> INSERT INTO t VALUES (10, 20, 30);
INSERT INTO t VALUES (10, 20, 30)
            *
ERROR at line 1:
ORA-54013: INSERT operation disallowed on virtual columns
We cannot explicitly add data to virtual columns, so we will attempt an insert into the physical columns only, as follows.

SQL> INSERT INTO t VALUES (10, 20);
INSERT INTO t VALUES (10, 20)
            *
ERROR at line 1:
ORA-00947: not enough values
/*
Despite the fact that we cannot insert or update virtual columns, they are still considered part of the table's column list. This means, therefore, that we must explicitly reference the physical columns in our insert statements, as follows.
*/
SQL> INSERT INTO t (n1, n2) VALUES (10, 20);

1 row created.
/*
Of course, fully-qualified inserts such as our example above are best practice so this should be a trivial restriction for most developers. Now we have data in our example table, we can query our virtual column, as follows.
*/
SQL> SELECT * FROM t;

        N1         N2         N3
---------- ---------- ----------
        10         20         30

1 row selected.

/*
Our expression is evaluated at runtime and gives the output we see above.

indexes and constraints

Virtual columns are valid for indexes and constraints. Indexes on virtual columns are essentially function-based indexes (this is covered in more detail later in this article). The results of the virtual column's expression are stored in the index. In the following example, we will create a primary key constraint on the N3 virtual column.
*/
SQL> CREATE UNIQUE INDEX t_pk ON t(n3);

Index created.

SQL> ALTER TABLE t ADD
  2     CONSTRAINT t_pk
  3     PRIMARY KEY (n3)
  4     USING INDEX;

Table altered.
--If we try to insert data that results in a duplicate virtual column value, we should expect a unique constraint violation, as follows.

SQL> INSERT INTO t (n1, n2) VALUES (10, 20);
INSERT INTO t (n1, n2) VALUES (10, 20)
*
ERROR at line 1:
ORA-00001: unique constraint (SCOTT.T_PK) violated
/*
As expected, this generates an ORA-00001 exception.

It follows, therefore, that if we can create a primary key on a virtual column, then we can reference it from a foreign key constraint. In the following example, we will create a child table with a foreign key to the T.N3 virtual column.
*/
SQL> CREATE TABLE t_child
  2  ( n3 INT
  3  , CONSTRAINT tc_fk
  4       FOREIGN KEY  (n3)
  5       REFERENCES  t(n3)
  6  );

Table created.
We will now insert some valid and invalid data, as follows.

SQL> INSERT INTO t_child VALUES (30);

1 row created.

SQL> INSERT INTO t_child VALUES (40);
INSERT INTO t_child VALUES (40)
*
ERROR at line 1:
ORA-02291: integrity constraint (SCOTT.TC_FK) violated - parent key not found
/*
adding virtual columns

Virtual columns can be added after table creation with an ALTER TABLE statement. In the following example, we will add a new virtual column to our existing table. We will include a check constraint for demonstration purposes.
*/
SQL> ALTER TABLE t ADD
  2     n4 GENERATED ALWAYS AS (n1 * n2)
  3        CHECK (n4 >= 10);

Table altered.
/*
As stated earlier, an index on a virtual column will store the results of the expression. A check constraint, however, will evaluate the expression at the time of adding or modifying data to the underlying table. This is seemingly obvious, because there is no associated storage structure (i.e. index) with a check constraint.

Our new virtual column, N4, has a check constraint to ensure that the product of the N1 and N2 columns is greater than 10. We will test this, as follows.
*/
SQL> INSERT INTO t (n1, n2) VALUES (1, 2);
INSERT INTO t (n1, n2) VALUES (1, 2)
*
ERROR at line 1:
ORA-02290: check constraint (SCOTT.SYS_C0010001) violated
/*
virtual columns based on pl/sql functions

Virtual columns can include PL/SQL functions, either in their entirety or as part of an expression. The only proviso is that the function must be deterministic. The function itself can be standalone or in a package. In the following example, we will create a deterministic function that returns the sum of two parameters and base a new virtual column on it. First, we create the function, as follows.
*/
SQL> CREATE FUNCTION addthem(
  2                  p1 IN INTEGER,
  3                  p2 IN INTEGER ) RETURN INTEGER DETERMINISTIC AS
  4  BEGIN
  5     RETURN p1 + p2;
  6  END addthem;
  7  /

Function created.
/*
Note the use of the keyword DETERMINISTIC to ensure that we can use this function in a virtual column expression. We will now add a third virtual column to our existing table, this time using the ADDTHEM function as the basis of the expression.
*/
SQL> ALTER TABLE t ADD n5 GENERATED ALWAYS AS (addthem(n1,n2));

Table altered.
We will test our new virtual column, as follows.

SQL> SELECT n1, n2, n5 FROM t;

        N1         N2         N5
---------- ---------- ----------
        10         20         30

1 row selected.
/*
As we can see, the N5 column returns the same results as the N3 virtual column. There are some design benefits to wrapping expressions in stored programs, yet there will be a performance penalty as a result. We can see this quite clearly with a simple example. We will compare the time it takes to query 1 million records from N3 and N5. We will begin by loading the sample table as follows.
*/
SQL> INSERT INTO t (n1, n2)
  2  SELECT ROWNUM*10, TRUNC(ROWNUM/20)+1
  3  FROM   dual
  4  CONNECT BY ROWNUM < 1000000;

999999 rows created.

SQL> COMMIT;

Commit complete.

--We now have 1 million records in our T table. We will select N3 and N5 in separate queries, using Autotrace and the wall-clock as an approximate measure of relative performance.

SQL> set autotrace traceonly statistics

SQL> set timing on

SQL> SELECT n3 FROM t;

1000000 rows selected.

Elapsed: 00:00:03.81

Statistics
----------------------------------------------------------
         14  recursive calls
          3  db block gets
       6210  consistent gets
       1140  physical reads
     162680  redo size
    7151701  bytes sent via SQL*Net to client
      22405  bytes received via SQL*Net from client
       2001  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
    1000000  rows processed

SQL> SELECT n5 FROM t;

1000000 rows selected.

Elapsed: 00:00:09.29

Statistics
----------------------------------------------------------
          4  recursive calls
          0  db block gets
       6374  consistent gets
       1155  physical reads
     151000  redo size
    7151701  bytes sent via SQL*Net to client
      22405  bytes received via SQL*Net from client
       2001  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
    1000000  rows processed

	/*
	In our approximate comparison, the virtual column based on a PL/SQL function (N5) took nearly three times longer to query than the column based on an expression (N3). The I/O was approximately the same for both queries. For simple expressions such as our example above, it therefore makes sense to use virtual columns (or views in versions prior to 11g) to encapsulate our business logic, thereby avoiding the performance penalty of using PL/SQL functions (primarily context-switching). Note that for PL/SQL function-based virtual columns with low cardinality (i.e. a small number of distinct values), we might get some benefit from Oracle 11g's new function result-caching. However, this will still be slower than using an inlined expression for the virtual column.

virtual column and comments

Finally for this overview, we can create comments on virtual columns in the same way as physical columns. In the following examples, we will add comments to our existing virtual columns.
*/
SQL> COMMENT ON COLUMN t.n3 IS 'Virtual column [n1 + n2]';

Comment created.

SQL> COMMENT ON COLUMN t.n4 IS 'Virtual column [n1 * n2]';

Comment created.

SQL> COMMENT ON COLUMN t.n5 IS 'Virtual column [addthem(n1,n2)]';

Comment created.

SQL> SELECT column_name
  2  ,      comments
  3  FROM   user_col_comments
  4  WHERE  table_name = 'T';

COLUMN_NAME          COMMENTS
-------------------- ----------------------------------------
N1
N2
N3                   Virtual column [n1 + n2]
N4                   Virtual column [n1 * n2]
N5                   Virtual column [addthem(n1,n2)]

5 rows selected.
/*
metadata

We can find information on virtual columns in several places in the data dictionary. In the following queries, we will lookup some basic information from the USER_ dictionary views, although the same information is available in the ALL_ and DBA_ derivatives.

column information

We will begin by querying some column information from USER_TAB_COLUMNS, as follows.
*/
SQL> SELECT column_name
  2  ,      data_type
  3  ,      data_default
  4  FROM   user_tab_columns
  5  WHERE  table_name = 'T'
  6  ORDER  BY
  7         column_id;

COLUMN_NAME DATA_TYPE DATA_DEFAULT
----------- --------- --------------------------------
N1          NUMBER
N2          NUMBER
N3          NUMBER    "N1"+"N2"
N4          NUMBER    "N1"*"N2"
N5          NUMBER    "SCOTT"."ADDTHEM"("N1","N2")

5 rows selected.

--The DATA_DEFAULT column stores the expressions we used to define our virtual columns. The USER_TAB_COLS view distinguishes between physical and virtual columns, as follows.

SQL> SELECT column_name
  2  ,      virtual_column
  3  ,      segment_column_id
  4  ,      internal_column_id
  5  FROM   user_tab_cols
  6  WHERE  table_name = 'T'
  7  ORDER  BY
  8         column_id;

COLUMN_NAME VIRTUAL_COLUMN SEGMENT_COLUMN_ID INTERNAL_COLUMN_ID
----------- -------------- ----------------- ------------------
N1          NO                             1                  1
N2          NO                             2                  2
N3          YES                                               3
N4          YES                                               4
N5          YES                                               5

5 rows selected.
/*
index information

Remember that we created an index on one of our virtual columns. The USER_INDEXES view gives us a clue to its implementation, as follows.
*/
SQL> SELECT index_name
  2  ,      index_type
  3  ,      funcidx_status
  4  FROM   user_indexes
  5  WHERE  table_name = 'T';

INDEX_NAME INDEX_TYPE                  FUNCIDX_STATUS
---------- --------------------------- --------------
T_PK       FUNCTION-BASED NORMAL       ENABLED

1 row selected.

/*
The INDEX_TYPE tells us that Oracle created a function-based index on our virtual column. In fact, this makes perfect sense, because virtual columns are derived using the same types of expressions as those permitted for the original function-based indexes (as an aside, Jonathan Lewis wrote some years back that FBIs should have been named "expression-based indexes"). Neither virtual columns nor the expressions used for function-based indexes are physically stored anywhere other than in the index itself.

We can query USER_IND_EXPRESSIONS to get more information on function-based indexes. This view includes the following information for the T_PK index on the N3 virtual column.
*/
SQL> SELECT *
  2  FROM   user_ind_expressions
  3  WHERE  index_name = 'T_PK';

INDEX_NAME TABLE_NAME COLUMN_EXPRESSION COLUMN_POSITION
---------- ---------- ----------------- ---------------
T_PK       T          "N1"+"N2"                       1
/*
This type of information should be familiar to developers who have used function-based indexes in the past.

other information

Note that other views containing column and constraint information (such as USER_CONS_COLUMNS, USER_CONSTRAINTS, USER_COL_COMMENTS and so on) don't distinguish between physical and virtual columns and can be interpreted in the usual way.

virtual columns and storage

As stated earlier, virtual columns do not consume any table storage other than the small amount of metadata in the data dictionary (of course, any indexes we create on virtual columns will require storage space). Built-in functions such as DUMP and VSIZE will, however, continue to return "normal" results for virtual columns, because they operate on the results of the expression and not the underlying stored column values (which are non-existent, of course). We can see this as follows.
*/
SQL> SELECT DUMP(n3)  AS dump
  2  ,      VSIZE(n3) AS vsize
  3  FROM   t
  4  WHERE  ROWNUM = 1;

DUMP                                  VSIZE
----------------------------------- -------
Typ=2 Len=2: 193,31                       2

1 row selected.

/*
Note that some executions of this query led to an internal error (ORA-00600: internal error code, arguments: [qkaffsindex5]), so there is a bug to be investigated at some stage.

To correctly demonstrate that a virtual column uses no storage would require techniques such as block dumping, which is beyond the scope of this article. We can, however, show that adding more virtual columns to an existing table doesn't require any additional space. In the following example, we will create two tables of 10,000 records each and compare their relative sizes (one table will have several virtual columns). We will begin by creating the tables as follows.
*/
SQL> CREATE TABLE ten_thousand_rows
  2  ( c1 VARCHAR2(4000)
  3  , c2 VARCHAR2(4000)
  4  , c3 VARCHAR2(4000)
  5  )
  6  PCTFREE 0;

Table created.

SQL> CREATE TABLE ten_thousand_rows_vc
  2  ( c1 VARCHAR2(4000)
  3  , c2 VARCHAR2(4000)
  4  , c3 VARCHAR2(4000)
  5  , c4 VARCHAR2(4000) GENERATED ALWAYS AS (UPPER(c1)) VIRTUAL
  6  , c5 VARCHAR2(4000) GENERATED ALWAYS AS (UPPER(c2)) VIRTUAL
  7  , c6 VARCHAR2(4000) GENERATED ALWAYS AS (UPPER(c3)) VIRTUAL
  8  )
  9  PCTFREE 0;

Table created.
We will now load each table with 10,000 identical rows.

SQL> INSERT INTO ten_thousand_rows
  2  SELECT RPAD('x',4000)
  3  ,      RPAD('x',4000)
  4  ,      RPAD('x',4000)
  5  FROM   dual
  6  CONNECT BY ROWNUM <= 10000;

10000 rows created.

SQL> INSERT INTO ten_thousand_rows_vc (c1, c2, c3)
  2  SELECT RPAD('x',4000)
  3  ,      RPAD('x',4000)
  4  ,      RPAD('x',4000)
  5  FROM   dual
  6  CONNECT BY ROWNUM <= 10000;

10000 rows created.
Finally, we can compare the sizes of the two tables, as follows.

SQL> SELECT segment_name
  2  ,      bytes
  3  ,      blocks
  4  ,      extents
  5  FROM   user_segments
  6  WHERE  segment_name LIKE 'TEN_THOUSAND_ROWS%';

SEGMENT_NAME                   BYTES     BLOCKS    EXTENTS
------------------------- ---------- ---------- ----------
TEN_THOUSAND_ROWS          125829120      15360         86
TEN_THOUSAND_ROWS_VC       125829120      15360         86

2 rows selected.
/*
As expected, the tables' physical storage requirements (excepting the dictionary metadata) are identical.

virtual columns and the cbo

At a high-level, the CBO treats virtual columns the same as physical columns, generally making the same estimates in the absence of statistics. If we enable Autotrace in SQL*Plus, we can see some example plans by querying the physical and virtual columns we created in the TEN_THOUSAND_ROWS_VC table. First, however, we will update one of the physical columns to shorten the output from the predicate section of DBMS_XPLAN (remember that all columns in this example table are currently 4,000 bytes).
*/
SQL> UPDATE ten_thousand_rows_vc SET c1 = 'X';

10000 rows updated.

SQL> COMMIT;

Commit complete.

--We can now run some sample queries, using Autotrace to output the theoretical plans.

SQL> set autotrace traceonly explain

SQL> SELECT * FROM ten_thousand_rows_vc WHERE c1 = 'X';

Execution Plan
------------------------------------------------------------------------------------------
Plan hash value: 1380810427

------------------------------------------------------------------------------------------
| Id  | Operation         | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                      |  9166 |   105M|  4123   (1)| 00:00:50 |
|*  1 |  TABLE ACCESS FULL| TEN_THOUSAND_ROWS_VC |  9166 |   105M|  4123   (1)| 00:00:50 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("C1"='X')

Note
-----
   - dynamic sampling used for this statement
/*
   There are no statistics on this table, so dynamic sampling has been used. The optimiser has estimated that almost all of the rows in our table will be satisfied by the query. The corresponding virtual column for C1 is C4 (generated as UPPER(c1)), which we will query in the same way, as follows.
*/
SQL> SELECT * FROM ten_thousand_rows_vc WHERE c4 = 'X';

Execution Plan
----------------------------------------------------------
Plan hash value: 1380810427

------------------------------------------------------------------------------------------
| Id  | Operation         | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                      |    92 |  1079K|  4123   (1)| 00:00:50 |
|*  1 |  TABLE ACCESS FULL| TEN_THOUSAND_ROWS_VC |    92 |  1079K|  4123   (1)| 00:00:50 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("C4"='X')

Note
-----
   - dynamic sampling used for this statement
/*
   The CBO estimates a different cardinality for the virtual column, despite it being a derivative of the base column. It appears as though the CBO has used its standard 1% selectivity for "function(column) = literal" to derive these numbers (the C4 virtual column estimate is 1% of the base C1 cardinality estimate).

Interestingly, Oracle used dynamic sampling for this query as well, which tells us that we can gather statistics on virtual columns (noted in the online documentation, of course). The fact that we can gather column-level statistics (and therefore histograms) on the underlying expressions means that the CBO can be far more accurate when costing statements involving virtual columns. We will now gather statistics and repeat the query against C4, as follows.
*/
SQL> BEGIN
  2     DBMS_STATS.GATHER_TABLE_STATS(USER, 'TEN_THOUSAND_ROWS_VC');
  3  END;
  4  /

PL/SQL procedure successfully completed.

SQL> set autotrace traceonly explain

SQL> SELECT * FROM ten_thousand_rows_vc WHERE c4 = 'X';

Execution Plan
----------------------------------------------------------
Plan hash value: 1380810427

------------------------------------------------------------------------------------------
| Id  | Operation         | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                      | 10000 |   152M|  4123   (1)| 00:00:50 |
|*  1 |  TABLE ACCESS FULL| TEN_THOUSAND_ROWS_VC | 10000 |   152M|  4123   (1)| 00:00:50 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("C4"='X')
With statistics available, the CBO makes a correct cardinality calculation. We can verify that we gathered statistics using dictionary views at both table and column level, as follows.

SQL> SELECT num_rows
  2  ,      sample_size
  3  FROM   user_tab_statistics
  4  WHERE  table_name = 'TEN_THOUSAND_ROWS_VC';

  NUM_ROWS SAMPLE_SIZE
---------- -----------
     10000       10000

1 row selected.

SQL> SELECT column_name
  2  ,      num_distinct
  3  ,      density
  4  ,      num_nulls
  5  ,      num_buckets
  6  ,      histogram
  7  FROM   user_tab_col_statistics
  8  WHERE  table_name = 'TEN_THOUSAND_ROWS_VC'
  9  ORDER  BY
 10         column_name;

COLUMN_NAME   NUM_DISTINCT    DENSITY  NUM_NULLS NUM_BUCKETS HISTOGRAM
------------- ------------ ---------- ---------- ----------- ---------------
C1                       1     .00005          0           1 FREQUENCY
C2                       1          1          0           1 NONE
C3                       1          1          0           1 NONE
C4                       1     .00005          0           1 FREQUENCY
C5                       1          1          0           1 NONE
C6                       1          1          0           1 NONE

6 rows selected.
/*
We appear to have accurate statistics. Note the density column values for C1 and C4, which are modified due to the presence of the frequency histograms. The histograms will have been created by DBMS_STATS because we used both C1 and C4 in predicates prior to gathering statistics (in recent versions, Oracle tracks all columns used in predicates, which enables DBMS_STATS to decide when to create histograms).

cost adjustments

Before we move on, there is a small detail related to virtual columns in the optimiser's costings. If we run a 10053 trace (CBO) for our previous SQL statement, we find the following excerpt in the trace file.

Table Stats::
  Table: TEN_THOUSAND_ROWS_VC  Alias: TEN_THOUSAND_ROWS_VC
    #Rows: 10000  #Blks:  15197  AvgRowLen:  16008.00
Access path analysis for TEN_THOUSAND_ROWS_VC
***************************************
SINGLE TABLE ACCESS PATH 
  Single Table Cardinality Estimation for TEN_THOUSAND_ROWS_VC[TEN_THOUSAND_ROWS_VC] 
 ***** Virtual column  Adjustment ****** 
 Column name       C4  
 cost_cpu 150.00
 cost_io  179769313486231570000 << ...hundreds of zeroes removed... >> 000.00
 ***** End virtual column  Adjustment ****** 
This gives us an interesting insight into the costing mechanisms that Oracle uses for virtual columns. It adjusts the CPU cost, presumably to account for the fact that the column needs to be derived by computation, which requires additional CPU.

virtual column replacement

If we continue to search the trace file for virtual column references, we also find some related parameters, as follows:

_trace_virtual_columns = false
_replace_virtual_columns = true
_virtual_column_overload_allowed = true
Of course, being undocumented parameters, we can only guess the effect that each of these parameters has, however well they are named. The second parameter, _replace_virtual_columns, is related to the rewriting of expressions in predicates to use candidate virtual columns. In the following example, we will query the TEN_THOUSAND_ROWS table using the underlying expression to C4, as follows. Note that the _replace_virtual_columns parameter is set to its default of TRUE.
*/
SQL> set autotrace traceonly explain

SQL> SELECT * FROM ten_thousand_rows_vc WHERE UPPER(c1) = 'X';

Execution Plan
----------------------------------------------------------
Plan hash value: 1380810427

------------------------------------------------------------------------------------------
| Id  | Operation         | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                      | 10000 |   152M|  4123   (1)| 00:00:50 |
|*  1 |  TABLE ACCESS FULL| TEN_THOUSAND_ROWS_VC | 10000 |   152M|  4123   (1)| 00:00:50 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("TEN_THOUSAND_ROWS_VC"."C4"='X')
/*
   Oracle has "redirected" our predicate to use the C4 virtual column. In doing so, it was able to make use of our statistics on that column and make an accurate cardinality calculation. We will now set this parameter to false and repeat the query, as follows (warning: do not change underscore parameters on any systems other than scratch/sandbox databases and without the approval of Oracle Support).
*/
SQL> ALTER SESSION SET "_replace_virtual_columns" = FALSE;

Session altered.

SQL> SELECT * FROM ten_thousand_rows_vc WHERE UPPER(c1) = 'X';

Execution Plan
----------------------------------------------------------
Plan hash value: 1380810427

------------------------------------------------------------------------------------------
| Id  | Operation         | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                      |   100 |  1563K|  4123   (1)| 00:00:50 |
|*  1 |  TABLE ACCESS FULL| TEN_THOUSAND_ROWS_VC |   100 |  1563K|  4123   (1)| 00:00:50 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(UPPER("C1")='X')
/*
   Without this feature enabled, the predicate remains unchanged. We can see the benefit of having virtual column replacement by comparing the cardinality estimates for our two queries. Without statistics on a random expression, the CBO makes an incorrect assumption regarding the number of rows this query returns (as we saw earlier, it uses 1% selectivity for an equality predicate between a function on a column and a constant literal). This also highlights the value of being able to gather statistics on virtual columns, because we get accurate cardinality estimates on data that is not stored anywhere.

Note that there seems to be some inconsistency with virtual column replacement. The following table highlights the difference between EXPLAIN PLAN and the runtime optimiser with respect to virtual column rewrite.

Predicate	Index	Runtime Optimiser	Explain Plan
N1 + N2 = 10	Y	access("T"."N3"=10)	access("N1"+"N2"=10)
N1 * N2 = 10	N	filter("N1"*"N2"=10)	filter("T"."N4"=10)
ADDTHEM(n1,n2) = 10	N	filter("SCOTT"."ADDTHEM"("N1","N2")=10)	filter("T"."N5"=10)
ADDTHEM(n1,n2) = 10	Y*	access("T"."N5"=10)	access("SCOTT"."ADDTHEM"("N1","N2")=10)
N3 = 10	Y	access("N3"=10)	access("N3"=10)
N4 = 10	N	filter("N1"*"N2"=10)	filter("N4"=10)
N5 = 10	N	filter("SCOTT"."ADDTHEM"("N1","N2")=10)	filter("N5"=10)
N5 = 10	Y*	access("T"."N5"=10)	access("SCOTT"."ADDTHEM"("N1","N2")=10)
UPPER(c1) = 'A'	N	filter(UPPER("C1")='A')	filter("TEN_THOUSAND_ROWS_VC"."C4"='A')
UPPER(c1) = 'A'	Y**	access("TEN_THOUSAND_ROWS_VC"."C4"='A')	access(UPPER("C1")='A')
C4 = 'A'	N	filter(UPPER("C1")='A')	filter("C4"='A')
C4 = 'A'	Y**	access("C4"='A')	access("C4"='A')
* index created on N5
** index created on C4

We can see that there are several differences between the runtime optimiser and Explain Plan utility. The main patterns emerging from these initial results are:

when a virtual column is indexed, the runtime optimiser rewrites all access predicates (including expressions) to use the virtual column;
when a virtual column is not indexed, the runtime optimiser rewrites all filter predicates (including explicit column references) to use the underlying expression;
when a virtual column is indexed and the predicate is an expression, Explain Plan will not rewrite the access;
when a virtual column is indexed and the predicate is an explicit column reference, Explain Plan will not rewrite the access. An exception to this is if the virtual column's underlying expression is a PL/SQL function call, in which case the column reference is rewritten to the call itself;
when a virtual column is not indexed and the predicate is an expression, Explain Plan will rewrite the filter to use the virtual column;
when a virtual column is not indexed and the predicate is an explicit column reference, Explain Plan will not rewrite the filter.
Why the Explain Plan utility behaves so differently to the runtime optimiser is unclear, but it is another example of how this tool diverges from the runtime optimiser "truth" as Oracle advances. As stated above, rewrite of expressions to virtual columns is critical if we want to make use of statistics on those columns and avoid CBO defaults.

virtual columns or views?

Many developers will recognise the fact that we can create "virtual columns" in most recent versions of Oracle by including expressions in views. We can also index such expressions using function-based indexes. While this might exclude some of the benefits of table-based virtual columns in 11g (such as statistics and/or histograms), a view should suffice for most requirements. We should not generally expect the performance of a derived column in a view to be any different to that of a virtual column, unless the data characteristics are such that having column statistics are essential.

The expression rewrite we saw in our examples above also applies to columns projected in views. By way of an example, we will create a simple view over our table T, repeating one of the table's virtual column expressions inline.
*/
SQL> CREATE VIEW v
  2  AS
  3     SELECT n1
  4     ,      n2
  5     ,      n1 + n2 AS n3
  6     FROM   t;

View created.
We will query our view and filter it on the N3 column, as follows.

SQL> SELECT * FROM v WHERE n3 > 10 AND ROWNUM = 1;

        N1         N2         N3
---------- ---------- ----------
        10          1         11

1 row selected.
/*
Remember that the N3 column above is an expression defined in the view and is not the underlying T.N3 virtual column. We will examine the execution plan for this query, but include the projection information to see how Oracle handles the expression in V.N3.
*/
SQL> SELECT *
  2  FROM   TABLE(
  3            DBMS_XPLAN.DISPLAY_CURSOR
  4               (NULL, NULL, 'TYPICAL +PROJECTION'));

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------
SQL_ID  gn2fdqs8gdt6z, child number 0
-------------------------------------
SELECT * FROM v WHERE n3 > 10 AND ROWNUM = 1

Plan hash value: 2185210849

-------------------------------------------------------------------------------------
| Id  | Operation                    | Name | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |      |       |       |     2 (100)|          |
|*  1 |  COUNT STOPKEY               |      |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| T    | 39096 |  1985K|     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | T_PK |  7037 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM=1)
   3 - access("T"."N3">10)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "N1"[NUMBER,22], "N2"[NUMBER,22], "T"."N3"[NUMBER,22]
   2 - "N1"[NUMBER,22], "N2"[NUMBER,22], "T"."N3"[NUMBER,22]
   3 - "T".ROWID[ROWID,10], "T"."N3"[NUMBER,22]

Note
-----
   - dynamic sampling used for this statement


32 rows selected.
/*
We can see that Oracle has recognised that the V.N3 expression is already served by the T.N3 virtual column and has rewritten both the access predicate and column projection, as highlighted in the plan. The benefit of this rewrite is that any available column statistics on T.N3 can be used by the CBO, rather than estimates based on a random expression. Note, however, that this rewrite has happened only because the underlying T.N3 virtual column is indexed. As we saw earlier, virtual columns without indexes are not candidates for expression replacement by the runtime optimiser.

a note on function-based indexes

With the virtual column feature in 11g, Oracle has seemingly re-used some of the implementation of function-based indexes (although we can do much more with virtual columns and do not necessarily need to index them, of course). For example, if we try to create a function-based index on one of our existing expressions, Oracle will raise an exception, as follows.
*/
SQL> CREATE INDEX t_fbi ON t(n1+n2);
CREATE INDEX t_fbi ON t(n1+n2)
                           *
ERROR at line 1:
ORA-54018: A virtual column exists for this expression
/*
Note that it is not index duplication that Oracle is preventing. Rather, it is virtual column duplication (yet when we create a function-based index, we are only trying to generate an index for the expression, not a column). So while we can create an index on a virtual column, we cannot create a function-based index on the same expression, regardless of whether the matching virtual column is indexed or not.

To demonstrate the similarity between basic virtual columns and function-based indexes, we will create a new table, T_FBI, as follows.
*/
SQL> CREATE TABLE t_fbi AS SELECT n1, n2 FROM t WHERE ROWNUM <= 100;

Table created.

--We will add a function-based index for the same expression that we used for T.N3 earlier, as follows.

SQL> CREATE INDEX t_fbi_i ON t_fbi(n1+n2);

Index created.
/*Finally, we will query the T_FBI table on the indexed expression and view the execution plan, as follows.
*/
SQL> SELECT * FROM t_fbi WHERE n1 + n2 > 10;

        N1         N2
---------- ----------
        10          1
        20          1
        30          1
<< ...snip... >>
       970          5
       980          5
       990          5

100 rows selected.

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------
SQL_ID  9444602r46ksk, child number 1
-------------------------------------
SELECT * FROM t_fbi WHERE n1 + n2 > 10

Plan hash value: 361701679

---------------------------------------------------------------------------------------
| Id  | Operation                   | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |         |       |       |     2 (100)|          |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_FBI   |     5 |   195 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_FBI_I |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T_FBI"."SYS_NC00003$">10)

Note
-----
   - dynamic sampling used for this statement


23 rows selected.
/*
We can clearly see that Oracle has used a virtual column to support our function-based index and has given it a system-generated name. We can see this because expression replacement is in operation for the query, as highlighted in the predicates. In fact, expression replacement is borne from function-based index technology and has been visible in execution plans since 10g Release 1. In Oracle 9i, however, neither the Explain Plan or cached runtime plan show this re-direct, despite there being an underlying hidden virtual column to support the function-based index.

Moving on, the USER_TAB_COLS view gives us more information about the "virtual column" created to support our function-based index, as follows.
*/
SQL> SELECT column_name
  2  ,      column_id
  3  ,      internal_column_id
  4  ,      hidden_column
  5  ,      virtual_column
  6  FROM   user_tab_cols
  7  WHERE  table_name = 'T_FBI';

COLUMN_NAME     COLUMN_ID INTERNAL_COLUMN_ID HIDDEN_COLUMN  VIRTUAL_COLUMN
-------------- ---------- ------------------ -------------- --------------
N1                      1                  1 NO             NO
N2                      2                  2 NO             NO
SYS_NC00003$                               3 YES            YES

3 rows selected.
/*
In this case, the column is hidden, although Oracle is now telling us that it is a virtual column. In fact, as we saw earlier, we use the same dictionary views to retrieve information on function-based indexes and indexes on virtual columns.

virtual columns and pl/sql

As might be expected, PL/SQL treats virtual columns in the same way as physical columns. This means, of course, that we can fetch them, reference them and use them as datatype anchors. In the following example, we will fetch a virtual column into an anchored variable.
*/
SQL> DECLARE
  2     v_variable t.n4%TYPE;
  3  BEGIN
  4     SELECT n4 INTO v_variable FROM t WHERE ROWNUM = 1;
  5     DBMS_OUTPUT.PUT_LINE(v_variable);
  6  END;
  7  /

PL/SQL procedure successfully completed.
/*
There really isn't much to consider for virtual columns in PL/SQL. One issue to be aware of, however, is that record-based DML will no longer work for tables with virtual columns, as the following demonstrates.
*/
SQL> DECLARE
  2     r_row t%ROWTYPE;
  3  BEGIN
  4     SELECT * INTO r_row FROM t WHERE ROWNUM = 1;
  5     INSERT INTO t VALUES r_row;
  6  END;
  7  /
DECLARE
*
ERROR at line 1:
ORA-54013: INSERT operation disallowed on virtual columns
ORA-06512: at line 5

--This is the same exception that was raised for our very first attempt to insert into the entire T table earlier. A similar exception is raised if we attempt a record-based update, as follows.

SQL> DECLARE
  2     r_row t%ROWTYPE;
  3  BEGIN
  4     SELECT * INTO r_row FROM t WHERE ROWNUM = 1;
  5     UPDATE t SET ROW = r_row WHERE n1 = r_row.n1;
  6  END;
  7  /
DECLARE
*
ERROR at line 1:
ORA-54017: UPDATE operation disallowed on virtual columns
ORA-06512: at line 5
/*
To be able to use record-based DML, therefore, we need to apply some "column subsetting" techniques (for example, create a view of the physical columns and use the view as the basis of the record and the insert). See the Miscellaneous section of this website for more workarounds and examples.

virtual columns and partitioning

We saw earlier that virtual columns can be used in key constraints. They can also be used as partition keys in partitioned tables. This also applies to subpartitioned tables (both the partition and subpartition keys can be based on virtual columns if we wish). We will demonstrate this with a simple partitioned table, using the data in ALL_OBJECTS as the basis of the partitioning. Note that the partitioning column, P1, is a virtual column based on two physical columns in the table.
*/
SQL> CREATE TABLE pt
  2  ( n1 INTEGER
  3  , c1 VARCHAR2(30)
  4  , c2 VARCHAR2(30)
  5  , d1 DATE NOT NULL
  6  , p1 VARCHAR2(61)
  7          GENERATED ALWAYS
  8          AS (c1 || '_' || CASE
  9                              WHEN c2 LIKE 'TABLE%'
 10                              THEN 'TABLE'
 11                              WHEN c2 LIKE 'INDEX%'
 12                              THEN 'INDEX'
 13                              WHEN c2 LIKE 'PACKAGE%'
 14                              OR   c2 LIKE 'TYPE%'
 15                              OR   c2 IN ('TRIGGER','PROCEDURE','FUNCTION')
 16                              THEN 'PLSQL'
 17                              ELSE 'OTHER'
 18                           END)
 19  )
 20  PARTITION BY LIST (p1)
 21  ( PARTITION p_scott_table VALUES ('SCOTT_TABLE')
 22  , PARTITION p_scott_index VALUES ('SCOTT_INDEX')
 23  , PARTITION p_scott_plsql VALUES ('SCOTT_PLSQL')
 24  , PARTITION p_scott_other VALUES ('SCOTT_OTHER')
 25  , PARTITION p_sh_table VALUES ('SH_TABLE')
 26  , PARTITION p_sh_index VALUES ('SH_INDEX')
 27  , PARTITION p_sh_plsql VALUES ('SH_PLSQL')
 28  , PARTITION p_sh_other VALUES ('SH_OTHER')
 29  );

Table created.
/*
We now have a list-partitioned table with eight partitions, using an expression based on the OWNER and OBJECT_TYPE data in ALL_OBJECTS (i.e. the P1 virtual column). We will load the physical columns of this table, as follows.
*/
SQL> INSERT INTO pt (n1, c1, c2, d1)
  2  SELECT object_id
  3  ,      owner
  4  ,      object_type
  5  ,      created
  6  FROM   all_objects
  7  WHERE  owner IN ('SCOTT','SH');

414 rows created.

--We can verify that the data loaded correctly with a simple query, as follows.

SQL> SELECT p1, COUNT(*)
  2  FROM   pt
  3  WHERE  c1 = 'SH'
  4  GROUP  BY
  5         p1;

P1             COUNT(*)
------------ ----------
SH_TABLE             74
SH_INDEX            223
SH_PLSQL              8
SH_OTHER             17

4 rows selected.

--Partition elimination also works as expected. In the following examples, we will gather statistics and explain a couple of typical partition-based queries. First we will gather statistics, as follows.

SQL> BEGIN
  2     DBMS_STATS.GATHER_TABLE_STATS(user,'PT');
  3  END;
  4  /

PL/SQL procedure successfully completed.

--We will use the EXPLAIN PLAN from Autotrace for simplicity. We will begin by explaining an equi-join on the partition key, as follows.

SQL> set autotrace traceonly explain

SQL> SELECT * FROM pt WHERE p1 = 'SH_INDEX';

Execution Plan
----------------------------------------------------------
Plan hash value: 2504868368

------------------------------------------------------- ... ------------------
| Id  | Operation             | Name | Rows  | Bytes |  ...  | Pstart| Pstop |
------------------------------------------------------- ... ------------------
|   0 | SELECT STATEMENT      |      |   223 |  8697 |  ...  |       |       |
|   1 |  PARTITION LIST SINGLE|      |   223 |  8697 |  ...  |   KEY |   KEY |
|   2 |   TABLE ACCESS FULL   | PT   |   223 |  8697 |  ...  |     6 |     6 |
------------------------------------------------------- ... ------------------

--Oracle has eliminated all partitions except the one that contains our target data, as expected. We will also explain a query that uses a LIKE expression against the partition key, as follows.

SQL> SELECT * FROM pt WHERE p1 LIKE 'SH%';

Execution Plan
----------------------------------------------------------
Plan hash value: 4163866522

--------------------------------------------------------- ... ------------------
| Id  | Operation               | Name | Rows  | Bytes |  ...  | Pstart| Pstop |
--------------------------------------------------------- ... ------------------
|   0 | SELECT STATEMENT        |      |    52 |  1976 |  ...  |       |       |
|   1 |  PARTITION LIST ITERATOR|      |    52 |  1976 |  ...  |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL     | PT   |    52 |  1976 |  ...  |   KEY |   KEY |
--------------------------------------------------------- ... ------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("P1" LIKE 'SH%')

   --Oracle correctly chooses a PARTITION LIST ITERATOR for the LIKE expression (note that this only works for LIKE expressions without a leading wildcard).
/*
virtual columns and dml error logging

Oracle 10.2 introduced DML error logging for bulk SQL inserts, updates, deletes and merges. This enables us to save any data that causes a bulk DML statement to fail to a separate logging table (we can even allow the parent statement to succeed based on an acceptable number of rejected records). Virtual columns are partly supported by DML error logging. In the following example, we will create a log table for our sample T table, load some "bad" data and view the log results. We will begin by creating the logging table, as follows.
*/
SQL> BEGIN
  2     DBMS_ERRLOG.CREATE_ERROR_LOG('T', 'T_ERR');
  3  END;
  4  /

PL/SQL procedure successfully completed.

--We will describe the T_ERR logging table to verify that our virtual columns are included, as follows.

SQL> DESC T_ERR
 Name                   Null?    Type
 ---------------------- -------- --------------------
 ORA_ERR_NUMBER$                 NUMBER
 ORA_ERR_MESG$                   VARCHAR2(2000)
 ORA_ERR_ROWID$                  ROWID
 ORA_ERR_OPTYP$                  VARCHAR2(2)
 ORA_ERR_TAG$                    VARCHAR2(2000)
 N1                              VARCHAR2(4000)
 N2                              VARCHAR2(4000)
 N3                              VARCHAR2(4000)
 N4                              VARCHAR2(4000)
 N5                              VARCHAR2(4000)
/*
 All of the data columns in logging tables are VARCHAR2(4000) to be able to store any unexpected data, and our virtual columns are present. We will now attempt to insert some "bad" data into T with error logging enabled and use Tom Kyte's print_table procedure to view the T_ERR logging table, as follows.
*/
SQL> INSERT INTO t (n1, n2) VALUES (1, 1) LOG ERRORS INTO t_err;
INSERT INTO t (n1, n2) VALUES (1, 1) LOG ERRORS INTO t_err
*
ERROR at line 1:
ORA-02290: check constraint (SCOTT.SYS_C0010001) violated

SQL> exec print_table('SELECT * FROM t_err');

ORA_ERR_NUMBER$               : 2290
ORA_ERR_MESG$                 : ORA-02290: check constraint (SCOTT.SYS_C0010001) violated
ORA_ERR_ROWID$                :
ORA_ERR_OPTYP$                : I
ORA_ERR_TAG$                  :
N1                            : 1
N2                            : 1
N3                            :
N4                            :
N5                            :
-----------------

PL/SQL procedure successfully completed.
/*
As we can see, the results of the virtual column expressions are not stored in the log table, even though we violated the check constraint on the N4 expression. When investigating error-logged data, therefore, we will need to reference the underlying table and its virtual column expressions to determine the cause of the exception.

virtual columns and the query result cache

The new query result cache can be used with the results of queries against virtual columns. Oracle makes no distinction between physical and virtual columns when storing results, as we will see below. We will query the T table using predicates against the indexed N3 virtual column and the unindexed N4 virtual column. In both cases, we will use the RESULT_CACHE hint to instruct Oracle to cache the results. We will begin with the N3 predicate, as follows.
*/
SQL> SELECT /*+ RESULT_CACHE */ * FROM t WHERE n3 = 30;

        N1         N2         N3         N4         N5
---------- ---------- ---------- ---------- ----------
        10         20         30        200         30

1 row selected.

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------
SQL_ID  fggr2uyqn7ck2, child number 0
-------------------------------------
SELECT /*+ RESULT_CACHE */ * FROM t WHERE n3 = 30

Plan hash value: 1303508680

--------------------------------------------------------------------------- ...
| Id  | Operation                    | Name                       | Rows  | ...
--------------------------------------------------------------------------- ...
|   0 | SELECT STATEMENT             |                            |       | ...
|   1 |  RESULT CACHE                | a4r7uu24qvrck56qvqv4vac32n |       | ...
|   2 |   TABLE ACCESS BY INDEX ROWID| T                          |     1 | ...
|*  3 |    INDEX UNIQUE SCAN         | T_PK                       |     1 | ...
--------------------------------------------------------------------------- ...

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("N3"=30)

Result Cache Information (identified by operation id):
------------------------------------------------------

   1 -


25 rows selected.
/*
Developers who are familiar with the new result cache mechanism will recognise this plan. It is telling us that Oracle cached the results of the query in the shared pool (where the result cache is stored) and gives us the name of the cache entry (for querying the relevant dynamic result cache views). We will repeat the example using the N4 virtual column below.
*/
SQL> SELECT /*+ RESULT_CACHE */ * FROM t WHERE n4 = 200;

        N1         N2         N3         N4         N5
---------- ---------- ---------- ---------- ----------
        10         20         30        200         30

1 row selected.

SQL> SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------
SQL_ID  823nn3zvrw2d6, child number 0
-------------------------------------
SELECT /*+ RESULT_CACHE */ * FROM t WHERE n4 = 200

Plan hash value: 1601196873

----------------------------------------------------------------- ...
| Id  | Operation          | Name                       | Rows  | ...
----------------------------------------------------------------- ...
|   0 | SELECT STATEMENT   |                            |       | ...
|   1 |  RESULT CACHE      | 7da9wa9105t0h19sm72aqrr7u9 |       | ...
|*  2 |   TABLE ACCESS FULL| T                          |     1 | ...
----------------------------------------------------------------- ...

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("N1"*"N2"=200)

Result Cache Information (identified by operation id):
------------------------------------------------------

   1 -


24 rows selected.
/*
The result cache is only interested in the results of a query, not how the results were originally accessed and computed. Therefore, the single result of a full scan of N4 is also cached and if we repeat the query, we should expect to generate zero I/O. We will test this using Autotrace, below.
*/
SQL> set autotrace traceonly statistics

SQL> SELECT /*+ RESULT_CACHE */ * FROM t WHERE n4 = 200;

1 row selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          0  consistent gets
          0  physical reads
          0  redo size
        632  bytes sent via SQL*Net to client
        416  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
		  /*
As predicted, Oracle has answered this query using the result cache, which has saved us a full scan of T.N4.

virtual column restrictions

There are several restrictions on virtual columns and several related new error messages and exceptions. To complete this article, the following restrictions from the online documentation are included:

You can create virtual columns only in relational heap tables. Virtual columns are not supported for index-organized, external, object, cluster, or temporary tables.
The column_expr in the AS clause has the following restrictions:
It cannot refer to another virtual column by name.
Any columns referenced in column_expr must be defined on the same table.
It can refer to a deterministic user-defined function, but if it does, then you cannot use the virtual column as a partitioning key column.
The output of column_expr must be a scalar value.
The virtual column cannot be an Oracle supplied datatype, a user-defined type, or LOB or LONG RAW.
further reading

For more information on virtual column syntax and usage, see the SQL Reference. For information on DML error logging or the new query result cache, see the 10g and 11g sections of oracle-developer.net, respectively.
*/