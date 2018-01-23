Example 7-1 Invoking Subprogram from Dynamic PL/SQL Block

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram created at schema level.

-- Subprogram that dynamic PL/SQL block invokes:
CREATE OR REPLACE PROCEDURE create_dept (
  deptid IN OUT NUMBER,
  dname  IN     VARCHAR2,
  mgrid  IN     NUMBER,
  locid  IN     NUMBER
) AUTHID DEFINER AS
BEGIN
  deptid := departments_seq.NEXTVAL;

  INSERT INTO departments (
    department_id,
    department_name,
    manager_id,
    location_id
  )
  VALUES (deptid, dname, mgrid, locid);
END;
/
DECLARE
  plsql_block VARCHAR2(500);
  new_deptid  NUMBER(4);
  new_dname   VARCHAR2(30) := 'Advertising';
  new_mgrid   NUMBER(6)    := 200;
  new_locid   NUMBER(4)    := 1700;
BEGIN
 -- Dynamic PL/SQL block invokes subprogram:
  plsql_block := 'BEGIN create_dept(:a, :b, :c, :d); END;';

 /* Specify bind variables in USING clause.
    Specify mode for first parameter.
    Modes of other parameters are correct by default. */

  EXECUTE IMMEDIATE plsql_block
    USING IN OUT new_deptid, new_dname, new_mgrid, new_locid;
END;
/
Example 7-2 Dynamically Invoking Subprogram with BOOLEAN Formal Parameter

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram that has a formal parameter of the PL/SQL (but not SQL) data type BOOLEAN.

CREATE OR REPLACE PROCEDURE p (x BOOLEAN) AUTHID DEFINER AS
BEGIN
  IF x THEN
    DBMS_OUTPUT.PUT_LINE('x is true');
  END IF;
END;
/

DECLARE
  dyn_stmt VARCHAR2(200);
  b        BOOLEAN := TRUE;
BEGIN
  dyn_stmt := 'BEGIN p(:x); END;';
  EXECUTE IMMEDIATE dyn_stmt USING b;
END;
/
Result:

x is true
Example 7-3 Dynamically Invoking Subprogram with RECORD Formal Parameter

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram that has a formal parameter of the PL/SQL (but not SQL) data type RECORD. The record type is declared in a package specification, and the subprogram is declared in the package specification and defined in the package body.

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
 
  TYPE rec IS RECORD (n1 NUMBER, n2 NUMBER);
 
  PROCEDURE p (x OUT rec, y NUMBER, z NUMBER);
END pkg;
/
CREATE OR REPLACE PACKAGE BODY pkg AS
 
  PROCEDURE p (x OUT rec, y NUMBER, z NUMBER) AS
  BEGIN
    x.n1 := y;
    x.n2 := z;
  END p;
END pkg;
/
DECLARE
  r       pkg.rec;
  dyn_str VARCHAR2(3000);
BEGIN
  dyn_str := 'BEGIN pkg.p(:x, 6, 8); END;';
 
  EXECUTE IMMEDIATE dyn_str USING OUT r;
 
  DBMS_OUTPUT.PUT_LINE('r.n1 = ' || r.n1);
  DBMS_OUTPUT.PUT_LINE('r.n2 = ' || r.n2);
END;
/
Example 7-4 Dynamically Invoking Subprogram with Assoc. Array Formal Parameter

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram that has a formal parameter of the PL/SQL collection type associative array indexed by PLS_INTEGER.

Note:
An associative array type used in this context must be indexed by PLS_INTEGER.

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
 
  TYPE number_names IS TABLE OF VARCHAR2(5)
    INDEX BY PLS_INTEGER;
 
  PROCEDURE print_number_names (x number_names);
END pkg;
/
CREATE OR REPLACE PACKAGE BODY pkg AS
  PROCEDURE print_number_names (x number_names) IS
  BEGIN
    FOR i IN x.FIRST .. x.LAST LOOP
      DBMS_OUTPUT.PUT_LINE(x(i));
    END LOOP;
  END;
END pkg;
/
DECLARE  
  digit_names  pkg.number_names;
  dyn_stmt     VARCHAR2(3000);
BEGIN
  digit_names(0) := 'zero';
  digit_names(1) := 'one';
  digit_names(2) := 'two';
  digit_names(3) := 'three';
  digit_names(4) := 'four';
  digit_names(5) := 'five';
  digit_names(6) := 'six';
  digit_names(7) := 'seven';
  digit_names(8) := 'eight';
  digit_names(9) := 'nine';
 
  dyn_stmt := 'BEGIN pkg.print_number_names(:x); END;';
  EXECUTE IMMEDIATE dyn_stmt USING digit_names;
END;
/
Example 7-5 Dynamically Invoking Subprogram with Nested Table Formal Parameter

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram that has a formal parameter of the PL/SQL collection type nested table.

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
 
  TYPE names IS TABLE OF VARCHAR2(10);
 
  PROCEDURE print_names (x names);
