How to Generate a Useful SQL Execution Plan
https://blogs.oracle.com/optimizer/how-to-generate-a-useful-sql-execution-plan
Nigel Bayliss 
PRODUCT MANAGER
Introduction
There is an old joke the unreconstructed comic Dave Allen used to tell, where a traveler asks a passer-by for directions to a particular town and the passer-by simply says, “Well I wouldn’t start from here if I were you.” When it comes to SQL execution plans, if you start from the wrong place, then you probably won't make it to your destination.

The purpose of this blog post is to take stock for a moment and present what I consider to be the best 'default' methods for collecting SQL execution plans. This post is intended for those of you that don't have an established method already and want to make sure that you capture something that is actually useful. To clarify what I mean by 'useful': I mean a plan that will help you to learn how SQL execution plans work (if you don't know already) and one that is suitable for figuring out if there is a problem that makes the SQL statement take longer to execute than it should.

A SQL execution plan reveals a great deal about how the Oracle Database plans to execute (or has executed) a SQL statement. Do you need to understand SQL execution plans to be an effective Oracle Database expert? No - but most of us like to learn new things, and it's fun to take a look inside the machine sometimes.

There's a lot of opinion in the post, so remember that comments are very welcome.

Yet Another Article on SQL Execution Plans?
I know that there are a LOT of articles and chapters in books about generating SQL execution plans. There is no single 'right way', but I want to distill things down to a few cases that will be good-to-go in most scenarios. Why? Well, I get sent quite a large number of SQL execution plans, and I often find myself wishing for that vital piece of information that's missing from the plan I've been sent. In addition, there seems to be some blind spots – useful methods that are often mentioned but often missed. Finally, when I wanted to learn to read plans myself, I found it confusing and frustrating until I realized that there's a lot of incredibly helpful information provided by the Oracle Database, but you won't see it if you don't ask for it!

It is perhaps easy to believe that you are the only one to think that SQL execution plans are difficult to understand. Often they are difficult to understand – their sheer size can be daunting. Some are almost impossible to evaluate if certain details are missing. They can be confusing because some query transformations and operations will result in reported numbers (such as Rows) being at odds with what you might expect. This won't prevent you from understanding how queries are executed, but when you start out, it can give you some tough hurdles to leap.

The examples below generate lot of information that is useful but potentially overwhelming (and probably unnecessary at first). Nevertheless, the information is broken down into sections (or available through an Enterprise Manager UI) so it is easy to digest piecemeal or simply ignored until you want to consider it.

I have not listed the output of all the examples below because it would take up too much space, so I uploaded some self-contained scripts to GitHub.

Examples
Here are my suggestions …

Example A

If you can run the query stand-alone using (for example) SQL Plus or SQLcl:

select e.ename,r.rname
from   employees  e
join   roles       r on (r.id = e.role_id)
join   departments d on (d.id = e.dept_id)
where  e.staffno <= 10
and    d.dname in ('Department Name 1','Department Name 2');

SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALL +OUTLINE'));
Or, if you don’t want to execute the query:

explain plan for
select  e.ename,r.rname
from    employees  e
join    roles       r on (r.id = e.role_id)
join    departments d on (d.id = e.dept_id)
where   e.staffno <= 10
and     d.dname in ('Department Name 1','Department Name 2');

SELECT *
FROM table(DBMS_XPLAN.DISPLAY (FORMAT=>'ALL +OUTLINE'));


The important feature of this example is that I am using FORMAT=>'ALL +OUTLINE'. Some of you might have come across the undocumented option, FORMAT=>'ADVANCED'. I am not using it here because the content of its output has the potential to be different between releases, but there's no fundamental reason why you can't use it. The 'ALL' format is documented and 'OUTLINE' is mentioned briefly; its basic content is unlikely to change between releases.

Example B

If you cannot run a query stand-alone, you can still get plan information from the cursor cache using a query like this:

SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(
            SQL_ID=>'the_SQL_ID', 
            CHILD_NUMBER=>the_child_number, 
            FORMAT=>'ALL +OUTLINE'));
You will need the SQL_ID and CHILD_NUMBER of the query you want. There are many ways of doing this, but if you have DBA privilege then you can search for the statement in V$SQL:

select /* MY_TEST_QUERY */
       e.ename,r.rname
from   employees  e
join   roles       r on (r.id = e.role_id)
join   departments d on (d.id = e.dept_id)
where  e.staffno <= 10
and    d.dname in ('Department Name 1','Department Name 2');

select sql_id, child_number, sql_text
from   v$sql 
where  sql_text like '%MY_TEST_QUERY%'
and    sql_text not like '%v$sql%';
The plans above do not include any runtime information, so you will not see how long each part of the plan took to execute or how many rows were actually processed. For example, 'Rows' is an estimate; it does not tell you how many rows were actually processed. If you gather and examine runtime information, it is likely that your level of understanding will be enhanced significantly. How do you go about getting it?

