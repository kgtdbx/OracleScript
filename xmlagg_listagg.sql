with x as
(
	select 'four' as a, 4 as b from dual
	union all select 'two', 2 from dual
	union all select 'one', 1 from dual
	union all select 'three', 3 from dual
)
select wm_concat(a) over (order by b) a
	from x
	
------------------	
	select xmlagg(xmlelement(col, table_name||',') order by table_name).extract('/COL/text()').getclobval()  
from all_tables
group by owner;

---------------
select wm_concat(a) 
 from (select a from x order by b)
 
 ----------------
 
 listagg(...)within group(order by ...) 
 
LISTAGG Analytic Function in 11g Release 2
The LISTAGG analytic function was introduced in Oracle 11g Release 2, making it very easy to aggregate strings. The nice thing about this function is it also allows us to order the elements in the concatenated list. If you are using 11g Release 2 you should use this function for string aggregation.

COLUMN employees FORMAT A50

SELECT deptno, LISTAGG(ename, ',') WITHIN GROUP (ORDER BY ename) AS employees
FROM   emp
GROUP BY deptno;

    DEPTNO EMPLOYEES
---------- --------------------------------------------------
        10 CLARK,KING,MILLER
        20 ADAMS,FORD,JONES,SCOTT,SMITH
        30 ALLEN,BLAKE,JAMES,MARTIN,TURNER,WARD

3 rows selected.
 
 
 
 --###############--
 The SQL:

SELECT department_id
     , LISTAGG(employee_id, ',')
         WITHIN GROUP (ORDER BY employee_id) 
         AS employees
FROM   employees
GROUP BY department_id;
When executed:

SQL> SELECT department_id
  2       , LISTAGG(employee_id, ',')
  3           WITHIN GROUP (ORDER BY employee_id)
  4           AS employees
  5  FROM   employees
  6  GROUP BY department_id;

DEPARTMENT_ID EMPLOYEES
------------- ---------------------------------------
           10 200
           20 201,202
           30 114,115,116,117,118,119
           40 203
           50 120,121,122,123,124,125,126,127,128,129
           
----------

