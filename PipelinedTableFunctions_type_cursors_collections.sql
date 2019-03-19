Pipelined Table Functions

Table Functions
Pipelined Table Functions
NO_DATA_NEEDED Exception
Memory Usage Comparison
Cardinality
Implicit (Shadow) Types
Parallel Enabled Pipelined Table Functions
Transformation Pipelines
Related articles.

Pipelined Table Functions 
Table Functions
Table functions are used to return PL/SQL collections that mimic tables. They can be queried like a regular table by using the TABLE operator in the FROM clause. Regular table functions require collections to be fully populated before they are returned. Since collections are held in memory, this can be a problem as large collections can waste a lot of memory and take a long time to return the first row. These potential bottlenecks make regular table functions unsuitable for large Extraction Transformation Load (ETL) operations. Regular table functions require named row and table types to be created as database objects.

-- Create the types to support the table function.
DROP TYPE t_tf_tab;
DROP TYPE t_tf_row;

CREATE TYPE t_tf_row AS OBJECT (
  id           NUMBER,
  description  VARCHAR2(50)
);
/

CREATE TYPE t_tf_tab IS TABLE OF t_tf_row;
/

-- Build the table function itself.
CREATE OR REPLACE FUNCTION get_tab_tf (p_rows IN NUMBER) RETURN t_tf_tab AS
  l_tab  t_tf_tab := t_tf_tab();
BEGIN
  FOR i IN 1 .. p_rows LOOP
    l_tab.extend;
    l_tab(l_tab.last) := t_tf_row(i, 'Description for ' || i);
  END LOOP;

  RETURN l_tab;
END;
/

-- Test it.
SELECT *
FROM   TABLE(get_tab_tf(10))
ORDER BY id DESC;

        ID DESCRIPTION
---------- --------------------------------------------------
        10 Description for 10
         9 Description for 9
         8 Description for 8
         7 Description for 7
         6 Description for 6
         5 Description for 5
         4 Description for 4
         3 Description for 3
         2 Description for 2
         1 Description for 1

10 rows selected.

SQL>
Notice the above output is in reverse order because the query includes a descending order by clause.

If you are using 12.2 or above you can use the table function without the TABLE operator.

SELECT *
FROM   get_tab_tf(10)
ORDER BY id DESC;

        ID DESCRIPTION
---------- --------------------------------------------------
        10 Description for 10
         9 Description for 9
         8 Description for 8
         7 Description for 7
         6 Description for 6
         5 Description for 5
         4 Description for 4
         3 Description for 3
         2 Description for 2
         1 Description for 1

10 rows selected.

SQL>
Pipelined Table Functions
Pipelining negates the need to build huge collections by piping rows out of the function as they are created, saving memory and allowing subsequent processing to start before all the rows are generated.

Pipelined table functions include the PIPELINED clause and use the PIPE ROW call to push rows out of the function as soon as they are created, rather than building up a table collection. Notice the empty RETURN call, since there is no collection to return from the function.

-- Build a pipelined table function.
CREATE OR REPLACE FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_tf_tab PIPELINED AS
BEGIN
  FOR i IN 1 .. p_rows LOOP
    PIPE ROW(t_tf_row(i, 'Description for ' || i));   
  END LOOP;

  RETURN;
END;
/

-- Test it.
SELECT *
FROM   TABLE(get_tab_ptf(10))
ORDER BY id DESC;

        ID DESCRIPTION
---------- --------------------------------------------------
        10 Description for 10
         9 Description for 9
         8 Description for 8
         7 Description for 7
         6 Description for 6
         5 Description for 5
         4 Description for 4
         3 Description for 3
         2 Description for 2
         1 Description for 1

10 rows selected.

SQL>
If you are using 12.2 or above you can use the pipelined table function without the TABLE operator.

SELECT *
FROM   get_tab_ptf(10)
ORDER BY id DESC;

        ID DESCRIPTION
---------- --------------------------------------------------
        10 Description for 10
         9 Description for 9
         8 Description for 8
         7 Description for 7
         6 Description for 6
         5 Description for 5
         4 Description for 4
         3 Description for 3
         2 Description for 2
         1 Description for 1

