/*
Converting from Row-by-Row to Bulk ProcessingView All Scripts Login and Run Script
https://livesql.oracle.com/apex/livesql/file/content_CTTBPHPA7VN2O8P88VB80Y4AB.html

Script Name
Converting from Row-by-Row to Bulk Processing
Description
This script offers a before-and-after look: first, we have row-by-row (slow-by-slow, in the immortal words of Tom Kyte) processing with multiple DML statements inside a loop. Next we have a bulkified version, relying on BULK COLLECT and FORALL to improve performance. Notice the use of nested subprograms in the after version, to improve readability.
Category
PL/SQL General
Contributor
Steven Feuerstein (Oracle)
Created
Thursday February 04, 2016
*/

--Statement 1
CREATE TABLE employees AS SELECT * FROM hr.employees 
Table created.
--Statement 2
CREATE TABLE employee_history ( 
    id NUMBER GENERATED ALWAYS AS IDENTITY, /* 12.1 and above */ 
    employee_id NUMBER,  
    salary NUMBER,  
    hire_date DATE, 
    created_on DATE DEFAULT SYSDATE, 
    created_by VARCHAR(128) DEFAULT USER) 
Table created.
--Statement 3
/*
You would, of course, have something much more robust.
"Stub" Program Displays Error Info
*/
CREATE OR REPLACE PROCEDURE log_error (  
   msg_in    IN VARCHAR2 DEFAULT DBMS_UTILITY.format_error_stack  
 , code_in   IN PLS_INTEGER DEFAULT SQLCODE)  AUTHID DEFINER 
IS  
BEGIN  
   -- A "stub" program that simply displays the error information.  
   DBMS_OUTPUT.put_line ('Error message: ' || msg_in);  
   DBMS_OUTPUT.put_line ('Error code: ' || code_in);  
END log_error; 
Procedure created.
--Statement 4
/*
The point here is that you need to do some "fancy" processing in PL/SQL that could not be (easily) done in SQL - thus, rather than rely on "pure" SQL to perform your bulk DML,
you will need to use BULK COLLECT and FORALL.
Another "Placeholder" Program
*/

CREATE OR REPLACE PROCEDURE adjust_compensation (  
   id_in       IN     employees.employee_id%TYPE  
 , sal_inout   IN OUT employees.salary%TYPE)  
IS  
BEGIN  
   /* Really complex stuff */  
   NULL;  
END adjust_compensation; 
Procedure created.

--Statement 5
/*
For each employee in department, give them the new salary. First, though, record the previous salary in the history table. 
Then call adjust_compensation to perform some incredibly complicated, procedural logic that may modify the new salary. Then do the update. 
Notice that if the insert fails, you never get to the update. And if either fails, you log the error and then continue.
The "Before" Version
*/
CREATE OR REPLACE PROCEDURE upd_for_dept (  
   dept_in     IN employees.department_id%TYPE  
 , newsal_in   IN employees.salary%TYPE) AUTHID DEFINER 
IS  
   CURSOR emp_cur  
   IS  
      SELECT employee_id, salary, hire_date  
        FROM employees  
       WHERE department_id = dept_in 
         FOR UPDATE;  
BEGIN  
   FOR rec IN emp_cur  
   LOOP  
      BEGIN  
         INSERT INTO employee_history (employee_id, salary, hire_date)  
              VALUES (rec.employee_id, rec.salary, rec.hire_date);  
  
         rec.salary := newsal_in;  
  
         adjust_compensation (rec.employee_id, rec.salary);  
  
         UPDATE employees  
            SET salary = rec.salary  
          WHERE employee_id = rec.employee_id;  
      EXCEPTION  
         WHEN OTHERS  
         THEN  
            log_error;  
      END;  
   END LOOP;  
END upd_for_dept; 
Procedure created.

--Statement 6
/*
Much longer, more complicated code. That's the price we pay to take advantage of the fantastic bulk features.
The After Version
*/
CREATE OR REPLACE PROCEDURE upd_for_dept (  
   dept_in         IN employees.department_id%TYPE  
 ,  newsal_in       IN employees.salary%TYPE  
 ,  bulk_limit_in   IN PLS_INTEGER DEFAULT 100) AUTHID DEFINER  
