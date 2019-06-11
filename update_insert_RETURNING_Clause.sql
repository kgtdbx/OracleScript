Use RETURNING Clause to Avoid Unnecessary SQL Statements
http://stevenfeuersteinonplsql.blogspot.com/2019/04/use-returning-clause-to-avoid.html

April 29, 2019
The RETURNING clause allows you to retrieve values of columns (and expressions based on columns) that were modified by an insert, delete or update. Without RETURNING you would have to run a SELECT statement after the DML statement is completed, in order to obtain the values of the changed columns. So RETURNING helps avoid another roundtrip to the database, another context switch in a PL/SQL block.

The RETURNING clause can return multiple rows of data, in which case you will use the RETURNING BULK COLLECT INTO form.

You can also call aggregate functions in the RETURNING clause to obtain sums, counts and so on of columns in multiple rows changed by the DML statement.

Finally, you can also use RETURNING with EXECUTE IMMEDIATE (for dynamically constructed and executed SQL statements).

Run this LiveSQL script to see all of the statements shown below "in action."

First, I will create a table to use in my scripts:
CREATE TABLE parts ( 
   part_number    INTEGER 
 , part_name   VARCHAR2 (100))
/

BEGIN
   INSERT INTO parts VALUES (1, 'Mouse');
   INSERT INTO parts VALUES (100, 'Keyboard');
   INSERT INTO parts VALUES (500, 'Monitor');
   COMMIT;
END;
/
Which rows did I update? (the wrong way)
The code below issues the update and then in a separate SQL statement retrieves the part number of the row that was just modified - but only by reproducing the logic ("partname = UPPER (partname)") in the WHERE clause.

This means that I have introduced repetition in my code, and also inefficiency (an extra context switch). This is logically equivalent to using the RETURNING clause, but definitely inferior to RETURNING.

And keep in mind that if you use a SELECT after your DML statement to determine if the correct changes were made, you need to be very careful about how you specify the WHERE clause of your query to be sure that you identify the same rows that were (possibly) changed. 
DECLARE 
   l_num   PLS_INTEGER; 
BEGIN 
   UPDATE parts 
      SET part_name = UPPER (part_name) 
    WHERE part_name LIKE 'K%'; 
 
   SELECT part_number 
     INTO l_num 
     FROM parts 
    WHERE part_name = UPPER (part_name); 
 
   DBMS_OUTPUT.put_line (l_num); 
END;

/
Note: John Keymer @keymer_john pointed out the following on Twitter: I'd argue that these two approaches are not "logically equivalent". Using returning is read consistent, whereas if you do an update and then a select as shown above, that query could potentially return freshly committed rows from other sessions that you *didn't* touch in the update.
Which rows did I update? (the right way)
Don't do an unnecessary SELECT simply to see/verify the impact of a non-query DML statement! Just add RETURNING to the statement and get information back from that single context switch between PL/SQL and SQL. Note that this RETURNING INTO only works because the WHERE clause identifies a single row for changing. If more than one row is or may be changed, you will need to also use BULK COLLECT (see later example).
DECLARE 
   l_num   PLS_INTEGER; 
BEGIN 
      UPDATE parts 
         SET part_name = UPPER (part_name) 
       WHERE part_name LIKE 'K%' 
   RETURNING part_number 
        INTO l_num; 
 
   DBMS_OUTPUT.put_line (l_num); 
END;
Use RETURNING with BULK COLLECT INTO when changing multiple rows
If your non-query DML statement changes (or might change) more than one row, you will want to add BULK COLLECT to your RETURNING INTO clause and populate an array with information from each changed row.
DECLARE 
   l_part_numbers   DBMS_SQL.number_table; 
BEGIN 
      UPDATE parts 
         SET part_name = part_name || '1' 
   RETURNING part_number 
        BULK COLLECT INTO l_part_numbers; 
 
   FOR indx IN 1 .. l_part_numbers.COUNT 
   LOOP 
      DBMS_OUTPUT.put_line (l_part_numbers (indx)); 
   END LOOP; 
END;
Return an entire row? 
Not with ROW keyword. You can "UPDATE table_name SET ROW =" to perform a record-level update, but you cannot use the ROW keyword in that same way in a RETURNING clause.
DECLARE 
   l_part   parts%ROWTYPE; 
BEGIN 
      UPDATE parts 
         SET part_number = -1 * part_number, part_name = UPPER (part_name) 
       WHERE part_number = 1 
   RETURNING ROW 
        INTO l_part; 
 
   DBMS_OUTPUT.put_line (l_part.part_name); 