END pkg;
/
CREATE OR REPLACE PACKAGE BODY pkg AS
  PROCEDURE print_names (x names) IS
  BEGIN
    FOR i IN x.FIRST .. x.LAST LOOP
      DBMS_OUTPUT.PUT_LINE(x(i));
    END LOOP;
  END;
END pkg;
/
DECLARE
  fruits   pkg.names;
  dyn_stmt VARCHAR2(3000);
BEGIN
  fruits := pkg.names('apple', 'banana', 'cherry');
  
  dyn_stmt := 'BEGIN pkg.print_names(:x); END;';
  EXECUTE IMMEDIATE dyn_stmt USING fruits;
END;
/
Example 7-6 Dynamically Invoking Subprogram with Varray Formal Parameter

In this example, the dynamic PL/SQL block is an anonymous PL/SQL block that invokes a subprogram that has a formal parameter of the PL/SQL collection type varray.

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
 
  TYPE foursome IS VARRAY(4) OF VARCHAR2(5);
 
  PROCEDURE print_foursome (x foursome);
END pkg;
/
CREATE OR REPLACE PACKAGE BODY pkg AS
  PROCEDURE print_foursome (x foursome) IS
  BEGIN
    IF x.COUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Empty');
    ELSE 
      FOR i IN x.FIRST .. x.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(x(i));
      END LOOP;
    END IF;
  END;
END pkg;
/
DECLARE
  directions pkg.foursome;
  dyn_stmt VARCHAR2(3000);
BEGIN
  directions := pkg.foursome('north', 'south', 'east', 'west');
  
  dyn_stmt := 'BEGIN pkg.print_foursome(:x); END;';
  EXECUTE IMMEDIATE dyn_stmt USING directions;
END;
/
Example 7-7 Uninitialized Variable Represents NULL in USING Clause

This example uses an uninitialized variable to represent the reserved word NULL in the USING clause.

CREATE TABLE employees_temp AS SELECT * FROM EMPLOYEES;

DECLARE
  a_null  CHAR(1);  -- Set to NULL automatically at run time
BEGIN
  EXECUTE IMMEDIATE 'UPDATE employees_temp SET commission_pct = :x'
    USING a_null;
END;
/
OPEN FOR, FETCH, and CLOSE Statements
If the dynamic SQL statement represents a SELECT statement that returns multiple rows, you can process it with native dynamic SQL as follows:

Use an OPEN FOR statement to associate a cursor variable with the dynamic SQL statement. In the USING clause of the OPEN FOR statement, specify a bind variable for each placeholder in the dynamic SQL statement.

The USING clause cannot contain the literal NULL. To work around this restriction, use an uninitialized variable where you want to use NULL, as in Example 7-7.

Use the FETCH statement to retrieve result set rows one at a time, several at a time, or all at once.

Use the CLOSE statement to close the cursor variable.

The dynamic SQL statement can query a collection if the collection meets the criteria in "Querying a Collection".

See Also:
"OPEN FOR Statement" for syntax details
"FETCH Statement" for syntax details
"CLOSE Statement" for syntax details
Example 7-8 Native Dynamic SQL with OPEN FOR, FETCH, and CLOSE Statements

This example lists all employees who are managers, retrieving result set rows one at a time.

DECLARE
  TYPE EmpCurTyp  IS REF CURSOR;
  v_emp_cursor    EmpCurTyp;
  emp_record      employees%ROWTYPE;
  v_stmt_str      VARCHAR2(200);
  v_e_job         employees.job%TYPE;
BEGIN
  -- Dynamic SQL statement with placeholder:
  v_stmt_str := 'SELECT * FROM employees WHERE job_id = :j';

  -- Open cursor & specify bind variable in USING clause:
  OPEN v_emp_cursor FOR v_stmt_str USING 'MANAGER';

  -- Fetch rows from result set one at a time:
  LOOP
    FETCH v_emp_cursor INTO emp_record;
    EXIT WHEN v_emp_cursor%NOTFOUND;
  END LOOP;

  -- Close cursor:
  CLOSE v_emp_cursor;
END;
/
Example 7-9 Querying a Collection with Native Dynamic SQL

This example is like Example 6-30 except that the collection variable v1 is a bind variable.

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
  TYPE rec IS RECORD(f1 NUMBER, f2 VARCHAR2(30));
  TYPE mytab IS TABLE OF rec INDEX BY pls_integer;
END;
/

DECLARE
  v1 pkg.mytab;  -- collection of records
  v2 pkg.rec;
  c1 SYS_REFCURSOR;
BEGIN
  OPEN c1 FOR 'SELECT * FROM TABLE(:1)' USING v1;
  FETCH c1 INTO v2;
  CLOSE c1;
  DBMS_OUTPUT.PUT_LINE('Values in record are ' || v2.f1 || ' and ' || v2.f2);
END;
/