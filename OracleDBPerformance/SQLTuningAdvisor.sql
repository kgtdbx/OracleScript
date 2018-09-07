A user requires certain privileges to run the SQL Tuning Advisor. Also, in order to collect and manage statistics on the HR schema, the existing statistics need to be cleared. Below are the steps to grant SQL Tuning Advisor privileges and to remove the existing statistics on the hr user.

Click SQL Worksheet  and select system user.


To grant privileges to the hr user to run the SQL Tuning Advisor, enter the following lines of code. Click Run Script.

grant advisor to hr;
grant administer sql tuning set to hr;

The Oracle database allows you to collect statistics of many different kinds in order to improve performance. To illustrate some of the features the SQL Tuning Advisor offers, clear the existing statistics from the HR schema. 
To delete the schema statistics, enter the following line of code.

exec DBMS_STATS.DELETE_SCHEMA_STATS ('hr');

Select the statement and click Run Statement 
With the DBMS_STATS package you can view and modify optimizer statistics gathered for database objects.The DELETE_SCHEMA_STATS procedure deletes statistics for an entire schema.


In this topic, you run the SQL Tuning Advisor on a SQL statement. Four types of analysis are performed by the SQL Tuning Advisor on the SQL statement.
All the recommendations are displayed in the Overview. You can also view each recommendation individually.

Open the SQL Worksheet for the hr user by clicking SQL Worksheet.


Enter the following SQL statement in the worksheet. 
select sum(e.salary), avg(e.salary), count(1), e.department_id from departments d, employees e group by e.department_id order by e.department_id;
Select the SQL statement and click SQL Tuning Advisor . or press CTR+F12.


The SQL Tuning Advisor output appears.


In the left navigator, click Statistics. In this analysis, objects with stale or missing statistics are identified and appropriate recommendations are made to remedy the problem.


In the left navigator, click SQL Profile. Here, the SQL Tuning Advisor recommends to improve the execution plan by the generation of a SQL Profile.

 
Click the Detail tabbed page to view the SQL Profile Finding.


In the left navigator, click Indexes. This recommends whether the SQL statement might benefit from an index. If necessary, new indexes that can significantly enhance query performances are identified and recommended.


Click the Overview tabbed page. In this case, there are no index recommendations.


In the left navigator, click Restructure SQL. In this analysis, relevant suggestions are made the restructure selected SQL statements for improved performance.

You can implement the SQL Tuning Advisor recommendation feature. This will enable you to update the statistics in hr schema. Perform the following steps to implement the SQL Tuning Advisor recommendations:

In the Connections navigator, right-click hr and select Gather Schema Statistics....


In Gather Schema Statistics, select Estimate Percent as 100 from the drop-down list so that all rows in each table are read. This ensures that the statistics are as accurate as possible.


Click Apply.


A confirmation message appears. Click OK.

 
To run the SQL Tuning Advisor on the SQL statement again, select the SQL statement and click SQL Tuning Advisor.

 
The SQL Tuning Advisor output appears. By gathering statistics, the Statistics and SQL Profile advice is now removed.


In the left navigator, click each of the SQL Tuning Advisor Implement Type to check if all the recommendations have been implemented.

Note the issues reported to you:

Note the issues reported to you: 

Note that the Restructure SQL recommendation to remove an unused table remains.
Remove the "departments" table in the SQL statement and click SQL Advisor. 
select sum(e.salary), avg(e.salary), count(1), e.department_id from employees e
group by e.department_id order by e.department_id;

 
The output appears. All of the advice recommendations have been removed.




 