10 rows selected.

SQL>
Once you start working with large warehousing ETL operations the performance improvements can be massive, allowing data loads from external tables via table functions directly into the warehouse tables, rather than loading via a staging area.

NO_DATA_NEEDED Exception
A pipelined table function may create more data than is needed by the process querying it. When this happens, the pipelined table function execution stops, raising the NO_DATA_NEEDED exception. This doesn't need to be explicitly handled provided you do not include an OTHERS exception handler.

The function below returns 10 rows, but the query against it only ask for the first 5 rows, so the function stops processing by raising the NO_DATA_NEEDED exception.

-- Build a pipelined table function.
CREATE OR REPLACE FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_tf_tab PIPELINED AS
BEGIN
  FOR i IN 1 .. p_rows LOOP
    DBMS_OUTPUT.put_line('Row: ' || i);
    PIPE ROW(t_tf_row(i, 'Description for ' || i));
  END LOOP;

  RETURN;
END;
/

-- Test it.
SET SERVEROUTPUT ON

SELECT *
FROM   TABLE(get_tab_ptf(10))
WHERE  rownum <= 5;

        ID DESCRIPTION
---------- --------------------------------------------------
         1 Description for 1
         2 Description for 2
         3 Description for 3
         4 Description for 4
         5 Description for 5

5 rows selected.

Row: 1
Row: 2
Row: 3
Row: 4
Row: 5
SQL>
If you include an OTHERS exception handler, this will capture the NO_DATA_NEEDED exception and potentially run some error handling code it shouldn't.

-- Build a pipelined table function.
CREATE OR REPLACE FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_tf_tab PIPELINED AS
BEGIN
  FOR i IN 1 .. p_rows LOOP
    DBMS_OUTPUT.put_line('Row: ' || i);
    PIPE ROW(t_tf_row(i, 'Description for ' || i));
  END LOOP;

  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('OTHERS Handler');
    RAISE;
END;
/

-- Test it.
SET SERVEROUTPUT ON

SELECT *
FROM   TABLE(get_tab_ptf(10))
WHERE  rownum <= 5;

        ID DESCRIPTION
---------- --------------------------------------------------
         1 Description for 1
         2 Description for 2
         3 Description for 3
         4 Description for 4
         5 Description for 5

5 rows selected.

Row: 1
Row: 2
Row: 3
Row: 4
Row: 5
OTHERS Handler
SQL>
If you plan to use an OTHERS exception handler, you must include a specific trap for the NO_DATA_NEEDED exception.

-- Build a pipelined table function.
CREATE OR REPLACE FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_tf_tab PIPELINED AS
BEGIN
  FOR i IN 1 .. p_rows LOOP
    DBMS_OUTPUT.put_line('Row: ' || i);
    PIPE ROW(t_tf_row(i, 'Description for ' || i));
  END LOOP;

  RETURN;
EXCEPTION
  WHEN NO_DATA_NEEDED THEN
    RAISE;
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('OTHERS Handler');
    RAISE;
END;
/

-- Test it.
SET SERVEROUTPUT ON

SELECT *
FROM   TABLE(get_tab_ptf(10))
WHERE  rownum <= 5;

        ID DESCRIPTION
---------- --------------------------------------------------
         1 Description for 1
         2 Description for 2
         3 Description for 3
         4 Description for 4
         5 Description for 5

5 rows selected.

Row: 1
Row: 2
Row: 3
Row: 4
Row: 5
SQL>
The NO_DATA_NEEDED can also be used to perform cleanup operations.

CREATE OR REPLACE FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_tf_tab PIPELINED AS
BEGIN
  my_package.initialize;

  FOR i IN 1 .. p_rows LOOP
    PIPE ROW(t_tf_row(i, 'Description for ' || i));
  END LOOP;

  RETURN;
EXCEPTION
  WHEN NO_DATA_NEEDED THEN
    my_package.cleanup;
    RAISE;
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('OTHERS Handler');
    RAISE;
