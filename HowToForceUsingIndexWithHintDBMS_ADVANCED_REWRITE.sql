USING DBMS_ADVANCED_REWRITE WITH AN HINT TO CHANGE THE EXECUTION PLAN
Posted by Gavin SoormaOn June 29, 20112 Comments
https://gavinsoorma.com/2011/06/using-dbms_advanced_rewrite-with-an-hint-to-change-the-execution-plan/

In one of my earlier posts, I had illustrated a use case of DBMS_ADVANCED_REWRITE and its use in cases where we cannot change the code, but can still influence and change the way the optimizer executes the same SQL statement.

In case of many vendor provided and packaged applications, we do not have access to the SQL code and we cannot rewrite the SQL statements.

So there could be cases where even though indexes are present on the table, they are not being used by the optimizer and one way we can force the optimizer to use an index is via the INDEX hint.

So how we change the execution plan of the optimizer for a particular statement without changing the original SQL statement that the application is executing?

We do it using the powerful new feature introduced in 10g called DBMS_ADVANCED_REWRITE or “tuning without touching the code”.

To illustrate this, let us create a small table called MYOBJECTS which is based on DBA_OBJECTS and I have made the data skewed on purpose where in the 55000 row table, 1000 rows have the OWNER column with the value ‘PUBLIC’ and the remaining 54000 rows have the value ‘GAVIN’ for the OWNER column.

So the CBO will choose a FULL TABLE SCAN over the INDEX scan when the WHERE clause includes the predicate ‘GAVIN’ because majority of the rows are being accessed by the query and the CBO considers it more optimal in that case to just scan the table rather than both the table and the index.

SQL> create table myobjects as select * from dba_objects;

Table created.

SQL> update myobjects set owner='GAVIN';

56575 rows updated.

SQL> update myobjects set owner='PUBLIC' where rownum <1001;

1000 rows updated.

SQL> commit;

Commit complete.

SQL> create index myobjects_ind on myobjects(owner);

Index created.

SQL> explain plan for select object_name,object_type from myobjects where owner='GAVIN';

Explained.

SQL> select * from table (dbms_xplan.display);

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------
Plan hash value: 2581838392

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 52826 |  4849K|   225   (3)| 00:00:03 |
|*  1 |  TABLE ACCESS FULL| MYOBJECTS | 52826 |  4849K|   225   (3)| 00:00:03 |
-------------------------------------------------------------------------------


So if we feel that the CBO should be still using an index regardless, we can provide an INDEX hint and we see now the index is being used as opposed to a full table scan.

SQL> explain plan for select /*+ INDEX (myobjects myobjects_ind) */
  2  object_name,object_type from myobjects where owner='GAVIN';

Explained.

SQL> select * from table (dbms_xplan.display);

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------
Plan hash value: 2745750972

---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               | 52826 |  4849K|   916   (1)| 00:00:11 |
|   1 |  TABLE ACCESS BY INDEX ROWID| MYOBJECTS     | 52826 |  4849K|   916   (1)| 00:00:11 |
|*  2 |   INDEX RANGE SCAN          | MYOBJECTS_IND | 52826 |       |   134   (3)| 00:00:02 |
---------------------------------------------------------------------------------------------
But now the question is if I cannot change the SQL statement or have access to the code, how do I still enforce the INDEX hint?

DBMS_ADVANCED_REWRITE to the rescue.

Remember SYS needs to grant execute privileges on the DBMS_ADVANCED_REWRITE package to the user who is going to use this.

Since we have created the table as SYSTEM, we connect as SYSTEM and execute this statement shown below.

Basically the two main parameters we are providing here is the SOURCE STATEMENT or the original SQL and the DESTINATION STATEMENT which is the modified piece of SQL we want the optimizer to execute every time it sees the “source or original” statement.


begin
sys.dbms_advanced_rewrite.declare_rewrite_equivalence(
name => 'Use_Myobjects_Index',
source_stmt =>'select object_name,object_type from myobjects where owner=''PUBLIC''',
destination_stmt => 'select /*+ INDEX (myobjects myobjects_ind) */ object_name,object_type from myobjects where owner=''PUBLIC''' , 
validate => false,
rewrite_mode => 'text_match');
end;
/
But since both the source and destination statements are the same in this case (Oracle considers the INDEX hint to be just a comment), we get an error like the one shown below:

ERROR at line 1:
ORA-30394: source statement identical to the destination statement
ORA-06512: at "SYS.DBMS_ADVANCED_REWRITE", line 29
ORA-06512: at "SYS.DBMS_ADVANCED_REWRITE", line 185
ORA-06512: at line 2
Okay. so now how do we make the second statement differ so that it is recognised as a new statement different from the original one without changing radically the SQL itself?

