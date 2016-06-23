Basically there are no such limitations to the scenario.You always have to be greddy enough for it..I look basically for some things like
* Total number of row scan(You must be having estimate of table size)
*Whether its using any index or not.
*If its using index then which index its using.
*Which optimizer is being used for plan generation..
If you are using more than one table then ordering position of driving table and arranging sequence of conditions will show some good result in explain plan output..Don't forget to provide hint to optimiser in that case for RBO/CBO..
*In case optimiser is using Cost based , what is the cost involved for each process.

and the list goes on

Some basic do's and don't are
- avoid using data conversions in condition clause
- don't let oracle to convert data type implicitly..
-put conditions directly related to driving table first(In case you are giving hint as RULE)
-avoid using not null in condition clause.Use minus query instead.
- use inline views instead of co-related subquery.
- avoid joins as much as possible.

Cost - - This column is weighted sum of cpu cost and I/O cost..General trend is lower the cost , faster the query executes , but its not true..So this factor is not reliable from performance point of view.Example optimiser could not calculate accurate cost in case of missing metadata.[get rough idea BUT DO NOT TRUST IT] 

Cardinality -- This is estimation of number of rows that needs to be read in different step in plan.This plays role as you would get an idea of detailed distribution of row scan in query and hence you will get idea which part of query is incresing row scans. 

Bytes -- It is almost estimation in terms of memory..Number of rows doesnt gives idea about actual byte scan in a row..There could be 10 column in a row and there could be 90 also..but row will be 1 in both case.So Byte is more important property than cardinality for me.
 Dave A.
Dave
Dave A.
Founder, SkillBuilders.com, Senior Oracle DBA

EXPLAIN PLAN is a command. It generates the predicted execution plan. You cannot answer answer your question without embarking on learning how to read an execution plan (i.e. in what order is the plan executed) and learning what the steps in the plan mean. There are "red flags" to look for, yes. But you must learn. You asked not to post a link and I will of course honor that. But if you want a link to excellent, free, video tutorials, respond and I will post.

1) "how we come to know that query requires optimization on the basis of explain plan" 
you don't. you know that the query requires optimization because it doesn't run as fast as you would like. then you use the plan to see what it is doing, to help you decide how to change it. if you see it doing full table scans, maybe you need an index or maybe you have a function on the indexed column in the where clause which is suppressing the index. or maybe it means you forgot a join condition and query is slow because it is wrong. or maybe your stats are not current, and oracle thinks the million row table only has 5 rows. you don't start with the plan, you start with a stopwatch. 

2) 
like Himanshu said, don't get hung up on the cost - it's relative to itself, and meaningless for comparison. when oracle parses a sql, it contemplates multiple plans - should I use index A or B, should I do I nested loop or hash join, start with table X or Y, etc, etc. then each of these potential plans are given "cost", which is weighted against the costs of the other possible plans. 

now let's say you create a new index, and run the same query again. oracle builds a whole new set of possible plans, and the costs of these have no relation to the costs of the plans from the first run (before the new index was created), because the conditions have changed. so any change in the environment. 

next, instead of creating an index, you simply rewrite your query - you changed a "not in" subquery to a "not exists" correlated subquery. this is a different query than you had before (even though it achieves the same results), so the "cost" assigned to it is relative to all possible plans for THIS query, and is totally unrelated to the cost of the original query. 

so, the cost is only meaningful to a specific query, and cannot be compared across queries - for two different queries, a higher cost might be faster than a lower cost, simply because they are different queries, and the costs are not relative to each other.




explain plan for
  select a.id from t1 a, t2 b
   where a.id=b.id(+)
     and b.id is null;

select * from table(dbms_xplan.display);

explain plan for
  select a.id from t1 a, t2 b
   where a.id=b.id(+)
     and b.id is null;
SELECT * FROM TABLE(dbms_xplan.display(NULL,NULL,'ALL'));
--or
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY('plan_table',null,'basic +predicate +cost')); 
--or
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'basic')); 