END;
/
Memory Usage Comparison
The following function returns the current value for a specified statistic. It will allow us to compare the memory used by regular and pipelined table functions.

CREATE OR REPLACE FUNCTION get_stat (p_stat IN VARCHAR2) RETURN NUMBER AS
  l_return  NUMBER;
BEGIN
  SELECT ms.value
  INTO   l_return
  FROM   v$mystat ms,
         v$statname sn
  WHERE  ms.statistic# = sn.statistic#
  AND    sn.name = p_stat;
  RETURN l_return;
END get_stat;
/
First we test the regular table function by creating a new connection and querying a large collection. Checking the PGA memory allocation before and after the test allows us to see how much memory was allocated as a result of the test.

-- Create a new session.
CONN test/test

-- Test table function.
SET SERVEROUTPUT ON
DECLARE
  l_start  NUMBER;
BEGIN
  l_start := get_stat('session pga memory');

  FOR cur_rec IN (SELECT *
                  FROM   TABLE(get_tab_tf(100000)))
  LOOP
    NULL;
  END LOOP;

  DBMS_OUTPUT.put_line('Regular table function : ' ||
                        (get_stat('session pga memory') - l_start));
END;
/
Regular table function : 22872064

PL/SQL procedure successfully completed.

SQL>
Next, we repeat the test for the pipelined table function.

-- Create a new session.
CONN test/test

-- Test pipelined table function.
SET SERVEROUTPUT ON
DECLARE
  l_start  NUMBER;
BEGIN
  l_start := get_stat('session pga memory');

  FOR cur_rec IN (SELECT *
                  FROM   TABLE(get_tab_ptf(100000)))
  LOOP
    NULL;
  END LOOP;

  DBMS_OUTPUT.put_line('Pipelined table function : ' ||
                        (get_stat('session pga memory') - l_start));
END;
/
Pipelined table function : 65536

PL/SQL procedure successfully completed.

SQL>
The reduction in memory used by the pipelined table function is due to it never having to resolve the whole collection in memory.

Cardinality
Oracle estimates the cardinality of a pipelined table function based on the database block size. When using the default block size, the optimizer will always assume the cardinality is 8168 rows.

SET AUTOTRACE TRACE EXPLAIN

-- Return 10 rows.
SELECT *
FROM   TABLE(get_tab_ptf(10));

Execution Plan
----------------------------------------------------------
Plan hash value: 822655197

-------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |             |  8168 | 16336 |     8   (0)| 00:02:19 |
|   1 |  COLLECTION ITERATOR PICKLER FETCH| GET_TAB_PTF |  8168 | 16336 |     8   (0)| 00:02:19 |
-------------------------------------------------------------------------------------------------

SET AUTOTRACE OFF
This is fine if you are just querying the pipelined table function, but if you plan to use it in a join it can adversely affect the execution plan.

There are 4 ways to correct the cardinality estimate for pipelined table functions:

CARDINALITY hint (9i+): Undocumented
OPT_ESTIMATE hint (10g+): Undocumented
DYNAMIC_SAMPLING hint (11gR1+): Causes a full scan of the pipelined table function to estimate the cardinality before running it in the query itself. This is very wasteful.
Extensible Optimizer (9i+): The extensible optimizer feature allows us to tell the optimizer what the cardinality should be in a supported manner.
Cardinality Feedback: In 11gR2 the optimizer notices if the actual cardinality from a query against a table function differs from the expected cardinality. Subsequent queries will have their cardinality adjusted based on this feedback. If the statement is aged out of the shared pool, or the instance is restarted, the cardinality feedback is lost. In 12c, cardinality feedback is persisted in the SYSAUX tablespace.
To use the extensible optimizer we need to add a parameter to the pipelined table functions, which will be used to manually tell the optimizer what cardinalty to use.

CREATE OR REPLACE FUNCTION get_tab_ptf (p_cardinality IN INTEGER DEFAULT 1)
  RETURN t_tf_tab PIPELINED AS
