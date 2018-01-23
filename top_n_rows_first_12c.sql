Row Limiting Clause for Top-N Queries in Oracle Database 12c Release 1 (12.1)

A Top-N query is used to retrieve the top or bottom N rows from an ordered set. Combining two Top-N queries gives you the ability to page through an ordered set. T
his concept is not a new one. In fact, Oracle already provides multiple ways to perform Top-N queries, as discussed here. 
These methods work fine, but they look rather complicated compared to the methods provided by other database engines. 
For example, MySQL uses a LIMIT clause to page through an ordered result set.

SELECT * 
FROM   my_table 
ORDER BY column_1
LIMIT 0 , 40

Oracle 12c has introduced the row limiting clause to simplify Top-N queries and paging through ordered result sets.

Setup

To be consistent, we will use the same example table used in the Top-N Queries article.

Create and populate a test table.

DROP TABLE rownum_order_test;

CREATE TABLE rownum_order_test (
  val  NUMBER
);

INSERT ALL
  INTO rownum_order_test
  INTO rownum_order_test
SELECT level
FROM   dual
CONNECT BY level <= 10;

COMMIT;
The following query shows we have 20 rows with 10 distinct values.

SELECT val
FROM   rownum_order_test
ORDER BY val;

       VAL
----------
         1
         1
         2
         2
         3
         3
         4
         4
         5
         5
         6

       VAL
----------
         6
         7
         7
         8
         8
         9
         9
        10
        10

20 rows selected.

SQL>
Top-N Queries

The syntax for the row limiting clause looks a little complicated at first glance.

[ OFFSET offset { ROW | ROWS } ]
[ FETCH { FIRST | NEXT } [ { rowcount | percent PERCENT } ]
    { ROW | ROWS } { ONLY | WITH TIES } ]
Actually, for the classic Top-N query it is very simple. The example below returns the 5 largest values from an ordered set. Using the ONLY clause limits the number of rows returned to the exact number requested.

SELECT val
FROM   rownum_order_test
ORDER BY val DESC
FETCH FIRST 5 ROWS ONLY;

       VAL
----------
        10
        10
         9
         9
         8

5 rows selected.

SQL>
Using the WITH TIES clause may result in more rows being returned if multiple rows match the value of the Nth row. In this case the 5th row has the value "8", but there are two rows that tie for 5th place, so both are returned.

SELECT val
FROM   rownum_order_test
ORDER BY val DESC
FETCH FIRST 5 ROWS WITH TIES;

       VAL
----------
        10
        10
         9
         9
         8
         8

6 rows selected.

SQL>
In addition to limiting by row count, the row limiting clause also allows us to limit by percentage of rows. The following query returns the bottom 20% of rows.

SELECT val
FROM   rownum_order_test
ORDER BY val
FETCH FIRST 20 PERCENT ROWS ONLY;

       VAL
----------
         1
         1
         2
         2

4 rows selected.

SQL>
Paging Through Data

Paging through an ordered resultset was a little annoying using the classic Top-N query approach, as it required two Top-N queries, one nested inside the other. For example, if we wanted the second block of 4 rows we might do the following.

SELECT val
FROM   (SELECT val, rownum AS rnum
        FROM   (SELECT val
                FROM   rownum_order_test
                ORDER BY val)
        WHERE rownum <= 8)
WHERE  rnum >= 5;

       VAL
----------
         3
         3
         4
         4

4 rows selected.

SQL>
With the row limiting clause we can achieve the same result using the following query.

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 4 ROWS ONLY;

       VAL
----------
         3
         3
         4
         4

4 rows selected.

SQL>
The starting point for the FETCH is OFFSET+1.

The OFFSET is always based on a number of rows, but this can be combined with a FETCH using a PERCENT.

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 20 PERCENT ROWS ONLY;

       VAL
----------
         3
         3
         4
         4

4 rows selected.

SQL>
Not surprisingly, the offset, rowcount and percent can, and probably should, be bind variables.

VARIABLE v_offset NUMBER;
VARIABLE v_next NUMBER;

BEGIN
  :v_offset := 4;
  :v_next   := 4;
END;
/

SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET :v_offset ROWS FETCH NEXT :v_next ROWS ONLY;

       VAL
----------
         3
         3
         4
         4

SQL>
Extra Information

The keywords ROW and ROWS can be used interchangeably, as can the FIRST and NEXT keywords. Pick the ones that scan best when reading the SQL like a sentence.
If the offset is not specified it is assumed to be 0.
Negative values for the offset, rowcount or percent are treated as 0.
Null values for offset, rowcount or percent result in no rows being returned.
Fractional portions of offset, rowcount or percent are truncated.
If the offset is greater than or equal to the total number of rows in the set, no rows are returned.
If the rowcount or percent are greater than the total number of rows after the offset, all rows are returned.
The row limiting clause can not be used with the FOR UPDATE clause, CURRVAL and NEXTVAL sequence pseudocolumns or in an fast refresh materialized view.
Query Transformation

--It's worth keeping in mind this new functionality is a query transformation. If we take one of the previous queries and perform a 10053 trace we can see this.

Check the trace file for the session.

SELECT value FROM v$diag_info WHERE  name = 'Default Trace File';

VALUE
----------------------------------------------------------------
/u01/app/oracle/diag/rdbms/cdb1/cdb1/trace/cdb1_ora_15539.trc

1 row selected.

SQL>
Perform a 10053 trace of the statement.

ALTER SESSION SET EVENTS '10053 trace name context forever';

SELECT val
FROM   rownum_order_test
ORDER BY val DESC
FETCH FIRST 5 ROWS ONLY;

ALTER SESSION SET EVENTS '10053 trace name context off';
The section beginning with "Final query after transformations" shows the statement that was actually processed, after the query transformation.

Final query after transformations:******* UNPARSED QUERY IS *******
SELECT "from$_subquery$_002"."VAL" "VAL"
FROM  (SELECT "ROWNUM_ORDER_TEST"."VAL" "VAL",
              "ROWNUM_ORDER_TEST"."VAL" "rowlimit_$_0",
              ROW_NUMBER() OVER ( ORDER BY "ROWNUM_ORDER_TEST"."VAL" DESC ) "rowlimit_$$_rownumber"
       FROM "TEST"."ROWNUM_ORDER_TEST" "ROWNUM_ORDER_TEST") "from$_subquery$_002"
WHERE  "from$_subquery$_002"."rowlimit_$$_rownumber"<=5
ORDER BY "from$_subquery$_002"."rowlimit_$_0" DESC
As you can see, the statement has been rewritten to a form we might have used prior to 12c.