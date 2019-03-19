SELECT  KEEP
(DENSE_RANK FIRST ORDER BY  [ NULLS )
OVER (PARTITION BY )
FROM 
GROUP BY ;	

SELECT last_name, department_id, salary,
MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct)
OVER (PARTITION BY department_id) "Worst",
MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct)
OVER (PARTITION BY department_id) "Best"
FROM employees
WHERE department_id IN (30, 60)
ORDER BY department_id, salary;

FIRST_VALUE( [IGNORE NULLS])
OVER ()	


SELECT last_name, salary, hire_date, FIRST_VALUE(hire_date)
OVER (ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lv
FROM (SELECT * FROM employees WHERE department_id = 90
ORDER BY hire_date);
-----------------------------------------------------------
SELECT   H.CODE, MAX(t.name) 
KEEP (DENSE_RANK FIRST ORDER BY NVL( HI.CLOSE_DATE, HI.OPEN_DATE) DESC)

FROM   JAN.HANDSET_INVOICE hi,
       JAN.INVOICE_TYPE it,
       JAN.TARIFF t,
       JAN.HANDSET h
WHERE      hi.HANDSET_CODE = h.code
       AND hi.INVOICE_TYPE_CODE = it.CODE
       AND it.TARIFF_CODE = t.CODE
       AND IT.TARIFF_CODE IS NOT NULL
       
GROUP BY H.CODE


--------------
select road, road_part, it, xdate, status
from
   (select t.*,
    row_number() over (partition by road order by it desc) rn
    from t
    where status <> 'stop'
   )  
where rn = 1   

--------------
select
road,
max(road_part) keep (dense_rank last order by it) road_part,
max(it)        keep (dense_rank last order by it) it,
max(xdate)     keep (dense_rank last order by it) xdate,
max(status)    keep (dense_rank last order by it) status
from t
where status <> 'stop'
group by road

---------------------------------------------------------

This article provides a clear, thorough concept of analytic functions and its various options by a series of simple yet concept building examples. The article is intended for SQL coders, who for might be not be using analytic functions due to unfamiliarity with its cryptic syntax or uncertainty about its logic of operation. Often I see that people tend to reinvent the feature provided by analytic functions by native join and sub-query SQL. This article assumes familiarity with basic Oracle SQL, sub-query, join and group function from the reader. Based on that familiarity, it builds the concept of analytic functions through a series of examples.
It is true that whatever an analytic function does can be done by native SQL, with join and sub-queries. But the same routine done by analytic function is always faster, or at least as fast, when compared to native SQL. Moreover, I am not considering here the amount of time that is spent in coding the native SQLs, testing, debugging and tuning them.

The general syntax of analytic function is:

Function(arg1,..., argn) OVER ( [PARTITION BY <...>] [ORDER BY <....>] [<window_clause>] )

<window_clause> is like "ROW <?>" or "RANK <?>" 
All the keywords will be dealt in details as we walk through the examples. The script for creating the schema (SCOTT) on which the example queries of this article are run can be obtained in ORACLE_HOME/sqlplus/demo/demobld.sql of any standard Oracle installation.

How are analytic functions different from group or aggregate functions?
SELECT deptno,
COUNT(*) DEPT_COUNT
FROM emp
WHERE deptno IN (20, 30)
GROUP BY deptno;

DEPTNO                 DEPT_COUNT             
---------------------- ---------------------- 
20                     5                      
30                     6                      

2 rows selected
Query-1
Consider the Query-1 and its result. Query-1 returns departments and their employee count. Most importantly it groups the records into departments in accordance with the GROUP BY clause. As such any non-"group by" column is not allowed in the select clause.

SELECT empno, deptno, 
COUNT(*) OVER (PARTITION BY 
deptno) DEPT_COUNT
FROM emp
WHERE deptno IN (20, 30);

     EMPNO     DEPTNO DEPT_COUNT
---------- ---------- ----------
      7369         20          5
      7566         20          5
      7788         20          5
      7902         20          5
      7876         20          5
      7499         30          6
      7900         30          6
      7844         30          6
      7698         30          6
      7654         30          6
      7521         30          6

11 rows selected.
Query-2
Now consider the analytic function query (Query-2) and its result. Note the repeating values of DEPT_COUNT column.

This brings out the main difference between aggregate and analytic functions. Though analytic functions give aggregate result they do not group the result set. They return the group value multiple times with each record. As such any other non-"group by" column or expression can be present in the select clause, for example, the column EMPNO in Query-2.

Analytic functions are computed after all joins, WHERE clause, GROUP BY and HAVING are computed on the query. The main ORDER BY clause of the query operates after the analytic functions. So analytic functions can only appear in the select list and in the main ORDER BY clause of the query.

In absence of any PARTITION or <window_clause> inside the OVER( ) portion, the function acts on entire record set returned by the where clause. Note the results of Query-3 and compare it with the result of aggregate function query Query-4.

SELECT empno, deptno, 
COUNT(*) OVER ( ) CNT
FROM emp
WHERE deptno IN (10, 20)
ORDER BY 2, 1;

     EMPNO     DEPTNO        CNT
---------- ---------- ----------
      7782         10          8
      7839         10          8
      7934         10          8
      7369         20          8
      7566         20          8
      7788         20          8
      7876         20          8
      7902         20          8
Query-3
SELECT COUNT(*) FROM emp
WHERE deptno IN (10, 20);

  COUNT(*)
----------
         8
Query-4
How to break the result set in groups or partitions?
It might be obvious from the previous example that the clause PARTITION BY is used to break the result set into groups. PARTITION BY can take any non-analytic SQL expression.

Some functions support the <window_clause> inside the partition to further limit the records they act on. In the absence of any <window_clause> analytic functions are computed on all the records of the partition clause.

The functions SUM, COUNT, AVG, MIN, MAX are the common analytic functions the result of which does not depend on the order of the records.

Functions like LEAD, LAG, RANK, DENSE_RANK, ROW_NUMBER, FIRST, FIRST VALUE, LAST, LAST VALUE depends on order of records. In the next example we will see how to specify that.

How to specify the order of the records in the partition?
The answer is simple, by the "ORDER BY" clause inside the OVER( ) clause. This is different from the ORDER BY clause of the main query which comes after WHERE. In this section we go ahead and introduce each of the very useful functions LEAD, LAG, RANK, DENSE_RANK, ROW_NUMBER, FIRST, FIRST VALUE, LAST, LAST VALUE and show how each depend on the order of the record.

The general syntax of specifying the ORDER BY clause in analytic function is:

ORDER BY <sql_expr> [ASC or DESC] NULLS [FIRST or LAST]

The syntax is self-explanatory.

ROW_NUMBER, RANK and DENSE_RANK
All the above three functions assign integer values to the rows depending on their order. That is the reason of clubbing them together.

ROW_NUMBER( ) gives a running serial number to a partition of records. It is very useful in reporting, especially in places where different partitions have their own serial numbers. In Query-5, the function ROW_NUMBER( ) is used to give separate sets of running serial to employees of departments 10 and 20 based on their HIREDATE.

SELECT empno, deptno, hiredate,
ROW_NUMBER( ) OVER (PARTITION BY
deptno ORDER BY hiredate
NULLS LAST) SRLNO
FROM emp
WHERE deptno IN (10, 20)
ORDER BY deptno, SRLNO;

EMPNO  DEPTNO HIREDATE       SRLNO
------ ------- --------- ----------
  7782      10 09-JUN-81          1
  7839      10 17-NOV-81          2
  7934      10 23-JAN-82          3
  7369      20 17-DEC-80          1
  7566      20 02-APR-81          2
  7902      20 03-DEC-81          3
  7788      20 09-DEC-82          4
  7876      20 12-JAN-83          5

8 rows selected.
Query-5 (ROW_NUMBER example)
RANK and DENSE_RANK both provide rank to the records based on some column value or expression. In case of a tie of 2 records at position N, RANK declares 2 positions N and skips position N+1 and gives position N+2 to the next record. While DENSE_RANK declares 2 positions N but does not skip position N+1.

Query-6 shows the usage of both RANK and DENSE_RANK. For DEPTNO 20 there are two contenders for the first position (EMPNO 7788 and 7902). Both RANK and DENSE_RANK declares them as joint toppers. RANK skips the next value that is 2 and next employee EMPNO 7566 is given the position 3. For DENSE_RANK there are no such gaps.

SELECT empno, deptno, sal,
RANK() OVER (PARTITION BY deptno
ORDER BY sal DESC NULLS LAST) RANK,
DENSE_RANK() OVER (PARTITION BY
deptno ORDER BY sal DESC NULLS
LAST) DENSE_RANK
FROM emp
WHERE deptno IN (10, 20)
ORDER BY 2, RANK;

EMPNO  DEPTNO   SAL  RANK DENSE_RANK
------ ------- ----- ----- ----------
  7839      10  5000     1          1
  7782      10  2450     2          2
  7934      10  1300     3          3
  7788      20  3000     1          1
  7902      20  3000     1          1
  7566      20  2975     3          2
  7876      20  1100     4          3
  7369      20   800     5          4

8 rows selected.
Query-6 (RANK and DENSE_RANK example)
LEAD and LAG
LEAD has the ability to compute an expression on the next rows (rows which are going to come after the current row) and return the value to the current row. The general syntax of LEAD is shown below:

LEAD (<sql_expr>, <offset>, <default>) OVER (<analytic_clause>)

<sql_expr> is the expression to compute from the leading row.
<offset> is the index of the leading row relative to the current row.
<offset> is a positive integer with default 1.
<default> is the value to return if the <offset> points to a row outside the partition range.

The syntax of LAG is similar except that the offset for LAG goes into the previous rows.
Query-7 and its result show simple usage of LAG and LEAD function.

SELECT deptno, empno, sal,
LEAD(sal, 1, 0) OVER (PARTITION BY dept ORDER BY sal DESC NULLS LAST) NEXT_LOWER_SAL,
LAG(sal, 1, 0) OVER (PARTITION BY dept ORDER BY sal DESC NULLS LAST) PREV_HIGHER_SAL
FROM emp
WHERE deptno IN (10, 20)
ORDER BY deptno, sal DESC;

 DEPTNO  EMPNO   SAL NEXT_LOWER_SAL PREV_HIGHER_SAL
------- ------ ----- -------------- ---------------
     10   7839  5000           2450               0
     10   7782  2450           1300            5000
     10   7934  1300              0            2450
     20   7788  3000           3000               0
     20   7902  3000           2975            3000
     20   7566  2975           1100            3000
     20   7876  1100            800            2975
     20   7369   800              0            1100

8 rows selected.
Query-7 (LEAD and LAG)
FIRST VALUE and LAST VALUE function
The general syntax is:

FIRST_VALUE(<sql_expr>) OVER (<analytic_clause>)

The FIRST_VALUE analytic function picks the first record from the partition after doing the ORDER BY. The <sql_expr> is computed on the columns of this first record and results are returned. The LAST_VALUE function is used in similar context except that it acts on the last record of the partition.

-- How many days after the first hire of each department were the next
-- employees hired?

SELECT empno, deptno, hiredate ? FIRST_VALUE(hiredate)
OVER (PARTITION BY deptno ORDER BY hiredate) DAY_GAP
FROM emp
WHERE deptno IN (20, 30)
ORDER BY deptno, DAY_GAP;

     EMPNO     DEPTNO    DAY_GAP
---------- ---------- ----------
      7369         20          0
      7566         20        106
      7902         20        351
      7788         20        722
      7876         20        756
      7499         30          0
      7521         30          2
      7698         30         70
      7844         30        200
      7654         30        220
      7900         30        286

11 rows selected.
Query-8 (FIRST_VALUE)
FIRST and LAST function
The FIRST function (or more properly KEEP FIRST function) is used in a very special situation. Suppose we rank a group of record and found several records in the first rank. Now we want to apply an aggregate function on the records of the first rank. KEEP FIRST enables that.

The general syntax is:

Function( ) KEEP (DENSE_RANK FIRST ORDER BY <expr>) OVER (<partitioning_clause>)

Please note that FIRST and LAST are the only functions that deviate from the general syntax of analytic functions. They do not have the ORDER BY inside the OVER clause. Neither do they support any <window> clause. The ranking done in FIRST and LAST is always DENSE_RANK. The query below shows the usage of FIRST function. The LAST function is used in similar context to perform computations on last ranked records.

-- How each employee's salary compare with the average salary of the first
-- year hires of their department?

SELECT empno, deptno, TO_CHAR(hiredate,'YYYY') HIRE_YR, sal,
TRUNC(
AVG(sal) KEEP (DENSE_RANK FIRST
ORDER BY TO_CHAR(hiredate,'YYYY') )
OVER (PARTITION BY deptno)
     ) AVG_SAL_YR1_HIRE
FROM emp
WHERE deptno IN (20, 10)
ORDER BY deptno, empno, HIRE_YR;

     EMPNO     DEPTNO HIRE        SAL AVG_SAL_YR1_HIRE
---------- ---------- ---- ---------- ----------------
      7782         10 1981       2450             3725
      7839         10 1981       5000             3725
      7934         10 1982       1300             3725
      7369         20 1980        800              800
      7566         20 1981       2975              800
      7788         20 1982       3000              800
      7876         20 1983       1100              800
      7902         20 1981       3000              800

8 rows selected.
Query-9 (KEEP FIRST)
How to specify the Window clause (ROW type or RANGE type windows)?
Some analytic functions (AVG, COUNT, FIRST_VALUE, LAST_VALUE, MAX, MIN and SUM among the ones we discussed) can take a window clause to further sub-partition the result and apply the analytic function. An important feature of the windowing clause is that it is dynamic in nature.

The general syntax of the <window_clause> is

[ROW or RANGE] BETWEEN <start_expr> AND <end_expr>

<start_expr> can be any one of the following 
UNBOUNDED PECEDING
CURRENT ROW 
<sql_expr> PRECEDING or FOLLOWING.
<end_expr> can be any one of the following
UNBOUNDED FOLLOWING or
CURRENT ROW or
<sql_expr> PRECEDING or FOLLOWING.
For ROW type windows the definition is in terms of row numbers before or after the current row. So for ROW type windows <sql_expr> must evaluate to a positive integer.

For RANGE type windows the definition is in terms of values before or after the current ORDER. We will take this up in details latter.

The ROW or RANGE window cannot appear together in one OVER clause. The window clause is defined in terms of the current row. But may or may not include the current row. The start point of the window and the end point of the window can finish before the current row or after the current row. Only start point cannot come after the end point of the window. In case any point of the window is undefined the default is UNBOUNDED PRECEDING for <start_expr> and UNBOUNDED FOLLOWING for <end_expr>.

If the end point is the current row, syntax only in terms of the start point can be can be
[ROW or RANGE] [<start_expr> PRECEDING or UNBOUNDED PRECEDING ]

[ROW or RANGE] CURRENT ROW is also allowed but this is redundant. In this case the function behaves as a single-row function and acts only on the current row.

ROW Type Windows
For analytic functions with ROW type windows, the general syntax is:

Function( ) OVER (PARTITIN BY <expr1> ORDER BY <expr2,..> ROWS BETWEEN <start_expr> AND <end_expr>)
or 
Function( ) OVER (PARTITON BY <expr1> ORDER BY <expr2,..> ROWS [<start_expr> PRECEDING or UNBOUNDED PRECEDING]

For ROW type windows the windowing clause is in terms of record numbers.

The query Query-10 has no apparent real life description (except column FROM_PU_C) but the various windowing clause are illustrated by a COUNT(*) function. The count simply shows the number of rows inside the window definition. Note the build up of the count for each column for the YEAR 1981.

The column FROM_P3_TO_F1 shows an example where start point of the window is before the current row and end point of the window is after current row. This is a 5 row window; it shows values less than 5 during the beginning and end.

-- The query below has no apparent real life description (except 
-- column FROM_PU_C) but is remarkable in illustrating the various windowing
-- clause by a COUNT(*) function.
 
SELECT empno, deptno, TO_CHAR(hiredate, 'YYYY') YEAR,
COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY')
ORDER BY hiredate ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING) FROM_P3_TO_F1,
COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY')
ORDER BY hiredate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM_PU_TO_C,
COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY')
ORDER BY hiredate ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) FROM_P2_TO_P1,
COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY')
ORDER BY hiredate ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) FROM_F1_TO_F3
FROM emp
ORDEDR BY hiredate

 EMPNO  DEPTNO YEAR FROM_P3_TO_F1 FROM_PU_TO_C FROM_P2_TO_P1 FROM_F1_TO_F3