BEGIN
  FOR i IN 1 .. 10 LOOP
    PIPE ROW (t_tf_row(i, 'Description for ' || i));
  END LOOP;

  RETURN;
END;
/
Notice the p_cardinality parameter isn't used anywhere in the function itself.

Next, we build a type and type body to set the cardinality manually. Notice the reference to the p_cardinality parameter in the type.

CREATE OR REPLACE TYPE t_ptf_stats AS OBJECT (
  dummy INTEGER,
  
  STATIC FUNCTION ODCIGetInterfaces (
    p_interfaces OUT SYS.ODCIObjectList
  ) RETURN NUMBER,

  STATIC FUNCTION ODCIStatsTableFunction (
    p_function    IN  SYS.ODCIFuncInfo,
    p_stats       OUT SYS.ODCITabFuncStats,
    p_args        IN  SYS.ODCIArgDescList,
    p_cardinality IN INTEGER
  ) RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY t_ptf_stats AS
  STATIC FUNCTION ODCIGetInterfaces (
    p_interfaces OUT SYS.ODCIObjectList
  ) RETURN NUMBER IS
  BEGIN
    p_interfaces := SYS.ODCIObjectList(
                      SYS.ODCIObject ('SYS', 'ODCISTATS2')
                    );
    RETURN ODCIConst.success;
  END ODCIGetInterfaces;

  STATIC FUNCTION ODCIStatsTableFunction (
                    p_function    IN  SYS.ODCIFuncInfo,
                    p_stats       OUT SYS.ODCITabFuncStats,
                    p_args        IN  SYS.ODCIArgDescList,
                    p_cardinality IN INTEGER
                  ) RETURN NUMBER IS
  BEGIN
    p_stats := SYS.ODCITabFuncStats(NULL);
    p_stats.num_rows := p_cardinality;
    RETURN ODCIConst.success;
  END ODCIStatsTableFunction;
END;
/
This type can be associated with any pipelined table function using the following command.

ASSOCIATE STATISTICS WITH FUNCTIONS get_tab_ptf USING t_ptf_stats;
We know the function returns 10 rows, but the optimizer doesn't. Regardless of the number of rows returned by the function, the optimizer uses the value of the p_cardinality parameter as the cardinality estimate.

SET AUTOTRACE TRACE EXPLAIN

SELECT *
FROM   TABLE(get_tab_ptf(p_cardinality => 10));

Execution Plan
----------------------------------------------------------
Plan hash value: 822655197

-------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |             |    10 |    20 |     8   (0)| 00:02:19 |
|   1 |  COLLECTION ITERATOR PICKLER FETCH| GET_TAB_PTF |    10 |    20 |     8   (0)| 00:02:19 |
-------------------------------------------------------------------------------------------------

SELECT *
FROM   TABLE(get_tab_ptf(p_cardinality => 10000));

Execution Plan
----------------------------------------------------------
Plan hash value: 822655197

-------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |             | 10000 | 20000 |     8   (0)| 00:02:19 |
|   1 |  COLLECTION ITERATOR PICKLER FETCH| GET_TAB_PTF | 10000 | 20000 |     8   (0)| 00:02:19 |
-------------------------------------------------------------------------------------------------

SET AUTOTRACE OFF
Implicit (Shadow) Types
Unlike regular table functions, pipelined table functions can be defined using record and table types defined in a package specification.

-- Drop the previously created objects.
DROP FUNCTION get_tab_tf;
DROP FUNCTION get_tab_ptf;
DROP TYPE t_tf_tab;
DROP TYPE t_tf_row;

-- Build package containing record and table types internally.
CREATE OR REPLACE PACKAGE ptf_api AS
  TYPE t_ptf_row IS RECORD (
    id           NUMBER,
    description  VARCHAR2(50)
  );

  TYPE t_ptf_tab IS TABLE OF t_ptf_row;

  FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_ptf_tab PIPELINED;
END;
/

CREATE OR REPLACE PACKAGE BODY ptf_api AS

  FUNCTION get_tab_ptf (p_rows IN NUMBER) RETURN t_ptf_tab PIPELINED IS
    l_row  t_ptf_row;
  BEGIN
    FOR i IN 1 .. p_rows LOOP
      l_row.id := i;
      l_row.description := 'Description for ' || i;
      PIPE ROW (l_row);
    END LOOP;
  
    RETURN;
  END;
END;
/

SELECT *
FROM   TABLE(ptf_api.get_tab_ptf(10))
ORDER BY id DESC;

        ID DESCRIPTION
---------- --------------------------------------------------
        10 Description for 10
         9 Description for 9
         8 Description for 8
         7 Description for 7
         6 Description for 6
         5 Description for 5
         4 Description for 4
         3 Description for 3
         2 Description for 2
         1 Description for 1

10 rows selected.

SQL>
This seems like a better solution than having to build all the database types manually, but behind the scenes Oracle is building the shadow object types implicitly.

COLUMN object_name FORMAT A30

SELECT object_name, object_type
FROM   user_objects;

OBJECT_NAME                    OBJECT_TYPE
------------------------------ -------------------
PTF_API                        PACKAGE BODY
SYS_PLSQL_82554_9_1            TYPE
SYS_PLSQL_82554_DUMMY_1        TYPE
SYS_PLSQL_82554_24_1           TYPE
PTF_API                        PACKAGE

5 rows selected.

SQL>
As you can see, Oracle has actually created three shadow object types with system generated names to support the types required by the pipelined table function. For this reason I always build named database object types, rather than relying on the implicit types.

Parallel Enabled Pipelined Table Functions
To parallel enable a pipelined table function the following conditions must be met.

The PARALLEL_ENABLE clause must be included.
It must have one or more REF CURSOR input parameters.
It must have a PARTITION BY clause to define a partitioning method for the workload. Weakly typed ref cursors can only use the PARTITION BY ANY clause, which randomly partitions the workload.
The basic syntax is shown below.

CREATE FUNCTION function-name(parameter-name ref-cursor-type)
  RETURN rec_tab_type PIPELINED
  PARALLEL_ENABLE(PARTITION parameter-name BY [{HASH | RANGE} (column-list) | ANY ]) IS
BEGIN
  ...
END;
To see it in action, first we must create and populate a test table.

CREATE TABLE parallel_test (
  id           NUMBER(10),
  country_code VARCHAR2(5),
  description  VARCHAR2(50)
);

INSERT /*+ APPEND */ INTO parallel_test
SELECT level AS id,
       (CASE TRUNC(MOD(level, 4))
         WHEN 1 THEN 'IN'
         WHEN 2 THEN 'UK'
         ELSE 'US'
        END) AS country_code,
       'Description or ' || level AS description
FROM   dual
CONNECT BY level <= 100000;
COMMIT;

-- Check data.
SELECT country_code, count(*) FROM parallel_test GROUP BY country_code;

COUNT   COUNT(*)
----- ----------
US         50000
IN         25000
UK         25000

3 rows selected.

SQL>
The following package defines parallel enabled pipelined table functions that accept ref cursors based on a query from the test table and return the same rows, along with the SID of the session that processed them. We could use a weakly typed ref cursor, like SYS_REFCURSOR, but this would restrict us to only the ANY partitioning type. The three functions represent the three partitioning methods.

CREATE OR REPLACE PACKAGE parallel_ptf_api AS

  TYPE t_parallel_test_row IS RECORD (
    id             NUMBER(10),
    country_code   VARCHAR2(5),
    description    VARCHAR2(50),
    sid            NUMBER
  );

  TYPE t_parallel_test_tab IS TABLE OF t_parallel_test_row;

  TYPE t_parallel_test_ref_cursor IS REF CURSOR RETURN parallel_test%ROWTYPE;
  
  FUNCTION test_ptf_any (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY);
    
  FUNCTION test_ptf_hash (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (country_code));
    
  FUNCTION test_ptf_range (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY RANGE (country_code));
    
END parallel_ptf_api;
/

CREATE OR REPLACE PACKAGE BODY parallel_ptf_api AS

  FUNCTION test_ptf_any (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY)
  IS
    l_row  t_parallel_test_row;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.id,
            l_row.country_code,
            l_row.description;
      EXIT WHEN p_cursor%NOTFOUND;
      
      SELECT sid
      INTO   l_row.sid
      FROM   v$mystat
      WHERE  rownum = 1;
      
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END test_ptf_any;

  FUNCTION test_ptf_hash (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (country_code))
  IS
    l_row  t_parallel_test_row;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.id,
            l_row.country_code,
            l_row.description;
      EXIT WHEN p_cursor%NOTFOUND;
      
      SELECT sid
      INTO   l_row.sid
      FROM   v$mystat
      WHERE  rownum = 1;
      
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END test_ptf_hash;

  FUNCTION test_ptf_range (p_cursor  IN  t_parallel_test_ref_cursor)
    RETURN t_parallel_test_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY RANGE (country_code))
  IS
    l_row  t_parallel_test_row;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.id,
            l_row.country_code,
            l_row.description;
      EXIT WHEN p_cursor%NOTFOUND;
      
      SELECT sid
      INTO   l_row.sid
      FROM   v$mystat
      WHERE  rownum = 1;
      
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END test_ptf_range;
      