I looked up various user forums because this problem has been faced by others as well and one of the suggestions given was to add the clause SYSDATE=SYSDATE which I think is a good suggestion as it will not affect the outcome of the SQL statement and should not cause any real performance overhead.

So this is what the new DBMS_ADVANCED_REWRITE statement looked like:


begin
sys.dbms_advanced_rewrite.declare_rewrite_equivalence(
name => 'Use_Myobjects_Index',
source_stmt =>'select object_name,object_type from myobjects where owner=''GAVIN''',
destination_stmt => 'select /*+ INDEX (myobjects myobjects_ind) */ object_name,object_type from myobjects where owner=''GAVIN'' and sysdate=sysdate' , 
validate => false,
rewrite_mode => 'text_match');
end;
/
After executing the piece of PL/SQL, let us now see what has happens when we run our SQL statement which was originally going for a FULL TABLE SCAN.

SQL> explain plan for select object_name,object_type from myobjects where owner='GAVIN';

Explained.

SQL> select * from table (dbms_xplan.display);

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------
Plan hash value: 792246183

----------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               | 52826 |  4849K|   916   (1)| 00:00:11 |
|*  1 |  FILTER                      |               |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| MYOBJECTS     | 52826 |  4849K|   916   (1)| 00:00:11 |
|*  3 |    INDEX RANGE SCAN          | MYOBJECTS_IND | 52826 |       |   134   (3)| 00:00:02 |
----------------------------------------------------------------------------------------------
We see that now the CBO is using the index MYOBJECTS_IND and doing an INDEX RANGE SCAN instead of the full table scan and we have actually transformed the SQL statement which the application executes without altering the SQL itself.

We can use the view USER_REWRITE_EQUIVALENCES to check what all query rewrites we have set up in the database.

SQL> set long 500000

SQL> select NAME,SOURCE_STMT,DESTINATION_STMT,REWRITE_MODE from user_rewrite_equivalences;

NAME                           SOURCE_STMT


NAME                           SOURCE_STMT
------------------------------ --------------------------------------------------------------------------------
DESTINATION_STMT                                                                 REWRITE_MO
-------------------------------------------------------------------------------- ----------
USE_MYOBJECTS_INDEX            select object_name,object_type from myobjects where owner='GAVIN'
select /*+ INDEX (myobjects myobjects_ind) */ object_name,object_type from myobj TEXT_MATCH
ects where owner='GAVIN' and sysdate=sysdate
A very good feature!

Read more about this here …


--##############################################################--
Optimizing Unoptimizeable SQL – dbms_advanced_rewrite
with one comment
https://dioncho.wordpress.com/2009/03/06/optimizing-unoptimizeable-sql-dbms_advanced_rewrite/

One of the common requests very difficult to solve.

I have a bad performing query, but I don’t have access to source file. How can I change the execution plan?

Very bad request, but there are people who are in trouble as in this OTN form thread.

The good news is that some smart guys struggled to fight this and now we do have some well known techniques.

Modifying optimizer parameters
Controlling statistics(including histogram) – Systemized by Wolfgang Breitling
Stored outline – Visit here
SQL profile – Visit here
Advanced query rewrite
The last one – advanced query rewrite – is the topic today. This technique is especially useful under following situations.

Oracle 10g+
When stored outline and sql profile do not help – they use hints to control the execution plan, but there are cases when hints are useless.
Select, not DML
With no bind variables
Advanced query rewrite is designed as an assistance to mview query rewrite, but with above conditions met, we can enjoy it’s power with non-mview queries.

Following is a simple demonstration.

I have following query.

create table t1(c1, c2, c3, c4) ...;
create index t1_n1 on t1(c1);

select * from t1 where c1 like '%11%';


I have index on t1.c1, but Oracle can’t use it. What I like to do is convert the original query to this form.

select /*+ leading(x) use_nl(x t1) */ t1.*
from 
  (select /*+ index_ffs(t1) */ rowid as row_id, c1 
    from t1 where c1 like '%11%') x,
  t1
where
  t1.rowid = x.row_id
;


By preprocessing with index fast full scan, I’m trying to avoid the danger of full scan on very large table.

Look how I achieve it using advanced query rewrite.

UKJA@ukja116> create table t1(c1, c2, c3, c4)
UKJA@ukja116> as
UKJA@ukja116> select to_char(level), to_char(level), to_char(level), to_char(level)
UKJA@ukja116> from dual
UKJA@ukja116> connect by level  ;
UKJA@ukja116> 
UKJA@ukja116> create index t1_n1 on t1(c1);
UKJA@ukja116> 
UKJA@ukja116> -- This is current problematic query
UKJA@ukja116> explain plan for
  2  select *
  3  from t1
  4  where c1 like '%11%'; -- Look here! 

Explained.