IS  
   bulk_errors   EXCEPTION;  
   PRAGMA EXCEPTION_INIT (bulk_errors, -24381);  
  
   CURSOR employees_cur  
   IS  
      SELECT employee_id, salary, hire_date  
        FROM employees  
       WHERE department_id = dept_in  
      FOR UPDATE;  
  
   TYPE employees_tt IS TABLE OF employees_cur%ROWTYPE  
                           INDEX BY PLS_INTEGER;  
  
   l_employees   employees_tt;  
  
   PROCEDURE adj_comp_for_arrays  
   IS  
      l_index   PLS_INTEGER := l_employees.FIRST;   
  
      PROCEDURE adjust_compensation (  
         id_in       IN INTEGER  
       ,  salary_in   IN NUMBER)  
      IS  
      BEGIN  
         NULL;  
      END;  
   BEGIN  
      WHILE (l_index IS NOT NULL)  
      LOOP  
         adjust_compensation (  
            l_employees (l_index).employee_id  
          ,  l_employees (l_index).salary);  
         l_index := l_employees.NEXT (l_index);  
      END LOOP;  
   END adj_comp_for_arrays;  
  
   PROCEDURE insert_history  
   IS  
   BEGIN  
      FORALL indx IN 1 .. l_employees.COUNT SAVE EXCEPTIONS  
         INSERT  
           INTO employee_history (employee_id  
                                ,  salary  
                                ,  hire_date)  
         VALUES (  
                   l_employees (indx).employee_id  
                 ,  l_employees (indx).salary  
                 ,  l_employees (indx).hire_date);  
   EXCEPTION  
      WHEN bulk_errors  
      THEN  
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT  
         LOOP  
            log_error (  
                  l_employees (  
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id  
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);  
 
            l_employees.delete (  
               SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);  
         END LOOP;  
   END insert_history;  
  
   PROCEDURE update_employees  
   IS  
   BEGIN  
      FORALL indx IN INDICES OF l_employees  
        SAVE EXCEPTIONS  
         UPDATE employees  
            SET salary = l_employees (indx).salary  
              ,  hire_date = l_employees (indx).hire_date  
          WHERE employee_id =  
                   l_employees (indx).employee_id;  
   EXCEPTION  
      WHEN bulk_errors  
      THEN  
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT  
         LOOP  
            log_error (  
                  l_employees (  
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id  
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);  
         END LOOP;  
   END update_employees;  
BEGIN  
   OPEN employees_cur;  
  
   LOOP  
      FETCH employees_cur  
      BULK COLLECT INTO l_employees  
      LIMIT bulk_limit_in;  
  
      EXIT WHEN l_employees.COUNT = 0;  
  
      insert_history;  
      adj_comp_for_arrays;  
      update_employees;  
   END LOOP;  
END upd_for_dept;
Procedure created.
--Statement 7
/*
To take things further, what if the current (non-bulk) code not only skips the update if the insert fails, but also rolls back to the insert if the update fails? 
How do we do the same thing with bulk processing?
Using Savepoint to Reverse Insert if Update Fails
*/

CREATE OR REPLACE PROCEDURE upd_for_dept ( 
   dept_in     IN employees.department_id%TYPE, 
   newsal_in   IN employees.salary%TYPE) 
IS 
   CURSOR emp_cur 
   IS 
      SELECT employee_id, salary, hire_date 
        FROM employees 
       WHERE department_id = dept_in; 
BEGIN 
   FOR rec IN emp_cur 
   LOOP 
      BEGIN 
         SAVEPOINT before_insert; 
 
         INSERT 
           INTO employee_history (employee_id, salary, hire_date) 
         VALUES (rec.employee_id, rec.salary, rec.hire_date); 
 
         rec.salary := newsal_in; 
 
         adjust_compensation (rec.employee_id, rec.salary); 
 
         UPDATE employees 
            SET salary = rec.salary 
          WHERE employee_id = rec.employee_id; 
      EXCEPTION 
         WHEN OTHERS 
         THEN 
            ROLLBACK TO before_insert; 
            log_error; 
      END; 
   END LOOP; 
END upd_for_dept;
Procedure created.
--Statement 8
--Match Behavior with Savepoint to Reverse Insert

CREATE OR REPLACE PROCEDURE upd_for_dept (  
   dept_in         IN employees.department_id%TYPE,  
   newsal_in       IN employees.salary%TYPE,  
   bulk_limit_in   IN PLS_INTEGER DEFAULT 100)  
IS  
   bulk_errors   EXCEPTION;  
   PRAGMA EXCEPTION_INIT (bulk_errors, -24381);  
  
   CURSOR employees_cur  
   IS  
      SELECT employee_id, salary, hire_date  
        FROM employees  
       WHERE department_id = dept_in  
      FOR UPDATE;  
  
   TYPE employees_tt IS TABLE OF employees_cur%ROWTYPE  
      INDEX BY PLS_INTEGER;  
  
   l_employees   employees_tt;  
  
   TYPE inserted_rt IS RECORD  
   (  
      id            employee_history.id%TYPE,  
      employee_id   employee_history.employee_id%TYPE  
   );  
  
   TYPE inserted_t IS TABLE OF inserted_rt;  
  
   l_inserted    inserted_t := inserted_t ();  
  
   PROCEDURE adj_comp_for_arrays  
   IS  
      l_index   PLS_INTEGER;  
  
      PROCEDURE adjust_compensation (id_in IN INTEGER, salary_in IN NUMBER)  
      IS  
      BEGIN  
         NULL;  
      END;  
   BEGIN  
      l_index := l_employees.FIRST;  
  
      WHILE (l_index IS NOT NULL)  
      LOOP  
         adjust_compensation (l_employees (l_index).employee_id,  
                              l_employees (l_index).salary);  
         l_index := l_employees.NEXT (l_index);  
      END LOOP;  
   END adj_comp_for_arrays;  
  
   PROCEDURE insert_history  
   IS  
   BEGIN  
      FORALL indx IN 1 .. l_employees.COUNT SAVE EXCEPTIONS  
         INSERT INTO employee_history (employee_id, salary, hire_date)  
                 VALUES (  
                           l_employees (indx).employee_id,  
                           l_employees (indx).salary,  
                           l_employees (indx).hire_date)  
      RETURNING id, employee_id BULK COLLECT INTO l_inserted;  
   EXCEPTION  
      WHEN bulk_errors  
      THEN  
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT  
         LOOP  
            log_error (  
                  l_employees (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id,  
               SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);  
            /*  
            Communicate this failure to the update phase:  
            Delete this row so that the update will not take place.  
            */  
            l_employees.delete (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);  
         END LOOP;  
   END insert_history;  
  
   PROCEDURE remove_history_row (  
      employee_id_in   IN employees.employee_id%TYPE)  
   IS  
      l_found_index   INTEGER;  
      l_index         INTEGER := l_inserted.FIRST;  
   BEGIN  
      /* Find matching element in l_inserted, and remove */  
  
      WHILE l_found_index IS NULL AND l_index IS NOT NULL  
      LOOP  
         IF l_inserted (l_index).employee_id = employee_id_in  
         THEN  
            l_found_index := l_index;  
         ELSE  
            l_index := l_inserted.NEXT (l_index);  
         END IF;  
      END LOOP;  
  
      IF l_found_index IS NOT NULL  
      THEN  
         DELETE FROM employee_history  
               WHERE id = l_inserted (l_found_index).id;  
      END IF;  
   END;  
  
   PROCEDURE update_employees  
   IS  
   BEGIN  
      FORALL indx IN INDICES OF l_employees SAVE EXCEPTIONS  
         UPDATE employees  
            SET salary = l_employees (indx).salary,  
                hire_date = l_employees (indx).hire_date  
          WHERE employee_id = l_employees (indx).employee_id;  
   EXCEPTION  
      WHEN bulk_errors  
      THEN  
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT  
         LOOP  
            remove_history_row (  
               l_employees (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id);  
  
            log_error (  
                  l_employees (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id,  
               SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);  
         END LOOP;  
   END update_employees;  
BEGIN  
   OPEN employees_cur;  
  
   LOOP  
      FETCH employees_cur BULK COLLECT INTO l_employees LIMIT bulk_limit_in;  
  
      EXIT WHEN l_employees.COUNT = 0;  
  
      insert_history;  
      adj_comp_for_arrays;  
      update_employees;  
   END LOOP;  
END upd_for_dept; 
Procedure created.