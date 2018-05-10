show parameter db_block_size
show parameter multiblock

Why is my query not picking up the local index when I try 
to fetch the rows which is less than 10% of data ? 

there is no set percentage of the data that will be retrieve via an index. You could have an index whereby 1% of the data selected would blow off the index and use a full scan. 

Consider a table with 10 rows per block. 
You want to get 10% of the rows from that table. 
You have 10,000 rows in the table (so you have 1,000 blocks). You want to get 1,000 of them. 

You might have to read EVERY SINGLE BLOCK from that table to get 10% of the rows - the 1,000 rows you want might be on 1,000 different table blocks. 

OR 

You might have to read 10 blocks to get those 1,000 rows - if the rows you want are located right next to each other. 


To make it more real, think of a table that has a NAME column and a CREATED_DATE column. You insert into this table some new name (arrives randomly) and sysdate. 

If you say "give me all of the records that begin with a name of A%", and we decide that will return about 10% of the data we might well full scan since the A's would be spread all over the place. 

On the other hand, if you say "where created_date between :x and :y" and we decide that will return about 10% of the data - we might well use an index on that since all of the rows with dates close to each other would naturally be physically close to each other - simply because we add rows to the table in order of sysdate. 

ops$tkyte%ORA11GR2> create table organized
  2  as
  3  select x.*
  4    from (select * from stage order by object_name) x
  5  /

Table created.

ops$tkyte%ORA11GR2> create table disorganized
  2  as
  3  select x.*
  4    from (select * from stage order by dbms_random.random) x
  5  /

Table created.

ops$tkyte%ORA11GR2> pause

ops$tkyte%ORA11GR2> create index organized_idx on organized(object_name);
Index created.

ops$tkyte%ORA11GR2> create index disorganized_idx on disorganized(object_name);
Index created.

ops$tkyte%ORA11GR2> begin
  2  dbms_stats.gather_table_stats
  3  ( user, 'ORGANIZED',
  4    estimate_percent => 100,
  5    method_opt=>'for all indexed columns size 254'
  6  );
  7  dbms_stats.gather_table_stats
  8  ( user, 'DISORGANIZED',
  9    estimate_percent => 100,
 10    method_opt=>'for all indexed columns size 254'
 11  );
 12  end;
 13  /

PL/SQL procedure successfully completed.

ops$tkyte%ORA11GR2> pause

ops$tkyte%ORA11GR2>
ops$tkyte%ORA11GR2>
ops$tkyte%ORA11GR2> clear screen
ops$tkyte%ORA11GR2> select table_name, blocks, num_rows, 0.05*num_rows, 0.10*num_rows from user_tables
  2  where table_name like '%ORGANIZED' order by 1;

TABLE_NAME                         BLOCKS   NUM_ROWS 0.05*NUM_ROWS 0.10*NUM_ROWS
------------------------------ ---------- ---------- ------------- -------------
DISORGANIZED                         1065      72939       3646.95        7293.9
ORGANIZED                            1066      72939       3646.95        7293.9

ops$tkyte%ORA11GR2> select table_name, index_name, clustering_factor from user_indexes
  2  where table_name like '%ORGANIZED' order by 1;

TABLE_NAME                     INDEX_NAME                     CLUSTERING_FACTOR
------------------------------ ------------------------------ -----------------
DISORGANIZED                   DISORGANIZED_IDX                           72877
ORGANIZED                      ORGANIZED_IDX                               1040

<b>so, we have two tables, exactly the same data - just in different orders.  In the
organized table, the rows are sorted by object_name, in the disorganized - they are not.

Notice the clustering factor statistic there - in the organized table it is close to the
number of blocks in the table, in the disorganized - near the number of rows.  the
clustering factor is a measure of how many IO's it would take to read the entire table
via the index.  That metric shows that the organized table index would be used to read
more rows out via the index than the disorganized - because the table rows just happen
to be sorted like the index keys are.  </b>

ops$tkyte%ORA11GR2> set autotrace traceonly explain
ops$tkyte%ORA11GR2> select * from organized where object_name like 'F%';

Execution Plan
----------------------------------------------------------
Plan hash value: 1925627673

-------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CP
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |   144 | 13968 |     6   (
|   1 |  TABLE ACCESS BY INDEX ROWID| ORGANIZED     |   144 | 13968 |     6   (
|*  2 |   INDEX RANGE SCAN          | ORGANIZED_IDX |   144 |       |     3   (
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_NAME" LIKE 'F%')
       filter("OBJECT_NAME" LIKE 'F%')

<b>that query has a very low cost because the optimizer thinks it will do about 3 IO's
against the index and 3 more against the table - which is just about right.  My table
gets about 70 rows per block - so it would take three table blocks to read the rows out
- and the index would have to read a root block, branch block and leaf block to get the
rowids for the 144 rows</b>

ops$tkyte%ORA11GR2> select * from disorganized where object_name like 'F%';

Execution Plan
----------------------------------------------------------
Plan hash value: 3767053355

-------------------------------------------------------------------------------
| Id  | Operation                   | Name             | Rows  | Bytes | Cost (
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                  |   144 | 13968 |   148
|   1 |  TABLE ACCESS BY INDEX ROWID| DISORGANIZED     |   144 | 13968 |   148
|*  2 |   INDEX RANGE SCAN          | DISORGANIZED_IDX |   144 |       |     3
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_NAME" LIKE 'F%')
       filter("OBJECT_NAME" LIKE 'F%')

<b>but look at the cost of the same query against the other table.  It is 148.  It would
take 3 IO's against the index as before - but somewhere around 144 IO's against the
table since the data is so spread out!  so much higher cost.  But both were using
indexes so far.

remember this is a 72,000 row table.  1% of that is 720.</b>


ops$tkyte%ORA11GR2> select * from organized where object_name like 'A%';

Execution Plan
----------------------------------------------------------
Plan hash value: 1925627673

-------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CP
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |  1826 |   172K|    39   (
|   1 |  TABLE ACCESS BY INDEX ROWID| ORGANIZED     |  1826 |   172K|    39   (
|*  2 |   INDEX RANGE SCAN          | ORGANIZED_IDX |  1826 |       |    12   (
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_NAME" LIKE 'A%')
       filter("OBJECT_NAME" LIKE 'A%')

<b>if we go after 1,826 rows - this query on this table will still use an index - the
cost is still very low since the 1,826 rows we want are all next to each other...

but...</b>

ops$tkyte%ORA11GR2> select * from disorganized where object_name like 'A%';

Execution Plan
----------------------------------------------------------
Plan hash value: 2727546897

-------------------------------------------------------------------------------
| Id  | Operation         | Name         | Rows  | Bytes | Cost (%CPU)| Time
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |              |  1826 |   172K|   291   (1)| 00:00:0
|*  1 |  TABLE ACCESS FULL| DISORGANIZED |  1826 |   172K|   291   (1)| 00:00:0
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("OBJECT_NAME" LIKE 'A%')

<b>getting the same 1,826 rows will not use an index here.  the full scan cost is 291 -
way below the cost of getting 1,826 using single block IO's all over the place.

in fact, we can see that if we were to get around 290 rows out of this table - we would
stop using an index.  that is about 0.4% of the rows in the table!!!!

we would not use this index to retrieve less than 0.5% of the table - no where near
10%!!!!
</b>