------ ------- ---- ------------- ------------ ------------- -------------
  7369      20 1980             1            1             0             0
  <font bgcolor=yellow>7499      30 1981             2            1             0             3
  7521      30 1981             3            2             1             3
  7566      20 1981             4            3             2             3
  7698      30 1981             5            4             3             3
  7782      10 1981             5            5             3             3
  7844      30 1981             5            6             3             3
  7654      30 1981             5            7             3             3
  7839      10 1981             5            8             3             2
  7900      30 1981             5            9             3             1
  7902      20 1981             4           10             3             0</font>
  7934      10 1982             2            1             0             1
  7788      20 1982             2            2             1             0
  7876      20 1983             1            1             0             0

14 rows selected.
Query-10 (ROW type windowing example)
The column FROM_PU_TO_CURR shows an example where start point of the window is before the current row and end point of the window is the current row. This column only has some real world significance. It can be thought of as the yearly employee build-up of the organization as each employee is getting hired.

The column FROM_P2_TO_P1 shows an example where start point of the window is before the current row and end point of the window is before the current row. This is a 3 row window and the count remains constant after it has got 3 previous rows.

The column FROM_F1_TO_F3 shows an example where start point of the window is after the current row and end point of the window is after the current row. This is a reverse of the previous column. Note how the count declines during the end.