END parallel_ptf_api;
/
The following query uses the CURSOR expression to convert a query against the test table into a ref cursor that is past to the table function as a parameter. The results are grouped by the SID of the session that processed the row. Notice all the rows were processed by the same session. Why? Because although the function is parallel enabled, we didn't tell it to run in parallel.

SELECT sid, count(*)
FROM   TABLE(parallel_ptf_api.test_ptf_any(CURSOR(SELECT * FROM parallel_test t1))) t2
GROUP BY sid;

       SID   COUNT(*)
---------- ----------
        31     100000

1 row selected.

SQL>
The following queries include a parallel hint and call each of the functions.

SELECT country_code, sid, count(*)
FROM   TABLE(parallel_ptf_api.test_ptf_any(CURSOR(SELECT /*+ parallel(t1, 5) */ * FROM   parallel_test t1))) t2
GROUP BY country_code,sid
ORDER BY country_code,sid;

COUNT        SID   COUNT(*)
----- ---------- ----------
IN            23       4906
IN            26       5219
IN            41       4847
IN            42       4827
IN            43       5201
UK            23       4906
UK            26       5218
UK            41       4848
UK            42       4826
UK            43       5202
US            23       9811
US            26      10437
US            41       9695
US            42       9655
US            43      10402

15 rows selected.

