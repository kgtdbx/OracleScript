-- create a temporary table for this example
CREATE TABLE emp_temp AS SELECT * FROM employees;

DECLARE
   TYPE empid_tab IS TABLE OF employees.employee_id%TYPE;
   emp_sr empid_tab;
-- create an exception handler for ORA-24381
   errors NUMBER;
   dml_errors EXCEPTION;
   PRAGMA EXCEPTION_INIT(dml_errors, -24381);
BEGIN
   SELECT employee_id BULK COLLECT INTO emp_sr FROM emp_temp 
         WHERE hire_date < '30-DEC-94';
-- add '_SR' to the job_id of the most senior employees
     FORALL i IN emp_sr.FIRST..emp_sr.LAST SAVE EXCEPTIONS
       UPDATE emp_temp SET job_id = job_id || '_SR' 
          WHERE emp_sr(i) = emp_temp.employee_id;
-- If any errors occurred during the FORALL SAVE EXCEPTIONS,
-- a single exception is raised when the statement completes.

EXCEPTION
  WHEN dml_errors THEN -- Now we figure out what failed and why.
   errors := SQL%BULK_EXCEPTIONS.COUNT;
   DBMS_OUTPUT.PUT_LINE('Number of statements that failed: ' || errors);
   FOR i IN 1..errors LOOP
      DBMS_OUTPUT.PUT_LINE('Error #' || i || ' occurred during '|| 
         'iteration #' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX); 
          DBMS_OUTPUT.PUT_LINE('Error message is ' ||
          SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
   END LOOP;
END;
/
DROP TABLE emp_temp;