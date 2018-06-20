SELECT  sysdate as "Date" FROM dual;
SELECT CURRENT_DATE FROM dual;--current date in the session time zone
-----------
/* 
SELECT  department_name||q'[ Department's Meneger Id: ]'||manager_id AS "Department and Meneger"
FROM departments;
*/
----------
SELECT employee_id, job_id, salary, commission_pct
FROM employees
ORDER BY commission_pct DESC NULLS LAST;
----------
accept job_title prompt 'Enter job identificator: ' --e.g. IT_PROG
SELECT last_name, department_id, salary*12
FROM   employees
WHERE  job_id = '&job_title';
-----------------
SELECT   employee_id, last_name, job_id, &&column_name
FROM     employees
ORDER BY &column_name ;
-----------------
DEFINE employee_num = 200

SELECT employee_id, last_name, salary, department_id
FROM   employees
WHERE  employee_id = &employee_num ;

UNDEFINE employee_num
-----------------
--SET DEFINE OFF
SELECT 	job_id, last_name
FROM		employees
WHERE		UPPER(job_id) like UPPER('%&job_title%')
ORDER BY	job_id, last_name
--SET DEFINE ON
------------
SET VERIFY ON;--show sql script in script output 
--SET VERIFY OFF;--hide

SELECT employee_id, last_name, salary, department_id
FROM   employees
WHERE  employee_id = &employee_num ;
------------

SELECT	last_name, TO_CHAR(hire_date, 'fmddth "of" Month YYYY fmHH:MI:SS AM')
FROM	employees
WHERE department_id IN (10, 80)
/
------------
select	last_name, decode( to_char(hire_date, 'Q'),
	        1, 'First quarter of ',
	        2, 'Second quarter of ',
	        3, 'Third quarter of ',
	        4, 'Last quarter of '
 ) || to_char(hire_date, 'YYYY') quarter_of_the_year,
              trunc(months_between(sysdate, hire_date)) "#_of_months"
from employees
order by 3 desc 
/
-----------------
SELECT location_id, department_name "Department", 
   TO_CHAR(NULL) "Warehouse location"  
FROM departments
UNION
SELECT location_id, TO_CHAR(NULL) "Department", 
   state_province
FROM locations;
------------------
SELECT employee_id, last_name, job_id
FROM   employees WHERE  job_id LIKE '%SA\_%' ESCAPE '\';
------------------'
SELECT last_name FROM employees
WHERE  employee_id NOT IN
                        (SELECT manager_id 
                         FROM   employees 
                         WHERE  manager_id IS NOT NULL);
--------------------
SELECT employee_id, hire_date,
	MONTHS_BETWEEN (SYSDATE, hire_date) TENURE,
	ADD_MONTHS (hire_date, 6) REVIEW,
	NEXT_DAY (hire_date, 'FRIDAY'), LAST_DAY(hire_date)
FROM   employees
WHERE  MONTHS_BETWEEN (SYSDATE, hire_date) < 150;
-----------------
SELECT em.last_name, em.salary 
FROM employees em
WHERE em.employee_id NOT BETWEEN 5000 and 12000;
-----------------
SELECT   TO_CHAR(NEXT_DAY(ADD_MONTHS
         (hire_date, 6), 'FRIDAY'),
         'fmDay, Month ddth, YYYY')
         "Next 6 Month Review"
FROM      employees
ORDER BY  hire_date;
-----------------
SELECT 	TO_CHAR(ROUND((salary/7), 2),'99G999D99', 
	'NLS_NUMERIC_CHARACTERS = '',.'' ') 
	"Formatted Salary"
FROM employees;
-----------------
SELECT last_name,  salary, commission_pct,
       NVL2(commission_pct, 
       'SAL+COMM', 'SAL') income
FROM   employees WHERE department_id IN (50, 80);
-----------------
SELECT first_name, LENGTH(first_name) "expr1", 
       last_name,  LENGTH(last_name)  "expr2",
       NULLIF(LENGTH(first_name), LENGTH(last_name)) result
FROM   employees;
-----------------
SELECT last_name, employee_id,
COALESCE(TO_CHAR(commission_pct),TO_CHAR(manager_id),
	'No commission and no manager') 
FROM employees;
-----------------
SELECT last_name, salary, commission_pct,
 COALESCE((salary+(commission_pct*salary)), salary+2000, salary) "New Salary"
FROM   employees;




col table_name_stg for a30
col table_name_arc for a30
col load_batch_name for a15
col banking_day_filter for a40
set lines 500
SET LINESIZE 150
SET PAGESIZE 150
						 
						 