END;
Populate record in RETURNING with list of columns
Sorry, but you must list each column, with compatible number and type to the fields of the "receiving" record. 
DECLARE 
   l_part   parts%ROWTYPE; 
BEGIN 
      UPDATE parts 
         SET part_number = -1 * part_number, part_name = UPPER (part_name) 
       WHERE part_number = 1 
   RETURNING part_number, part_name 
        INTO l_part; 
 
   DBMS_OUTPUT.put_line (l_part.part_name); 
END;
OK, let's create another table for some other examples.
CREATE TABLE employees ( 
   employee_id   INTEGER 
 , last_name     VARCHAR2 (100) 
 , salary        NUMBER)
/

BEGIN
   INSERT INTO employees VALUES (100, 'Gutseriev', 1000);
   INSERT INTO employees VALUES (200, 'Ellison', 2000);
   INSERT INTO employees VALUES (400, 'Gates', 3000);
   INSERT INTO employees VALUES (500, 'Buffet', 4000);
   INSERT INTO employees VALUES (600, 'Slim', 5000);
   INSERT INTO employees VALUES (700, 'Arnault', 6000);
   COMMIT;
END;
/
Need aggregate information about impact of DML?
Sure, you could execute ANOTHER SQL statement to retrieve that information, using group functions. As in:
DECLARE 
   l_total   INTEGER; 
BEGIN 
   UPDATE employees 
      SET salary = salary * 2 
    WHERE INSTR (last_name, 'e') > 0; 
 
   SELECT SUM (salary) 
     INTO l_total 
     FROM employees 
    WHERE INSTR (last_name, 'e') > 0; 
 
   DBMS_OUTPUT.put_line (l_total); 
END;
Or you could perform a computation in PL/SQL. Use RETURNING to get back all the modified salaries. Then iterate through them, summing up the total along the way. Hmmm. That's a lot of code to write to do a SUM operation.
DECLARE 
   l_salaries   DBMS_SQL.number_table; 
   l_total      INTEGER := 0; 
BEGIN 
      UPDATE employees 
         SET salary = salary * 2 
       WHERE INSTR (last_name, 'e') > 0 
   RETURNING salary 
        BULK COLLECT INTO l_salaries; 
 
   FOR indx IN 1 .. l_salaries.COUNT 
   LOOP 
      l_total := l_total + l_salaries (indx); 
   END LOOP; 
 
   DBMS_OUTPUT.put_line (l_total); 
END;
What you should do instead is call the aggregate function right inside the RETURNING clause!

Yes! You can call SUM, COUNT, etc. directly in the RETURNING clause and thereby perform analytics before you return the data back to your PL/SQL block. Very cool. 
DECLARE    l_total   INTEGER; 
BEGIN 
      UPDATE employees 
         SET salary = salary * 2 
       WHERE INSTR (last_name, 'e') > 0 
   RETURNING SUM (salary) 
        INTO l_total; 
 
   DBMS_OUTPUT.put_line (l_total); 
END;
Use RETURNING with EXECUTE IMMEDIATE
You can also take advantage of the RETURNING clause when executing a dynamic SQL statement! 
DECLARE  
   l_part_number   parts.part_number%TYPE;  
BEGIN  
   EXECUTE IMMEDIATE 
   q'[UPDATE parts  
         SET part_name = part_name || '1' 
       WHERE part_number = 100 
      RETURNING part_number INTO :one_pn]'       
   RETURNING INTO l_part_number;  
  
   DBMS_OUTPUT.put_line (l_part_number);   
END;
RETURNING Multiple Rows in EXECUTE IMMEDIATE 
In this variation you see how to use RETURNING with a dynamic SQL statement that modifies more than one row. 
DECLARE  
   l_part_numbers   DBMS_SQL.number_table;  
BEGIN  
   EXECUTE IMMEDIATE 
   q'[UPDATE parts  
         SET part_name = part_name || '1' 
      RETURNING part_number INTO :pn_list]'       
   RETURNING BULK COLLECT INTO l_part_numbers;  
  
   FOR indx IN 1 .. l_part_numbers.COUNT  
   LOOP  
      DBMS_OUTPUT.put_line (l_part_numbers (indx));  
   END LOOP;  
END;
Resources
The RETURNING INTO Clause (doc)

DML Returning INTO Clause (Oracle-Base)

RETURNING INTO by @dboriented

Oracle Dev Gym workout on RETURNING