Example C

You can use a hint to gather runtime information:

select /*+ gather_plan_statistics */
       e.ename,r.rname
from   employees  e
join   roles       r on (r.id = e.role_id)
join   departments d on (d.id = e.dept_id)
where  e.staffno <= 10
and    d.dname in ('Department Name 1','Department Name 2');

SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALLSTATS LAST ALL +OUTLINE'));


This will show you statistics such as the actual number of rows processed (A-Rows), rather than just the estimates (E-Rows). It also includes a column called Starts, which tells you how many times each step was executed. A-Rows, E-Rows and Starts are all incredibly useful if you want to understand a plan.

Example D

If you don’t want to change the query text to add the hint, there is a parameter you can set instead:

alter session set statistics_level='ALL';

select e.ename,r.rname
from   employees  e
join   roles       r on (r.id = e.role_id)
join   departments d on (d.id = e.dept_id)
where  e.staffno <= 10
and    d.dname in ('Department Name 1','Department Name 2');

SELECT *
FROM table(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT=>'ALLSTATS LAST ALL +OUTLINE'));
Example E

DBMS_XPLAN 'ALLSTATS LAST' does not give you a continuous view of runtime statistics while a query is executing, but SQL Monitor solves this problem. It requires the Oracle Tuning Pack, so always check the licence user guide for your database version. This tool is fantastic for generating plans and monitoring SQL, and it is available via Enterprise Manager in the Performance Hub. Before I cover that, you can use it on the command line too (a fact that is often missed or forgotten for some reason):

select /*+ MONITOR */
       e.ename,r.rname
from   employees  e
join   roles       r on (r.id = e.role_id)
join   departments d on (d.id = e.dept_id)
where  e.staffno <= 10
and    d.dname in ('Department Name 1','Department Name 2');

-- Get the SQL ID of the query we just executed
select prev_sql_id 
from   v$session 
where  sid=userenv('sid') 
and    username is not null 
and    prev_hash_value <> 0;

PREV_SQL_ID
-------------
an05rsj1up1k5

set linesize 250 pagesize 0 trims on tab off long 1000000
column report format a220

select 
   DBMS_SQL_MONITOR.REPORT_SQL_MONITOR
        (sql_id=>'an05rsj1up1k5',report_level=>'ALL') report
from dual;


The SQL_ID parameter is optional, but I usually set it explicitly because there might be multiple long-running queries in the system, so the default report will sometimes pick up a different SQL statement to the one I am experimenting with. The database automatically makes long-running queries available to SQL Monitor, but I used a MONITOR hint in this case because the query is very fast and wouldn't normally show up.

It can be useful to monitor a query while it is executing because you can watch its progress and learn from that. This is where SQL Monitor is really useful because you can watch a query in another session and see its statistics updating continuously. You don’t necessarily have to wait for it to complete to figure out what part of the query is taking a long time, so you can sometimes avoid having to wait for completion. Note that you can get 'ALL +OUTLINE' plan details while a query is executing - just use Example B, above.

You can even generate an active HTML report using the command line! This is a great way to capture a SQL execution plan and explore it interactively later on. Just run the report like this:

-- spool output to a file, then…
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR
        (sql_id       =>'an05rsj1up1k5',
         report_level =>'all', 
         type         =>'ACTIVE') report
from dual;
If you spool the output and open it in a browser, you get an interactive HTML page like this:



Bear in mind that the browser requires Internet access because the HTML report downloads some external assets.

Example F

I know that many of you love the command line (and I am the same) but you should check out using SQL Monitor in the Oracle Enterprise Manager Performance Hub. It’s much easier to access interactive SQL Monitor reports and they will refresh continuously as query execution progresses. In addition, it is easy to save these reports and send them to others. Just use the Save button (circled in red, below).



If you hit the 'Plan' tab, it can be enlightening to look at a graphical view if the plan is not too large. I like to select 'Rotate' to give me a tree that is oriented vertically. Aha - now I can see what the left side and right side of a join actually means! Very broadly speaking, you read trees from the bottom left up. I might blog about this later. In the following example, and in common with the examples above, the database reads DEPARTMENTS first, then joins the rows with EMPLOYEES and then joins these rows with ROLES.



Example G

Finally, there is SQL Developer too!



With DBMS_XPLAN:

SQL Developer and DBMS_XPLAN

Summary
If you want to save and share a plan, then...


More
Check out the self-contained test scripts for this post.

If you want more detail and more options for looking at plans, then check out Maria’s blog posts on DBMS_XPLAN and SQL Monitor.

If you want to generate plans and send a runnable test case to someone else, then check out Test Case Builder and the Oracle Support tool SQLT.

Comments and @vldbb welcome!