SQL>

SELECT country_code, sid, count(*)
FROM   TABLE(parallel_ptf_api.test_ptf_hash(CURSOR(SELECT /*+ parallel(t1, 5) */ * FROM   parallel_test t1))) t2
GROUP BY country_code,sid
ORDER BY country_code,sid;

COUNT        SID   COUNT(*)
----- ---------- ----------
IN            29      25000
UK            38      25000
US            40      50000

3 rows selected.

SQL>

SELECT country_code, sid, count(*)
FROM   TABLE(parallel_ptf_api.test_ptf_range(CURSOR(SELECT /*+ parallel(t1, 5) */ * FROM   parallel_test t1))) t2
GROUP BY country_code,sid
ORDER BY country_code,sid;

COUNT        SID   COUNT(*)
----- ---------- ----------
IN            40      25000
UK            23      25000
US            41      50000

3 rows selected.

SQL>
The degree of parallelism (DOP) may be lower than that requested in the hint.

An optional streaming clause can be used to order or cluster the data inside the server process based on a column list. This may be necessary if data has dependencies, for example you wish to partition by a specific column, but also want the rows processed in a specific order within that partition. The extended syntax is shown below.

CREATE FUNCTION function-name(parameter-name ref-cursor-type)
  RETURN rec_tab_type PIPELINED
  PARALLEL_ENABLE(PARTITION parameter-name BY [{HASH | RANGE} (column-list) | ANY ]) 
  [ORDER | CLUSTER] parameter-name BY (column-list) IS
BEGIN
  ...
END;
You may wish to do something like the following for example.