RANGE Windows
For RANGE windows the general syntax is same as that of ROW:

Function( ) OVER (PARTITION BY <expr1> ORDER BY <expr2> RANGE BETWEEN <start_expr> AND <end_expr>)
or 
Function( ) OVER (PARTITION BY <expr1> ORDER BY <expr2> RANGE [<start_expr> PRECEDING or UNBOUNDED PRECEDING]

For <start_expr> or <end_expr> we can use UNBOUNDED PECEDING, CURRENT ROW or <sql_expr> PRECEDING or FOLLOWING. However for RANGE type windows <sql_expr> must evaluate to value compatible with ORDER BY expression <expr1>.

<sql_expr> is a logical offset. It must be a constant or expression that evaluates to a positive numeric value or an interval literal. Only one ORDER BY expression is allowed.

If <sql_expr> evaluates to a numeric value, then the ORDER BY expr must be a NUMBER or DATE datatype. If <sql_expr> evaluates to an interval value, then the ORDER BY expr must be a DATE datatype.

Note the example (Query-11) below which uses RANGE windowing. The important thing here is that the size of the window in terms of the number of records can vary.

-- For each employee give the count of employees getting half more that their 
-- salary and also the count of employees in the departments 20 and 30 getting half 
-- less than their salary.
 
SELECT deptno, empno, sal,
Count(*) OVER (PARTITION BY deptno ORDER BY sal RANGE
BETWEEN UNBOUNDED PRECEDING AND (sal/2) PRECEDING) CNT_LT_HALF,
COUNT(*) OVER (PARTITION BY deptno ORDER BY sal RANGE
BETWEEN (sal/2) FOLLOWING AND UNBOUNDED FOLLOWING) CNT_MT_HALF
FROM emp
WHERE deptno IN (20, 30)
ORDER BY deptno, sal

 DEPTNO  EMPNO   SAL CNT_LT_HALF CNT_MT_HALF
------- ------ ----- ----------- -----------
     20   7369   800           0           3
     20   7876  1100           0           3
     20   7566  2975           2           0
     20   7788  3000           2           0
     20   7902  3000           2           0
     30   7900   950           0           3
     30   7521  1250           0           1
     30   7654  1250           0           1
     30   7844  1500           0           1
     30   7499  1600           0           1
     30   7698  2850           3           0

11 rows selected.
Query-11 (RANGE type windowing example)
Order of computation and performance tips
Defining the PARTITOIN BY and ORDER BY clauses on indexed columns (ordered in accordance with the PARTITION CLAUSE and then the ORDER BY clause in analytic function) will provide optimum performance. For Query-5, for example, a composite index on (deptno, hiredate) columns will prove effective.

It is advisable to always use CBO for queries using analytic functions. The tables and indexes should be analyzed and optimizer mode should be CHOOSE.

Even in absence of indexes analytic functions provide acceptable performance but need to do sorting for computing partition and order by clause. If the query contains multiple analytic functions, sorting and partitioning on two different columns should be avoided if they are both not indexed.

Conclusion
The aim of this article is not to make the reader try analytic functions forcibly in every other complex SQL. It is meant for a SQL coder, who has been avoiding analytic functions till now, even in complex analytic queries and reinventing the same feature much painstakingly by native SQL and join query. Its job is done if such a person finds analytic functions clear, understandable and usable after going through the article, and starts using them.





-------------------------------------------------------
Общие положения
Общая информация
В версии СУБД Oracle 8.1.6 появился новый класс из 26 функций, названных аналитическими, и получившим дальнейшее развитие в версии 9. Их описания были созданы совместными усилиями фирм IBM, Informix, Oracle и Compaq путем разработки так называемых "улучшений" некоторых конструкций, имеющихся в стандарте SQL1999.
В отличие от обычных скалярных функций аналитические функции берут аргументом SQL-таблицу, представляющую логический промежуточный результат обработки SQL-оператора, где использовано обращение к такой функции, и возвращают в качестве своего результата обычно тоже SQL-таблицу.
Цели введения аналитических функций в Oracle
Техническая цель введения аналитических функций - дать лаконичную формулировку и увеличить скорость выполнения "аналитических запросов" к БД, то есть запросов, имеющих смыслом выявление внутренних соотношений и зависимостей в данных. Более точно, пользование аналитическими функциями может дать следующие выгоды перед обычными SQL-операторами:
Лаконичную и простую формулировку. Многие аналитические запросы к БД традиционными средствами сложно формулируются, а потому с трудом осмысливаются и плохо отлаживаются.
Снижение нагрузки на сеть. То, что раньше могло формулироваться только серией запросов, сворачивается в один запрос. По сети только отправляется запрос и получается окончательный результат.
Перенос вычислений на сервер. С использованием аналитических функций нет нужды организовывать расчеты на клиенте; они полностью проводятся на сервере, ресурсы которого могут быть более подходящи для быстрой обработки больших объемов данных.
Лучшую эффективность обработки запросов. Аналитические функции имеют алгоритмы вычисления, неразрывно связанные со специальными планами обработки запросов, оптимизированными для большей скорости получения результата. 
Стратегическая цель введения в Oracle аналитических функций - дать базовое средство для построения ИС типа "складов данных" (data warehouse, DW), ИС "аналитического характера" (business intelligence systems, BI) или OLAP-систем. По представлениям разработчиков, набор таких базовых средств помимо аналитических функций формируют еще и прочие средства Oracle, такие как
конструкции ROLLUP, CUBE и связанные с ними в предложениях с GROUP BY
материализованные выводимые таблицы (materialized views) 
Классификация видов аналитических функций в Oracle
Согласно классификации из документации по Oracle, аналитические функции могут быть следующих видов:
(a) функции ранжирования
(b) статистические функции для плавающего интервала
(c) функции подсчета долей
(d) статистические функции LAG/LEAD с запаздывающим/опережающим аргументом
(e) статистические функции (линейная регрессия и т. д.)
Основные технические особенности
Место указания аналитических функций в SQL-предложении
Аналитические функции принимают в качестве аргумента столбец промежуточного результата вычисления SQL-предложения и возвращают тоже столбец. Поэтому местом их использования в SQL-предложении могут быть только фразы ORDER BY и SELECT, выполняющие завершающую обработку логического промежуточного результата.
Сравнение с обычными функциями агрегирования
Многие аналитические функции действуют подобно обычным скалярным функциям агрегирования SUM, MAX и прочим, примененным к группам строк, сформированным с помощью GROUP BY. Однако обычные функции агрегирования уменьшают степень детализации, а аналитические функции нет. Поясняющий сравнительный пример:
SELECT deptno, job, SUM(sal) sum_sal
FROM emp
GROUP BY deptno, job;
SELECT ename, deptno, job, 
            SUM(sal) OVER (PARTITION BY deptno, job) sum_sal    
FROM emp;
Результат первого запроса:
DEPTNO             JOB                       SUM_SAL
-                                           -

10
CLERK 
1300
 <- - одна группа
10
MANAGER 
2450
 <- - одна группа
10
PRESIDENT 
5000
 <- - одна группа
20
CLERK 
6000
 <- - одна группа
20
MANAGER 
1900

20
PRESIDENT 
2975

30
CLERK 
950

30
MANAGER 
2850

30
PRESIDENT 
5600

9 rows selected.
Результат второго запроса:
ENAME                    DEPTNO           JOB                SUM_SAL
-                        -                              -

MILLER
10
CLERK
1300
<- - одна группа
CLARK
10
MANAGER
2450
<- - еще одна группа
KING
10
PRESIDENT 
5000
<- - еще одна группа
SCOTT
20
ANALYST
6000
<- - еще одна группа
FORD
20
ANALYST
6000
 
SMITH
20
CLERK
1900
<- - еще одна группа
ADAMS
20
CLERK
1900
 
JONES
20
MANAGER
2975
<- - еще одна группа
JAMES
30
CLERK
950
<- - еще одна группа
BLAKE
30
MANAGER
2850
<- - еще одна группа
ALLEN
30
SALESMAN 
5600
<- - еще одна группа
MARTIN
30
SALESMAN 
5600
 
TURNER
30
SALESMAN 
5600
 
WARD
30
SALESMAN 
5600
 
14 rows selected.
Особенности обработки
Построим в SQL*Plus планы для двух запросов выше:
SET AUTOTRACE TRACEONLY EXPLAIN
SELECT deptno, job, SUM(sal) sum_sal
FROM emp
GROUP BY deptno, job;
SELECT empno, deptno, job, 
SUM(sal) OVER (PARTITION BY deptno, job) sum_sal
FROM emp;
SET AUTOTRACE OFF
Обратим внимание на однопроходность и специальный шаг плана второго запроса (шаг WINDOW).
Разбиение данных на группы для вычислений
Аналитические функции агрегируют данные порциями (partitions; группами), количество и размер которых можно регулировать специальной синтаксической конструкцией. Ниже она указана на примере агрегирующей функции SUM:
SUM(выражение 1) OVER([PARTITION BY выражение 2 [, выражение 3 [, …]]])
Пример использования такой конструкции см. выше.
Если PARTITION BY не указано, то в качестве единственной группы для вычислений будет взят полный набор строк:
SELECT ename, deptno, job, 
SUM(sal) OVER () sum_sal
FROM emp;
Результат последнего запроса:
ENAME DEPTNO JOB SUM_SAL
- - -

SMITH
20
CLERK
29025
<- -  единственная группа,
ALLEN
30
SALESMAN
29025
     и сумма на всех одна
WARD
30
SALESMAN
29025
 
JONES
20
MANAGER
29025
 
MARTIN
30
SALESMAN
29025
 
BLAKE
30
MANAGER
29025
 
CLARK
10
MANAGER
29025
 
SCOTT
20
ANALYST
29025
 
KING
10
PRESIDENT
29025
 
TURNER
30
SALESMAN
29025
 
ADAMS
20
CLERK
29025
 
JAMES
30
CLERK
29025
 
FORD
20
ANALYST
29025
 
MILLER
10
CLERK
29025
 
14 rows selected.
Упорядочение в границах отдельной группы
С помощью синтаксической конструкции ORDER BY строки в группах вычислений можно упорядочивать. Синтаксис иллюстрируется на примере агрегирующей функции SUM:
SUM(выражение 1) OVER([PARTITION …] 
ORDER BY выражение 2 [,…] [{ASC/DESC}] [{NULLS FIRST/NULLS LAST}])
Правила работы ORDER BY - как в обычных SQL-операторах. Пример:
SELECT ename, deptno, job,
SUM(sal) OVER (PARTITION BY deptno, job ORDER BY hiredate) sum_sal
FROM emp;
ENAME             DEPTNO           JOB                            SUM_SAL
-                    -                                   -

MILLER
10
CLERK
1300
 
CLARK
10
MANAGER
2450
 
KING
10
PRESIDENT
5000
 
FORD
20
ANALYST
3000
<- - порядок и сумма изменились
SCOTT
20
ANALYST
6000
 
SMITH
20
CLERK
800
<- - порядок и сумма изменились
ADAMS
20
CLERK
1900
 
JONES
20
MANAGER
2975
 
JAMES
30
CLERK
950
 
BLAKE
30
MANAGER
2850
 
ALLEN
30
SALESMAN
1600
<- - порядок и сумма изменились
WARD
30
SALESMAN
2850
 
TURNER
30
SALESMAN
4350
 
MARTIN
30
SALESMAN
5600
 
14 rows selected.
В группах из более одной строки появился заданный порядок. Природа изменения поля SUM_SAL в пределах групп из нескольких строк станет ясна из следующего раздела.
Выполнение вычислений для строк в группе по плавающему окну (интервалу)
Для некоторых аналитических функций, например, агрегирующих, можно дополнительно указать объем строк, участвующих в вычислении, выполняемом для каждой строки в группе. Этот объем, своего рода контекст строки, называется "окном", а границы окна могут задаваться различными способами.
{ROWS / RANGE} {{UNBOUNDED / выражение} PRECEDING / CURRENT ROW }
{ROWS / RANGE} 
BETWEEN 
{{UNBOUNDED PRECEDING / CURRENT ROW / 
{UNBOUNDED / выражение 1}{PRECEDING / FOLLOWING}} 
AND 
{{UNBOUNDED FOLLOWING / CURRENT ROW / 
{UNBOUNDED / выражение 2}{PRECEDING / FOLLOWING}} 
Фразы PRECEDING и FOLLOWING задают верхнюю и нижнюю границы агрегирования (то есть интервал строк, "окно" для агрегирования).
Вот поясняющий пример, воспроизводящий результат из предыдущего раздела:
SELECT ename, deptno, job,
SUM(sal) 
OVER (PARTITION BY deptno, job ORDER BY hiredate 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sum_sal
FROM emp;
ENAME DEPTNO JOB SUM_SAL
- - -

MILLER
10
CLERK
1300
 
CLARK
10
MANAGER
2450
 
KING
10
PRESIDENT
5000
 
FORD
20
ANALYST
3000
<- - зарплата FORD'а
SCOTT
20
ANALYST
6000 
<- - сумма FORD'а и SCOTT'а
SMITH
20
CLERK
800
<- - зарплата SMITH'а
ADAMS
20
CLERK
1900
<- - сумма SMITH'а и ADAMS'а
JONES
20
MANAGER
2975
 
JAMES
30
CLERK
950
 
BLAKE
30
MANAGER
2850
 
ALLEN
30
SALESMAN
1600 
<- - зарплата ALLEN'а
WARD
30
SALESMAN
2850 
<- - сумма ALLEN'а и WARD'а
TURNER
30
SALESMAN
4350
<- - ALLEN+WARD+TURNER
MARTIN
30
SALESMAN
5600
<- - ALLEN+WARD+TURNER+MARTIN
14 rows selected.
Здесь в пределах каждой группы (использована фраза PARTITION BY) сотрудники упорядочиваются по времени найма на работу (фраза ORDER BY) и для каждого в группе вычисляется сумма зарплат: его и всех его предшественников (фраза ROWS BETWEEN формулирует "окошко суммирования" от первого в группе до текущего рассматриваемого).
Выделенная в последнем запросе жирным цветом фраза подразумевается по умолчанию, если она попросту отсутствует (ср. с запросом из предыдущего раздела).
Обратите внимание, что плавающий интервал задается в терминах упорядоченных строк (ROWS) или значений (RANGE), для чего фраза ORDER BY в определении группы обязана присутствовать.
Формирование интервалов агрегирования "по строкам" и "по значениям"
Разницу между ROWS и RANGE (определяющими, как говорится в документации, "физические" и "логические" интервалы-окна) удобно продемонстрировать следующим примером:
SELECT ename, hiredate, sal,
SUM(sal)
OVER (ORDER BY hiredate
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) rows_sal,
SUM(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) range_sal
FROM emp;
ENAME HIREDATE SAL ROWS_SAL RANGE_SAL
- - - -

SMITH
17-DEC-80
800
800
800
ALLEN
20-FEB-81
1600
2400
2400
WARD
22-FEB-81
1250
3650
3650
JONES
02-APR-81
2975
6625
6625
BLAKE
01-MAY-81
2850
9475
9475
CLARK
09-JUN-81
2450
11925
11925
TURNER
08-SEP-81
1500
13425
13425
MARTIN
28-SEP-81
1250
14675
14675
KING
17-NOV-81
5000
19675
19675
JAMES
03-DEC-81
950
20625
23625
FORD
03-DEC-81
3000
23625
23625
MILLER
23-JAN-82
1300
24925
24925
SCOTT
19-APR-87
3000
27925
27925
ADAMS
23-MAY-87
1100
29025
29025
14 rows selected.
JAMES и FORD поступили на работу одновременно, и с точки зрения интервала суммирования неразличимы. Поэтому суммирование "по значению" присвоило им один и тот же общий для "мини-группы", образованной этой парой, результат - максимальную сумму, которая при всех возможных порядках перечисления сотрудников внутри этой пары будет всегда одинакова. Суммирование "по строкам" (ROWS) поступило иначе: оно упорядочило сотрудников в "мини-группе", образованной равными датами (на самом деле чисто произвольно) и подсчитало суммы, как будто бы у этих сотрудников был задан порядок следования.
Функции FIRST_VALUE и LAST_VALUE для интервалов агрегирования
Эти функции позволяют для каждой строки выдать первое значение ее окна и последнее. Пример:
SELECT ename, hiredate, sal,
FIRST_VALUE(sal)
OVER (ORDER BY hiredate
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) first_rows,
LAST_VALUE(sal)
OVER (ORDER BY hiredate
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) last_rows,
FIRST_VALUE(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN 2 PRECEDING AND CURRENT ROW) first_range,
LAST_VALUE(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN 2 PRECEDING AND CURRENT ROW) last_range 
FROM emp;
ENAME HIREDATE SAL FIRST_ROWS LAST_ROWS FIRST_RANGE LAST_RANGE
-                                               -           -     -

SMITH
17-DEC-80
800
800 
800 
800 
800 
ALLEN
20-FEB-81
1600
800 
1600 
1600 
1600 
WARD
22-FEB-81
1250
800 
1250
1600 
1250
JONES
02-APR-81
2975
1600 
2975 
2975 
2975 
BLAKE
01-MAY-81
2850
1250
2850 
2850 
2850 
CLARK
09-JUN-81
2450
2975
2450
2450
2450
TURNER
08-SEP-81
1500
2850 
1500 
1500 
1500 
MARTIN
28-SEP-81
1250
2450
1250 
1250 
1250 
KING
17-NOV-81
5000
1500
5000 
5000 
5000 
JAMES
03-DEC-81
950
1250 
950 
950 
3000
FORD
03-DEC-81
3000
5000
3000
950 
3000
MILLER
23-JAN-82
1300
950 
1300
1300
1300
SCOTT
19-APR-87
3000
3000 
3000 
3000 
3000 
ADAMS
23-MAY-87
1100
1300
1100
1100
1100
14 rows selected.
Интервалы времени
Для интервалов (окон), упорядоченных внутри по значению ("логическом", RANGE) в случае, если это значение имеет тип "дата", границы интервала можно указывать выражением над датой, а не конкретными значениями из строк. Примеры таких выражений:
INTERVAL число {YEAR / MONTH / DAY / HOUR / MINUTE / SECOND}
NUMTODSINTERVAL(число, '{DAY / HOUR / MINUTE / SECOND}')
NUMTOYMINTERVAL(число, '{YEAR / MONTH}')
Пример выдачи зарплат сотрудников и средних зарплат за последние полгода на момент приема нового сотрудника:
SELECT ename, hiredate, sal,
AVG(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN INTERVAL '6' MONTH PRECEDING AND CURRENT ROW) avg_sal
FROM emp;
ENAME          HIREDATE             SAL            AVG_SAL
-                                  -            -

SMITH
17-DEC-80
800
800
ALLEN
20-FEB-81
1600
1200
WARD
22-FEB-81
1250
1216.66667
JONES
02-APR-81
2975
1656.25
BLAKE
01-MAY-81
2850
1895
CLARK
09-JUN-81
2450
1987.5
TURNER
08-SEP-81
1500
2443.75
MARTIN
28-SEP-81
1250
2205
KING
17-NOV-81
5000
2550
JAMES
03-DEC-81
950
2358.33333
FORD
03-DEC-81
3000
2358.33333
MILLER
23-JAN-82
1300
2166.66667
SCOTT
19-APR-87
3000 
3000 
ADAMS
23-MAY-87
1100
2050
14 rows selected.
Вот другая запись для того же запроса, но позволяющая использовать для числа месяцев обычное числовое выражение:
SELECT ename, hiredate, sal,
AVG(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN NUMTOYMINTERVAL(6, 'MONTH') PRECEDING 
AND CURRENT ROW) avg_sal
FROM emp;
Виды аналических функций
В качестве базовой в аналитической функции могут быть указаны традиционные для Oracle статистические (агрегатные, то есть обобщающие) функции COUNT, MIN, MAX, SUM, AVG и другие ("стандартные агрегатные функции" по документации). Примеры приводились выше. Можно обратить внимание на то, что аналитические функции со статистическими агрегатами разумно обрабатывают NULL:
SELECT ename, hiredate, sal,
AVG(sal)
OVER (ORDER BY hiredate
RANGE BETWEEN UNBOUNDED PRECEDING AND INTERVAL '1' SECOND PRECEDING) avg_sal
FROM emp;
Ниже приводится полный перечень аналитических функций в версии СУБД 9.2:

AVG * 
CORR * 
COVAR_POP * 
COVAR_SAMP * 
COUNT * 
CUME_DIST 
DENSE_RANK 
FIRST 
FIRST_VALUE * 
LAG 
LAST
 
LAST_VALUE * 
LEAD 
MAX * 
MIN * 
NTILE 
PERCENT_RANK 
PERCENTILE_CONT 
PERCENTILE_DISC 
RANK 
RATIO_TO_REPORT
 
REGR_ (вид_функции_линейной_регрессии) * 
ROW_NUMBER 
STDDEV * 
STDDEV_POP * 
STDDEV_SAMP * 
SUM * 
VAR_POP * 
VAR_SAMP * 
VARIANCE 
 
Звездочкой помечены функции, допускающие использование плавающего интервала расчета.
Некоторые из этих функций рассматриваются ниже.
Функции ранжирования
Функции ранжирования позволяют "раздать" строкам "места" в зависимости от имеющихся в них значениях. Некоторые примеры:
SELECT ename, sal, 
            ROW_NUMBER () OVER (ORDER BY sal DESC) AS salbacknumber, 
            ROW_NUMBER () OVER (ORDER BY sal) AS salnumber,
            RANK() OVER (ORDER BY sal) AS salrank,
            DENSE_RANK() OVER (ORDER BY sal) AS saldenserank 
FROM emp;
(раздать сотрудникам места в порядке убывания/возрастания зарплат)
Функции подсчета долей
Функции подсчета долей позволяют одной SQL-операцией получить для каждой строки ее "вес" в таблице в соответствии с ее значениями. Некоторые примеры:
SELECT ename, sal, RATIO_TO_REPORT(sal) OVER () AS salshare FROM emp;
(доли сотрудников в общей сумме зарплат)
Пример выдачи доли сотрудников с меньшей или равной зарплатой, чем у "текущего":
SELECT job, ename, sal, 
CUME_DIST() OVER (PARTITION BY job ORDER BY sal) AS cume_dist
FROM emp;
JOB                       ENAME                      SAL                            CUME_DIST
-                                                   -                     -

ANALYST
SCOTT
3000
1
ANALYST
FORD
3000
1
CLERK
SMITH
800
.25
CLERK
JAMES
950 
.5
CLERK
ADAMS
1100 
.75
CLERK
MILLER
1300
1
MANAGER
CLARK
2450
.333333333
MANAGER
BLAKE
2850 
.666666667
MANAGER
JONES
2975
1
PRESIDENT
KING
5000 
1
SALESMAN
WARD
1250 
.5
SALESMAN
MARTIN
1250 
.5
SALESMAN
TURNER
1500
.75
SALESMAN
ALLEN
1600
1
14 rows selected.
(видно, что три четверти клерков имеют зарплату, меньше чем ADAMS).
Проранжировать эту выдачу по доле сотрудников в группе можно функцией PERCENT_RANK:
SELECT job, ename, sal, 
CUME_DIST() OVER (PARTITION BY job ORDER BY sal) AS cume_dist,
PERCENT_RANK() OVER (PARTITION BY job ORDER BY sal) AS pct_rank
FROM emp;
JOB ENAME SAL CUME_DIST PCT_RANK
- - - -

ANALYST
SCOTT
3000
1
0
ANALYST
FORD
3000
1
0
CLERK
SMITH
800
.25
0
CLERK
JAMES
950
.5
.333333333
CLERK
ADAMS
1100
.75
.666666667
CLERK
MILLER
1300
1
1
MANAGER
CLARK
2450
.333333333
0
MANAGER
BLAKE
2850
.666666667
.5
MANAGER
JONES
2975
1
1
PRESIDENT
KING
5000
1
0
SALESMAN
WARD
1250
.5
0
SALESMAN
MARTIN
1250
.5
0
SALESMAN
TURNER
1500
.75
.666666667
SALESMAN
ALLEN
1600
1
1
14 rows selected.
Процентный ранг отсчитывается от 0 и изменяется до 1.
Некоторые жизненные примеры аналитических запросов
Для типов сегментов, более других расходующих дисковое пространство, выдать главных пользователей, ответственных за такой расход
Построить такой запрос на основе таблицы SYS.DBA_SEGMENTS, можно пошагово.
Шаг 1. Выдать типы сегментов в БД, общий объем памяти на диске для каждого типа и долю числа типов с равным или меньшим общим объемом памяти:
SELECT segment_type, 
      SUM(bytes) bytes,
      CUME_DIST() OVER (ORDER BY SUM(bytes)) bytes_percentile
      FROM sys.dba_segments
      GROUP BY segment_type;
Шаг 2. Отобрать 40% "наиболее расточительных" по дисковой памяти типов:
SELECT * 
FROM
(SELECT segment_type, 
SUM(bytes) bytes,
CUME_DIST() OVER (ORDER BY SUM(bytes)) bytes_percentile
FROM sys.dba_segments
GROUP BY segment_type)
WHERE bytes_percentile >= 0.5;
Шаг 3. Отобрать пользователей, занимающих первые пять мест по расходованию памяти среди "наиболее расточительных" типов сегментов:
SELECT * 
FROM
(
SELECT owner,
        SUM(bytes) bytes,
        RANK() OVER(ORDER BY SUM(bytes) DESC) bytes_rank
FROM sys.dba_segments
WHERE segment_type IN
      (SELECT segment_type
        FROM
           (SELECT segment_type, 
                SUM(bytes) bytes,
                CUME_DIST() OVER (ORDER BY SUM(bytes)) bytes_percentile
                FROM sys.dba_segments
                GROUP BY segment_type)
        WHERE bytes_percentile >= 0.5)
GROUP BY owner
)
WHERE bytes_rank <=5
/
Выдать список периодов наиболее активного переключения журнальных файлов БД
Список переключений журнальных файлов хранится в динамической таблице v$loghist. Ниже приводится один из вариантов запроса.
var treshold number
exec :treshold := 30
alter session set nls_date_format='MON-DD HH24:MI:SS';
SELECT 
start_time,
end_time,
ROUND((end_time - start_time)*24*60, 2) delta_min,
switches,
switches / ((end_time - start_time)*24*60) per_minute
FROM
(
SELECT
MIN(time_stamp) start_time,
MAX(time_stamp) end_time,
count (*) switches
FROM
(
SELECT time_stamp, freq10, more,
SUM(ABS(indicator)) OVER (ORDER BY time_stamp) part
FROM
(
SELECT time_stamp, freq10,
SIGN(freq10 - :treshold - 0.5) more,
SIGN(freq10 - :treshold - 0.5) - LAG(SIGN(freq10 - :treshold - 0.5), 1)
OVER (ORDER BY time_stamp) indicator
FROM
(
SELECT first_time time_stamp,
GREATEST(
COUNT(*)
OVER (ORDER BY first_time
RANGE BETWEEN CURRENT ROW AND INTERVAL '10' MINUTE FOLLOWING)
,
COUNT(*)
OVER (ORDER BY first_time
RANGE BETWEEN INTERVAL '10' MINUTE PRECEDING AND CURRENT ROW)
) freq10
FROM v$loghist
) /* frequency table */
) /* frequency treshold overcome table */
) /* transient partitioned table */
WHERE more > 0
GROUP BY part
)
WHERE (end_time - start_time)*24*60 > 0 
/
Пояснения
Фактически проверяется не частота переключений журнальных файлов, а частота фиксации первого изменения в журнальных файлах. Это не совсем одно и то же, но, похоже, сильно коррелирующие события. 
Результат получается в несколько проходов. Сначала для каждой записи проверяется средняя активность переключений в 10-минутные предшествующий и последующий интервалы. Затем выбираются записи, для которых средняя активность превышает порог :treshold = 30 в минуту. Затем размечаются точки перехода через порог, которые далее служат границами групп "повышенной" и "пониженной" активности. Потом интервалы с повышенной активностью выдаются на экран.