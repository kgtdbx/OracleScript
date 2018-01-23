Partial index tips

Oracle Database Tips by Donald BurlesonApril 5, 2016
Question:  Can you explain the partial index feature in 12c for partitioned tables?  What are the benefits of a partial index?  Can you show an example of using a partial index?

Answer:  Oracle 12c introduced the partial index in 12c for partitioned tables.  The partial index is just like an ordinary index except that the index exists only for a specific partitions.

This feature works with the parameter skip_unusable_indexes=true.

This feature is very useful in cases where parts of a super-large table are "retired" and "archived", without any specific SQL running against the partition.

In this example we create a partial index on a table named test:

create table test 
(col1 number,c2 varchar2(2)) 
   partition by list(c2) ( 
   partition p1 values('A') INDEXING OFF, 
   partition p2 values('B') INDEXING OFF, 
   partition p3 values('C') INDEXING OFF, 
   partition p4 values('D') INDEXING ON);

Note that the partitions P1 through P3 were created with the INDEX OFF syntax.  Next we create a partial index on the table:

create index idx_part_col1 on test(co11) LOCAL indexing PARTIAL;

And we see the partial index on partition p4:

select PARTITION_NAME,INDEXING from user_tab_partitions;
 
PARTITION_NAME  INDEX
--------------- ---- 
P1              OFF 
P2              OFF 
P3              OFF
P4              ON

As we see, the partial index is great when only the most recent partition ion a partitioned table is being used.


--################################################--
How Partial Indexing helps you save space in #Oracle 12c

partial

Over time certain partitions may become less popular. In 12c, you don’t have to index these partitions anymore! This can save huge amounts of space and is one of the best 12c New Features in my opinion. Really a big deal if you are working with range partitioned tables where the phenomenon of old ranges becoming unpopular is very common. Let’s have a look, first at the problem:

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments 
     where segment_name like '%OLD';   

SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
GLOBAL_OLD			   96
LOCAL_OLD  Q4			   22
LOCAL_OLD  Q3			   22
LOCAL_OLD  Q2			   22
LOCAL_OLD  Q1			   22
Without the New Feature, every part of the table is being indexed like shown on the below picture:

Ordinary Indexes on a partitioned table
Ordinary Indexes on a partitioned table

Say partitions Q1, Q2 and Q3 are not popular any more, only Q4 is accessed frequently. In 12c I can do this:

SQL> alter table sales_range modify partition q1 indexing off;

Table altered.

SQL> alter table sales_range modify partition q2 indexing off;

Table altered.

SQL> alter table sales_range modify partition q3 indexing off;

Table altered.
This alone doesn’t affect indexes, though. They must be created with the new INDEXING PARTIAL clause now:

SQL> drop index local_old;

Index dropped.

SQL> drop index global_old;

Index dropped.

SQL> create index local_new on sales_range(time_id) indexing partial local nologging;

Index created.

SQL> create index global_new on sales_range(name) global indexing partial nologging;

Index created.
You may notice that these commands execute much faster now because less I/O needs to be done. And there is way less space consumed:

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments
     where segment_name like '%NEW';
SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
LOCAL_NEW Q4 22
GLOBAL_NEW 24
That’s because the indexes look like this now:

Partial Indexes
Partial Indexes

Instead of dropping the old index you can also change it into using the New Feature:

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments 
     where segment_name like '%OLD%';

SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
GLOBAL_OLD			   96
LOCAL_OLD  Q4			   22
LOCAL_OLD  Q3			   22
LOCAL_OLD  Q2			   22
LOCAL_OLD  Q1			   22

SQL> alter index LOCAL_OLD indexing partial;

Index altered.
For a LOCAL index, that frees the space from the unpopular partitions immediately:

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments 
     where segment_name like '%OLD%';

SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
GLOBAL_OLD			   96
LOCAL_OLD  Q4			   22
That is different with a GLOBAL index:

SQL> alter index GLOBAL_OLD indexing partial;

Index altered.

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments 
     where segment_name like '%OLD%';

SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
GLOBAL_OLD			   96
LOCAL_OLD  Q4			   22
Still uses as much space as before, but now this releases space from unpopular parts of the index:

SQL> alter index global_old rebuild indexing partial;

Index altered.

SQL> select segment_name,partition_name ,bytes/1024/1024 from user_segments 
     where segment_name like '%OLD%';

SEGMENT_NA PARTITION_ BYTES/1024/1024
---------- ---------- ---------------
LOCAL_OLD  Q4			   22
GLOBAL_OLD			   24
Cool 12c New Feature, isn’t it? ??