FUNCTION test_ptf_hash (p_cursor  IN  t_parallel_test_ref_cursor)
  RETURN t_parallel_test_tab PIPELINED
  PARALLEL_ENABLE(PARTITION p_cursor BY HASH (country_code))
  ORDER p_cursor BY (country_code, created_date);

FUNCTION test_ptf_hash (p_cursor  IN  t_parallel_test_ref_cursor)
  RETURN t_parallel_test_tab PIPELINED
  PARALLEL_ENABLE(PARTITION p_cursor BY HASH (country_code))
  CLUSTER p_cursor BY (country_code, created_date);
Transformation Pipelines
In traditional Extract Transform Load (ETL) processes you may be required to load data into a staging area, then make several passes over it to transform it into a state where it can be loaded into your destination schema. Passing the data through staging tables can represent a significant amount of disk I/O for both the data and the redo generated. An alternative is to perform the transformations in pipelined table functions so data can be read from an external table and inserted directly into the destination table, removing much of the disk I/O.

In this section we will see and example of this using the techniques discussed previously to build a transformation pipeline.

First, generate some test data as a flat file by spooling it out to the database server's file system.

SET PAGESIZE 0
SET FEEDBACK OFF
SET LINESIZE 1000
SET TRIMSPOOL ON
SPOOL /tmp/tp_test.txt
SELECT owner || ',' || object_name || ',' || object_type || ',' || status
FROM   all_objects;
SPOOL OFF
SET FEEDBACK ON
SET PAGESIZE 24
Create a directory object pointing to the location of the file, create an external table to read the file and create a destination table.

-- Create a directory object pointing to the flat file.
CONN / AS SYSDBA
CREATE OR REPLACE DIRECTORY data_load_dir AS '/tmp/';
GRANT READ, WRITE ON DIRECTORY data_load_dir TO test;

CONN test/test
-- Create an external table.
DROP TABLE tp_test_ext;
CREATE TABLE tp_test_ext (
  owner                    VARCHAR2(30),
  object_name              VARCHAR2(30),
  object_type              VARCHAR2(19),
  status                   VARCHAR2(7)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY data_load_dir
  ACCESS PARAMETERS
  (
    RECORDS DELIMITED BY NEWLINE
    BADFILE data_load_dir:'tp_test_%a_%p.bad'
    LOGFILE data_load_dir:'tp_test_%a_%p.log'
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
    (
      owner                    CHAR(30),
      object_name              CHAR(30),
      object_type              CHAR(19),
      status                   CHAR(7)
    )
  )
  LOCATION ('tp_test.txt')
)
PARALLEL 10
REJECT LIMIT UNLIMITED
/

-- Create a table as the final destination for the data.
CREATE TABLE tp_test (
  owner                    VARCHAR2(30),
  object_name              VARCHAR2(30),
  object_type              VARCHAR2(19),
  status                   VARCHAR2(7),
  extra_1                  NUMBER,
  extra_2                  NUMBER
);
Notice the destination table has two extra columns compared to the external table. Each of these columns represents a transformation step. The actual transformations in this example are trivial, but imagine they were so complex they could not be done in SQL alone, hence the need for the table functions.

The package below defines the two steps of the transformation process and a procedure to initiate it.

CREATE OR REPLACE PACKAGE tp_api AS

  TYPE t_step_1_in_rc IS REF CURSOR RETURN tp_test_ext%ROWTYPE;
  
  TYPE t_step_1_out_row IS RECORD (
    owner                    VARCHAR2(30),
    object_name              VARCHAR2(30),
    object_type              VARCHAR2(19),
    status                   VARCHAR2(7),
    extra_1                  NUMBER
  );
  
  TYPE t_step_1_out_tab IS TABLE OF t_step_1_out_row;

  TYPE t_step_2_in_rc IS REF CURSOR RETURN t_step_1_out_row;

  TYPE t_step_2_out_tab IS TABLE OF tp_test%ROWTYPE;

  FUNCTION step_1 (p_cursor  IN  t_step_1_in_rc)
    RETURN t_step_1_out_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY);

  FUNCTION step_2 (p_cursor  IN  t_step_2_in_rc)
    RETURN t_step_2_out_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY);

  PROCEDURE load_data;

