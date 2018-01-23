How to reduce Buffer Busy Waits with Hash Partitioned Indexes in #Oracle

fight_contention

Buffer Busy Waits can be a serious problem for large OLTP systems on both tables and indexes. If e.g. many inserts from multiple sessions occur simultaneously, they may have to compete about the same index leaf blocks like the picture below shows:

Index Leaf Block Contention
Index Leaf Block Contention

For the demo below, I’m using 100 jobs running at the same time to simulate 100 end user session that do inserts into table t with an ordinary index i that is not yet partitioned:

SQL> create table t (id number, sometext varchar2(50));

Table created.

SQL> create index i on t(id);

Index created.

SQL> create sequence id_seq;

Sequence created.

SQL> create or replace procedure manyinserts as
     begin
      for i in 1..10000 loop
       insert into t values (id_seq.nextval, 'DOES THIS CAUSE BUFFER BUSY WAITS?');
      end loop;
      commit;
     end;
     /  

Procedure created.

SQL> create or replace procedure manysessions as
     v_jobno number:=0;
     begin
      for i in 1..100 loop
       dbms_job.submit(v_jobno,'manyinserts;', sysdate);
      end loop;
      commit;
     end;
     /

Procedure created.

SQL> exec manysessions

PL/SQL procedure successfully completed.
After a couple of minutes the jobs are done and the table is populated:

SQL> select count(*) from t;

  COUNT(*)
----------
   1000000

SQL> select object_name,subobject_name,value 
     from v$segment_statistics where owner='ADAM' 
     and statistic_name='buffer busy waits'
     and object_name = 'I';

OBJECT_NAM SUBOBJECT_	   VALUE
---------- ---------- ----------
I			  167363
There have been Buffer Busy Waits on the table t as well of course, but let’s focus on the index here. Now the same load but with a Hash Partitioned index instead:

SQL> drop index i;

Index dropped.

SQL> truncate table t;

Table truncated.

SQL> create index i on t(id) global
     partition by hash(id) partitions 32;
 
Index created.
Notice that you have to say GLOBAL even though the table is not partitioned itself, so LOCAL is impossible. How about the effect?

SQL> exec manysessions

PL/SQL procedure successfully completed.

SQL> select count(*) from t;

  COUNT(*)
----------
   1000000

SQL> select object_name,subobject_name,value 
     from v$segment_statistics where owner='ADAM' 
     and statistic_name='buffer busy waits'
     and object_name = 'I';


OBJECT_NAM SUBOBJECT_	   VALUE
---------- ---------- ----------
I	   SYS_P249	     138
I	   SYS_P250	     122
I	   SYS_P251	     138
I	   SYS_P252	     120
I	   SYS_P253	     134
I	   SYS_P254	     116
I	   SYS_P255	     132
I	   SYS_P256	     129
I	   SYS_P257	     126
I	   SYS_P258	     140
I	   SYS_P259	     126
I	   SYS_P260	     129
I	   SYS_P261	     142
I	   SYS_P262	     142
I	   SYS_P263	     156
I	   SYS_P264	     155
I	   SYS_P265	     165
I	   SYS_P266	     121
I	   SYS_P267	     142
I	   SYS_P268	     148
I	   SYS_P269	     120
I	   SYS_P270	     112
I	   SYS_P271	     168
I	   SYS_P272	     130
I	   SYS_P273	     129
I	   SYS_P274	     137
I	   SYS_P275	     147
I	   SYS_P276	     131
I	   SYS_P277	     132
I	   SYS_P278	     136
I	   SYS_P279	     124
I	   SYS_P280	     138

32 rows selected.
Instead of having just one hot part, we now have as many ‘warm parts’ as there are partitions, like the picture below tries to show:

Reduced contention with hash partitioned index
Reduced contention with hash partitioned index

Precisely this was achieved by the solution:

SQL> select sum(value) from v$segment_statistics 
     where owner='ADAM' 
     and statistic_name='buffer busy waits'
     and object_name = 'I'; 

SUM(VALUE)
----------
      4325

SQL> select 167363-4325 as waits_gone from dual;

WAITS_GONE
----------
    163038