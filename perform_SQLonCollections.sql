--SQL on Collections
/*
https://livesql.oracle.com/apex/livesql/file/content_CST3SOEGRI58LR5EDXYTVZSCJ.html

Description
"Hi Steven, what is the best way to perform operations like SELECT a, SUM(b) from t GROUP BY a that work great on tables, but on PLSQL collections? I know that we can do this by using loops, but I would like to have someting as expressive as SQL on the PLSQL collection. Is there a way to get this?" Oh, yeah!
Category
PL/SQL General
Contributor
Steven Feuerstein (Oracle)
Created
Friday January 29, 2016
*/
--Statement 1
create type ot is object (
   employee_id integer,
   last_name varchar2(100),
   department_id integer,
   salary number)
Type created.

--Statement 2
create type nt is table of ot
Type created.

--Statement 3
declare
   emps nt;
begin
   select ot (employee_id, last_name, department_id, salary) 
     bulk collect into emps
     from hr.employees;
     
   for rec in (
   select d.department_name, sum (e.salary) total_salary
     from hr.departments d, table (emps) e
    where d.department_id = e.department_id
    group by d.department_name)
   loop
       dbms_output.put_line (rec.department_name || ' - ' || rec.total_salary);
   end loop;
end;

Administration - 4400
Accounting - 20308
Purchasing - 24900
Human Resources - 6500
IT - 28800
Public Relations - 10000
Executive - 58000
Shipping - 156400
Sales - 304500
Finance - 51608
Marketing - 19000