END tp_api;
/


CREATE OR REPLACE PACKAGE BODY tp_api AS

  FUNCTION step_1 (p_cursor  IN  t_step_1_in_rc)
    RETURN t_step_1_out_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY)
  IS
    l_row  t_step_1_out_row;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.owner,
            l_row.object_name,
            l_row.object_type,
            l_row.status;
      EXIT WHEN p_cursor%NOTFOUND;
      
      -- Do some work here.
      l_row.extra_1 := p_cursor%ROWCOUNT;
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END step_1;


  FUNCTION step_2 (p_cursor  IN  t_step_2_in_rc)
    RETURN t_step_2_out_tab PIPELINED
    PARALLEL_ENABLE(PARTITION p_cursor BY ANY)
  IS
    l_row  tp_test%ROWTYPE;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.owner,
            l_row.object_name,
            l_row.object_type,
            l_row.status,
            l_row.extra_1;
      EXIT WHEN p_cursor%NOTFOUND;
      
      -- Do some work here.
      l_row.extra_2 := p_cursor%ROWCOUNT;
      PIPE ROW (l_row);
    END LOOP;
    RETURN;
  END step_2;


  PROCEDURE load_data IS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE tp_test';
    
    INSERT /*+ APPEND PARALLEL(t4, 5) */ INTO tp_test t4
    SELECT /*+ PARALLEL(t3, 5) */ *
    FROM   TABLE(step_2(CURSOR(SELECT /*+ PARALLEL(t2, 5) */ *
                               FROM   TABLE(step_1(CURSOR(SELECT /*+ PARALLEL(t1, 5) */ *
                                                          FROM   tp_test_ext t1
                                                          )
                                                   )
                                            ) t2
                               )
                        )
                 ) t3;
    COMMIT;
  END load_data;

END tp_api;
/
The insert inside the LOAD_DATA procedure represents the whole data load including the transformations. The statement looks quite complicated, but it is made up of the following simple steps.

The rows are queried from the external table.
These are converted into the ref cursor using the CURSOR function.
This ref cursor is passed to the first stage of the transformation (STEP_1).
The return collection from STEP_1 is queried using the TABLE function.
The output of this query is converted to a ref cursor using the CURSOR function.
This ref cursor is passed to the second stage of the transformation (STEP_2).
The return collection from STEP_2 is queried using the TABLE function.
This query is used to drive the insert into the destination table.
By calling the LOAD_DATA procedure we can transform and load the data.

EXEC tp_api.load_data;

PL/SQL procedure successfully completed.

SQL>

-- Check the rows in the external table.
SELECT COUNT(*) FROM tp_test_ext;

  COUNT(*)
----------
     56059

1 row selected.

SQL> 

-- Compare to the destination table.
SELECT COUNT(*) FROM tp_test;

  COUNT(*)
----------
     56059

1 row selected.

SQL>
Notice, the example contains no error handling and the parallel hints have been removed to simplify the query in the LOAD_DATA procedure.

For more information see:

Pipelined Table Functions 
Accepting and Returning Multiple Rows with Table Functions (9i)
Chaining Pipelined Table Functions for Multiple Transformations (11gR2)
Hope this helps. Regards Tim...

Back to the Top.

 

11 comments, read/add them...

    
Home | Articles | Scripts | Blog | Certification | Misc | About

About Tim Hall
Copyright & Disclaimer
Privacy Policy
Validate
This site uses cookies.
Some of these cookies are essential, while others help us to improve your experience by providing insights into how the site is being used.

For more detailed information on the cookies we use, please check our Privacy Policy

Accept Recommended Settings
Necessary Cookies
Necessary cookies enable core functionality. The website cannot function properly without these cookies, and can only be disabled by changing your browser preferences.

Analytical Cookies
On
Off
Analytical cookies help us to improve our website by collecting and reporting information on its usage.

About this tool 