--Comparison of performance of implicit and explicit cursors
--https://livesql.oracle.com/apex/livesql/file/content_FZPPPV0PPWPPXKRO6GXUTJGGO.html
/*
Description
Implicit cursors generally run faster than explicit cursors - when a row is found. When a row is not found, a SELECT-INTO raises NO_DATA_FOUND, which slows things down considerably. Bottom line: when you expect to almost always find a row, use SELECT-INTO. When you expect to often NOT find a row, go with OPEN-FETCH-CLOSE.
Category
PL/SQL General
Contributor
Steven Feuerstein (Oracle)
Created
Friday December 15, 2017
*/
--Statement 1
CREATE OR REPLACE PACKAGE tmr 
IS 
   PROCEDURE start_timer; 
 
   PROCEDURE show_elapsed (str IN VARCHAR2); 
END tmr; 
Package created.

--Statement 2
CREATE OR REPLACE PACKAGE BODY tmr 
IS 
   last_timing   NUMBER := NULL; 
 
   PROCEDURE start_timer 
   IS 
   BEGIN 
      last_timing := DBMS_UTILITY.get_time; 
   END; 
 
   PROCEDURE show_elapsed (str IN VARCHAR2) 
   IS 
   BEGIN 
      DBMS_OUTPUT.put_line ( 
            str 
         || ': ' 
         || MOD (DBMS_UTILITY.get_time - last_timing + POWER (2, 32), 
                 POWER (2, 32))); 
      start_timer; 
   END; 
END tmr; 
Package Body created.

--Statement 3
CREATE TABLE not_much_stuff (n NUMBER)
Table created.

--Statement 4
INSERT INTO not_much_stuff
       SELECT LEVEL
         FROM DUAL
   CONNECT BY LEVEL < 11
10 row(s) inserted.

--Statement 5
--Demonstration of Exception Behavior with SELECT-INTO

DECLARE 
   my_n   not_much_stuff.n%TYPE; 
BEGIN 
   DBMS_OUTPUT.put_line ('No rows found:'); 
 
   BEGIN 
      SELECT n 
        INTO my_n 
        FROM not_much_stuff 
       WHERE n = -1; 
   EXCEPTION 
      WHEN NO_DATA_FOUND 
      THEN 
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack); 
   END; 
 
   DBMS_OUTPUT.put_line ('Too many rows found:'); 
 
   BEGIN 
      SELECT n 
        INTO my_n 
        FROM not_much_stuff 
       WHERE n BETWEEN 1 AND 10; 
   EXCEPTION 
      WHEN TOO_MANY_ROWS 
      THEN 
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack); 
   END; 
END;
No rows found:
ORA-01403: no data found

Too many rows found:
ORA-01422: exact fetch returns more than requested number of rows

--Statement 6
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
BEGIN    
   tmr.start_timer; 
   FOR indx IN 1 .. 10000 
   LOOP 
      BEGIN 
         SELECT n 
           INTO my_n 
           FROM not_much_stuff 
          WHERE n = -1; 
 
         my_n := 100; 
      EXCEPTION 
         WHEN NO_DATA_FOUND 
         THEN 
            my_n := 100; 
      END; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('Implicit Failure'); 
END;
100
Implicit Failure: 56

--Statement 7
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
BEGIN 
   tmr.start_timer; 
 
   FOR indx IN 1 .. 10000 
   LOOP 
      BEGIN 
         SELECT n 
           INTO my_n 
           FROM not_much_stuff 
          WHERE n = 1; 
 
         my_n := 100; 
      EXCEPTION 
         WHEN NO_DATA_FOUND 
         THEN 
            my_n := 100; 
      END; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('Implicit Success'); 
END;
100
Implicit Success: 34

--Statement 8
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
 
   CURSOR stuff_cur 
   IS 
      SELECT n 
        FROM not_much_stuff 
       WHERE n = -1; 
BEGIN 
   tmr.start_timer; 
 
   FOR indx IN 1 .. 10000 
   LOOP 
      OPEN stuff_cur; 
 
      FETCH stuff_cur INTO my_n; 
 
      IF stuff_cur%NOTFOUND 
      THEN 
         my_n := 100; 
      END IF; 
 
      CLOSE stuff_cur; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('Explicit Failure'); 
END;
100
Explicit Failure: 46

--Statement 9
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
 
   CURSOR stuff_cur 
   IS 
      SELECT n 
        FROM not_much_stuff 
       WHERE n = 1; 
BEGIN 
   tmr.start_timer; 
 
   FOR indx IN 1 .. 10000 
   LOOP 
      OPEN stuff_cur; 
 
      FETCH stuff_cur INTO my_n; 
 
      IF stuff_cur%FOUND 
      THEN 
         my_n := 100; 
      END IF; 
 
      CLOSE stuff_cur; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('Explicit Success'); 