UKJA@ukja116> 
UKJA@ukja116> select * from table(dbms_xplan.display);
--------------------------------------------------------------------------                                              
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |                                              
--------------------------------------------------------------------------                                              
|   0 | SELECT STATEMENT  |      | 50000 |  1318K|  1182   (3)| 00:00:06 |                                              
|*  1 |  TABLE ACCESS FULL| T1   | 50000 |  1318K|  1182   (3)| 00:00:06 |                                              
--------------------------------------------------------------------------                                              
                                                                                                                        
UKJA@ukja116> 
UKJA@ukja116> -- This is what I want
UKJA@ukja116> explain plan for
  2  select /*+ leading(x) use_nl(x t1) */ t1.*
  3  from
  4    (select /*+ index_ffs(t1) */ rowid as row_id, c1
  5  	 from t1 where c1 like '%11%') x,
  6    t1
  7  where
  8    t1.rowid = x.row_id
  9  ;

Explained.

UKJA@ukja116> select * from table(dbms_xplan.display);
-------------------------------------------------------------------------------------                                   
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |                                   
-------------------------------------------------------------------------------------                                   
|   0 | SELECT STATEMENT            |       | 50000 |  2246K| 50697   (1)| 00:04:14 |                                   
|   1 |  NESTED LOOPS               |       | 50000 |  2246K| 50697   (1)| 00:04:14 |                                   
|*  2 |   INDEX FAST FULL SCAN      | T1_N1 | 50000 |   927K|   653   (5)| 00:00:04 |                                   
|   3 |   TABLE ACCESS BY USER ROWID| T1    |     1 |    27 |     1   (0)| 00:00:01 |                                   
-------------------------------------------------------------------------------------                                   
                                                                                                                        
UKJA@ukja116> 
UKJA@ukja116> -- Advanced query rewrite is the answer
UKJA@ukja116> 
UKJA@ukja116> -- grant priv to ukja (as sys user)
UKJA@ukja116> -- grant execute on dbms_advanced_rewrite to ukja;
UKJA@ukja116> -- grant create materialized view to ukja;
UKJA@ukja116> 
UKJA@ukja116> alter session set query_rewrite_integrity = trusted;

Session altered.

UKJA@ukja116> 
UKJA@ukja116> 
UKJA@ukja116> begin
  2    sys.dbms_advanced_rewrite.declare_rewrite_equivalence (
  3  	  name		 => 'rewrite1',
  4  	  source_stmt =>
  5  'select *
  6  from t1
  7  where c1 like ''%11%''',
  8  	 destination_stmt =>
  9  'select /*+ leading(x) use_nl(x t1) */ t1.*
 10  from
 11    (select /*+ index_ffs(t1) */ rowid as row_id, c1
 12  	 from t1 where c1 like ''%11%'') x,
 13    t1
 14  where
 15    t1.rowid = x.row_id',
 16  	  validate	 => false,
 17  	  rewrite_mode	 => 'text_match');
 18  end;
 19  /

PL/SQL procedure successfully completed.

UKJA@ukja116> -- See how the execution plan is changed
UKJA@ukja116> explain plan for
  2  select *
  3  from t1
  4  where c1 like '%11%'
  5  ;

Explained.

UKJA@ukja116> select * from table(dbms_xplan.display);
-------------------------------------------------------------------------------------                                   
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |                                   
-------------------------------------------------------------------------------------                                   
|   0 | SELECT STATEMENT            |       | 50000 |  1660K| 50697   (1)| 00:04:14 |                                   
|   1 |  NESTED LOOPS               |       | 50000 |  1660K| 50697   (1)| 00:04:14 |                                   
|*  2 |   INDEX FAST FULL SCAN      | T1_N1 | 50000 |   341K|   653   (5)| 00:00:04 |                                   
|   3 |   TABLE ACCESS BY USER ROWID| T1    |     1 |    27 |     1   (0)| 00:00:01 |                                   
-------------------------------------------------------------------------------------                                   
                                                                                                                        
UKJA@ukja116> -- drop rewrite equivalence
UKJA@ukja116> begin
  2    sys.dbms_advanced_rewrite.drop_rewrite_equivalence( name=> 'rewrite1');
  3  end;
  4  /

PL/SQL procedure successfully completed.



Magical approach, isn’t it?

The stored outline and SQL profile are easy and common approaches, but this special case does not allow us to use them. The basic mechanism of both tricks is hints. I can’t make Oracle choose the index preprocessing(index fast full scan first, then table lookup by rowid) just by hints.

Consider to apply following technqiues before you beg of the arrogant developers to modify the source. :)

Modifying optimizer parameters
Controlling statistics(including histogram) – Systemized by Wolfgang Breitling
Stored outline – Visit here
SQL profile – Visit here
Advanced query rewrite
