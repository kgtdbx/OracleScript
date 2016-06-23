Partition Pruning

What is Partition Pruning?

Some tables are so large that a Full Table Scan is unthinkable. If these tables are not partitioned, they should be.

The most common (by far) form of partitioning is Range Partitioning on a DATE column. For example, a table may be partitioned on TXN_DATE, with a separate partition for each year, month, or even day (I have seen a multi-terabyte database where daily partitions were the norm!).

If Oracle can use the WHERE predicates to eliminate some partitions from a search, then it probably will. This is called Partition Pruning. For example:

SELECT *
FROM my_big_partition_table
WHERE calendar_date = :b1

SELECT STATEMENT
    PARTITION RANGE SINGLE
        TABLE ACCESS FULL MY_BIG_PARTITION_TABLE

SELECT *
FROM my_big_partition_table
WHERE calendar_date >= :b1

SELECT STATEMENT
    PARTITION RANGE ITERATOR
        TABLE ACCESS FULL MY_BIG_PARTITION_TABLE
Explain Plan lines showing PARTITION RANGE SINGLE or PARTITION RANGE ITERATOR indicate that Oracle is performing a Partition Prune. A line of PARTITION RANGE ALL indicates Oracle is scanning all partitions. Depending on your Explain Plan tool, there is one confusing situation: if Oracle can work out exactly which partition or partitions to scan, then the step is removed from the plan. eg.

SELECT *
FROM my_big_partition_table
WHERE calendar_date = to_date('01-MAY-2003','DD-MON-YYYY')

SELECT STATEMENT
    TABLE ACCESS FULL MY_BIG_PARTITION_TABLE
This looks like Oracle is performing a Full Table Scan of all partitions, but it is not. If that were the case, the plan would look like this:

SELECT STATEMENT
    PARTITION RANGE ALL
        TABLE ACCESS FULL MY_BIG_PARTITION_TABLE
New Explain Plan tools will show the actual partition number(s) thus eliminating this confusion.

When can I use Partition Pruning?

There are three ways to exploit partitons for performance:

Use your range partiton key in =, <[=], >[=], BETWEEN, or LIKE predicates, comparing the key to either literals, bind variables, literal / bind variable expressions, or non-correlated sub-queries. eg.

col = :my_date
col BETWEEN :my_date AND :my_date + 3
col = (SELECT processing_date FROM current_processing_date)
For List and Hash partitions, use = or IN predicates.

Perform a join to a partitoned table using the partiton key in an equals clause, where one of the above rules can be derived transitively. eg.

SELECT a.*
FROM   table_a a, big_partitioned_table b
WHERE  a.calendar_date > :a
AND    a.calendar_date = b.calendar_date
Here, Oracle can use transitive rules to learn something about the partiton key. eg. If A > :x, and A = B, then B > :x

Perform a partition-wise join. If you have two tables that are partitioned the same way, then even if you have to scan the entire table, you can make the Hash or Sort-Merge join faster by joining matching partitions. eg.

SELECT *
FROM   big_partitioned_a a, big_partitioned_b b
WHERE  a.key1 = b.key1
AND    a.key2 = b.key2
AND    a.calendar_date = b.calendar_date

SELECT STATEMENT
    PARTITION RANGE ALL
        HASH JOIN
            TABLE ACCESS FULL ON BIG_PARTITIONED_A
            TABLE ACCESS FULL ON BIG_PARTITIONED_B
Notice that the join is being done within the partition range loop. This means Oracle is joining partition to partition, not table to table.
How to fix SQLs that won't Partition Prune

If you are not using the partition key, but you are using another low-cardinality key, then speak to the DBA about Hash (v8i and above) or List (V9i and above) sub-partitions within the existing Range partitions.
The syntax WHERE partition_key oper (sub-query) will only perform a partition prune for = and IN operators; this is consistent with Index Scans. For >[=] or <[=] predicates on sub-queries, Try putting the sub-query into a PL/SQL function, and change your syntax to WHERE partition_key oper my_func() (NB. Do not pass any columns from the query into the function as arguments; it won't partition prune). For = and IN sub-queries that won't Partition Prun, make sure that the sub-query is not correlated.
Use ranges instead of functions of partition keys. eg.
Don't use WHERE to_char(calendar_date,'MON-YYYY') = 'JAN-2003'
Instead use WHERE calendar_date BETWEEN '01-JAN-2003' and '01-FEB-2003' - 0.00001
Never denormalize the partition key into other columns, because queries on those other columns will not partition prune. eg. If calendar_date were the partition key, do not create another column such as calendar_month that is derived from calendar_date. Instead, create a date lookup (dimension) table that does the denormalization for you and use the STAR_TRANSFORMATION hint. eg.
SELECT /*+ STAR_TRANSFORMATION*/ *
FROM   big_partitioned a, months b
WHERE  b.calendar_month = '200304'
AND    a.calendar_date BETWEEN b.month_start and b.month_end
If you are joining on the partition key, but not using equals joins, then you may have a design problem. eg.

SELECT *
FROM   big_partitioned_a a, big_partitioned_b b
WHERE  a.calendar_date = :a
AND    a.key = b.key
AND    b.calendar_date <= a.calendar_date
If these tables are really big, then you are in a lot of trouble: this cannot be tuned effectively.
If the join is only performed once per day or less, a Nested Loops indexed join to big_partitioned_b may be faster than a hash join with full table scan on big_partitioned_b.
If the join is more frequent, or if the query is not constrained to a single day or small subset of big_partitioned_a, then the results of the join should be built incrementally into a de-normalised table over nignt. Every day, select the new rows from big_partitioned_a and use an indexed Nested Loop join to big_partitioned_b, inserting the combined results into partitioned table big_partitioned_ab.