END;
100
Explicit Success: 33

--Statement 10
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
BEGIN 
   tmr.start_timer; 
 
   FOR indx IN 1 .. 10000 
   LOOP 
      FOR rec IN (SELECT n 
                    FROM not_much_stuff 
                   WHERE n = -1) 
      LOOP 
         my_n := rec.n; 
      END LOOP; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('CFL Failure'); 
END;
CFL Failure: 33

--Statement  11
DECLARE 
   my_n   not_much_stuff.n%TYPE; 
BEGIN 
   tmr.start_timer; 
 
   FOR indx IN 1 .. 10000 
   LOOP 
      FOR rec IN (SELECT n 
                    FROM not_much_stuff 
                   WHERE n = 1) 
      LOOP 
         my_n := rec.n; 
      END LOOP; 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (my_n); 
 
   tmr.show_elapsed ('CFL Success'); 
END;
1
CFL Success: 38

--Statement 12
--1. Implicit cursor inside a nested block

CREATE OR REPLACE PROCEDURE do_stuff_with_employee (  
   employee_id_in   IN hr.employees.employee_id%TYPE)  
IS  
   l_name   hr.employees.last_name%TYPE;  
BEGIN  
   BEGIN  
      SELECT last_name  
        INTO l_name  
        FROM hr.employees e  
       WHERE e.employee_id = do_stuff_with_employee.employee_id_in;  
   EXCEPTION  
      WHEN NO_DATA_FOUND  
      THEN  
         /* log the error if this really is an error or let it go... */  
         l_name := NULL;  
   END;  
  
   IF l_name IS NOT NULL  
   THEN  
      /* continue with application logic */  
      NULL;  
   END IF;  
END; 
Procedure created.

--Statement 13
--2. Implicit cursor inside a nested subprogram

CREATE OR REPLACE PROCEDURE do_stuff_with_employee (  
   employee_id_in   IN hr.employees.employee_id%TYPE)  
IS  
   l_name   hr.employees.last_name%TYPE;  
  
   FUNCTION emp_name (employee_id_in IN hr.employees.employee_id%TYPE)  
      RETURN hr.employees.last_name%TYPE  
   IS  
      l_name   hr.employees.last_name%TYPE;  
   BEGIN  
      SELECT last_name  
        INTO l_name  
        FROM hr.employees  
       WHERE employee_id = employee_id_in;  
  
      RETURN l_name;  
   EXCEPTION  
      WHEN NO_DATA_FOUND  
      THEN  
         /* log the error if this really is an error or let it go... */  
         RETURN NULL;  
   END;  
BEGIN  
   l_name := emp_name (employee_id_in);  
  
   IF l_name IS NOT NULL  
   THEN  
      /* continue with application logic */  
      NULL;  
   END IF;  
END; 
Procedure created.

--Statement 14
--3. Explicit cursor unconcerned with too many rows

CREATE OR REPLACE PROCEDURE do_stuff_with_employee (  
   employee_id_in   IN hr.employees.employee_id%TYPE)  
IS  
   l_name   hr.employees.last_name%TYPE;  
  
   CURSOR name_cur  
   IS  
      SELECT last_name  
        FROM hr.employees e  
       WHERE e.employee_id = do_stuff_with_employee.employee_id_in;  
BEGIN  
   OPEN name_cur;  
  
   FETCH name_cur INTO l_name;  
  
   CLOSE name_cur;  
  
   IF l_name IS NOT NULL  
   THEN  
      /* continue with application logic */  
      NULL;  
   END IF;  
END; 
Procedure created.

--Statement 15
--4. Explicit cursor that checks for too many rows

CREATE OR REPLACE PROCEDURE do_stuff_with_employee (  
   employee_id_in   IN hr.employees.employee_id%TYPE)  
IS  
   l_name    hr.employees.last_name%TYPE;  
   l_name2   hr.employees.last_name%TYPE;  
  
   CURSOR name_cur  
   IS  
      SELECT last_name  
        FROM hr.employees e  
       WHERE e.employee_id = do_stuff_with_employee.employee_id_in;  
BEGIN  
   OPEN name_cur;  
  
   FETCH name_cur INTO l_name;  
  
   FETCH name_cur INTO l_name2;  
  
   IF name_cur%FOUND  
   THEN  
      CLOSE name_cur;  
  
      RAISE TOO_MANY_ROWS;  
   ELSE  
      CLOSE name_cur;  
   END IF;  
  
   IF l_name IS NOT NULL  
   THEN  
      /* continue with application logic */  
      NULL;  
   END IF;  
END; 
Procedure created.