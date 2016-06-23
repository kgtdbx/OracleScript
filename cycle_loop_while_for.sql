-------------loop----------------------------
SET serveroutput ON
DECLARE
  i   NUMBER :=100;
  cnt NUMBER :=0;
  emp_rec emp_test%rowtype;
BEGIN
  LOOP
    SELECT * INTO emp_rec
    FROM employees
    WHERE employee_id = i;
    INSERT INTO emp_test VALUES emp_rec;
  cnt:= cnt + sql%rowcount;
  i:= i + 1;
    EXIT WHEN i = 200;
  END LOOP;
  dbms_output.put_line(cnt||' values inserted');
END;
--select * from emp_test;
----------while---------------------------------
SET serveroutput ON
DECLARE
  i NUMBER :=150;
  emp_rec emp_test%rowtype;
  cnt NUMBER :=0;
BEGIN
  WHILE i < 300
  LOOP
    SELECT * INTO emp_rec
    FROM employees
    WHERE employee_id = i;
      UPDATE emp_test
      SET row = emp_rec
      WHERE employee_id = i;
  cnt := cnt + sql%rowcount;
  i :=i +1;
   EXIT WHEN i = 200;
  END LOOP;
  dbms_output.put_line(cnt||' values updated');
EXCEPTION
WHEN no_data_found THEN
  NULL;
END;
-----------------for-------------------------------
SET serveroutput ON
DECLARE
  v_start   NUMBER := 100;
  v_finish  NUMBER := 150;
  cnt       NUMBER := 0;
  emp_rec   emp_test%rowtype;
BEGIN
  FOR i IN v_start.. v_finish LOOP
    SELECT * INTO emp_rec
    FROM employees
    WHERE employee_id = i;
    INSERT INTO emp_test VALUES emp_rec;
  cnt:= cnt + sql%rowcount;
--    EXIT WHEN i = 200;
  END LOOP;
  dbms_output.put_line(cnt||' values inserted');
END;
