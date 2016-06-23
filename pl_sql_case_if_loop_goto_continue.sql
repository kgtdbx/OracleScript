Using PL/SQL Control Structures
This chapter shows you how to structure the flow of control through a PL/SQL program. PL/SQL provides conditional tests, loops, and branches that let you produce well-structured programs.

Topics:

Overview of PL/SQL Control Structures
Testing Conditions (IF and CASE Statements)
Controlling Loop Iterations (LOOP, EXIT, and CONTINUE Statements)
Sequential Control (GOTO and NULL Statements)
Overview of PL/SQL Control Structures
Procedural computer programs use the basic control structures shown in Figure 4-1.

Figure 4-1 Control Structures

Control Structures
Description of "Figure 4-1 Control Structures"

The selection structure tests a condition, then executes one sequence of statements instead of another, depending on whether the condition is true or false. A condition is any variable or expression that returns a BOOLEAN value. The iteration structure executes a sequence of statements repeatedly as long as a condition holds true. The sequence structure simply executes a sequence of statements in the order in which they occur.

Testing Conditions (IF and CASE Statements)
The IF statement executes a sequence of statements depending on the value of a condition. There are three forms of IF statements: IF-THEN, IF-THEN-ELSE, and IF-THEN-ELSIF. For a description of the syntax of the IF statement, see IF Statement.

The CASE statement is a compact way to evaluate a single condition and choose between many alternative actions. It makes sense to use CASE when there are three or more alternatives to choose from. For a description of the syntax of the CASE statement, see CASE Statement.

Topics:

Using the IF-THEN Statement
Using the IF-THEN-ELSE Statement
Using the IF-THEN-ELSIF Statement
Using the Simple CASE Statement
Using the Searched CASE Statement
Guidelines for IF and CASE Statements
Using the IF-THEN Statement
The simplest form of IF statement associates a condition with a sequence of statements enclosed by the keywords THEN and END IF (not ENDIF) as illustrated in Example 4-1.

The sequence of statements is executed only if the condition is TRUE. If the condition is FALSE or NULL, the IF statement does nothing. In either case, control passes to the next statement.

Example 4-1 Simple IF-THEN Statement

SQL> DECLARE
  2    sales  NUMBER(8,2) := 10100;
  3    quota  NUMBER(8,2) := 10000;
  4    bonus  NUMBER(6,2);
  5    emp_id NUMBER(6) := 120;
  6  BEGIN
  7    IF sales > (quota + 200) THEN
  8       bonus := (sales - quota)/4;
  9  
 10       UPDATE employees SET salary =
 11         salary + bonus
 12           WHERE employee_id = emp_id;
 13    END IF;
 14  END;
 15  /
 
PL/SQL procedure successfully completed.
 
SQL>
Using the IF-THEN-ELSE Statement
The second form of IF statement adds the keyword ELSE followed by an alternative sequence of statements, as shown in Example 4-2.

The statements in the ELSE clause are executed only if the condition is FALSE or NULL. The IF-THEN-ELSE statement ensures that one or the other sequence of statements is executed.

Example 4-2 Using a Simple IF-THEN-ELSE Statement

SQL> DECLARE
  2    sales  NUMBER(8,2) := 12100;
  3    quota  NUMBER(8,2) := 10000;
  4    bonus  NUMBER(6,2);
  5    emp_id NUMBER(6) := 120;
  6  BEGIN
  7    IF sales > (quota + 200) THEN
  8      bonus := (sales - quota)/4;
  9    ELSE
 10      bonus := 50;
 11    END IF;
 12  
 13    UPDATE employees
 14      SET salary = salary + bonus
 15        WHERE employee_id = emp_id;
 16  END;
 17  /
 
PL/SQL procedure successfully completed.
 
SQL> 
IF statements can be nested. Example 4-3 shows nested IF-THEN-ELSE statements.

Example 4-3 Nested IF-THEN-ELSE Statements

SQL> DECLARE
  2    sales  NUMBER(8,2) := 12100;
  3    quota  NUMBER(8,2) := 10000;
  4    bonus  NUMBER(6,2);
  5    emp_id NUMBER(6)   := 120;
  6  BEGIN
  7    IF sales > (quota + 200) THEN
  8      bonus := (sales - quota)/4;
  9    ELSE
 10      IF sales > quota THEN
 11        bonus := 50;
 12      ELSE
 13        bonus := 0;
 14      END IF;
 15    END IF;
 16  
 17    UPDATE employees
 18      SET salary = salary + bonus
 19        WHERE employee_id = emp_id;
 20  END;
 21  /
 
PL/SQL procedure successfully completed.
 
SQL>
Using the IF-THEN-ELSIF Statement
Sometimes you want to choose between several alternatives. You can use the keyword ELSIF (not ELSIF or ELSE IF) to introduce additional conditions, as shown in Example 4-4.

If the first condition is FALSE or NULL, the ELSIF clause tests another condition. An IF statement can have any number of ELSIF clauses; the final ELSE clause is optional. Conditions are evaluated one by one from top to bottom. If any condition is TRUE, its associated sequence of statements is executed and control passes to the next statement. If all conditions are false or NULL, the sequence in the ELSE clause is executed, as shown in Example 4-4.

Example 4-4 Using the IF-THEN-ELSIF Statement

SQL> DECLARE
  2    sales  NUMBER(8,2) := 20000;
  3    bonus  NUMBER(6,2);
  4    emp_id NUMBER(6)   := 120;
  5  BEGIN
  6    IF sales > 50000 THEN
  7      bonus := 1500;
  8    ELSIF sales > 35000 THEN
  9      bonus := 500;
 10    ELSE
 11      bonus := 100;
 12    END IF;
 13  
 14    UPDATE employees
 15      SET salary = salary + bonus
 16        WHERE employee_id = emp_id;
 17  END;
 18  /
 
PL/SQL procedure successfully completed.
 
SQL>
If the value of sales is larger than 50000, the first and second conditions are TRUE. Nevertheless, bonus is assigned the proper value of 1500 because the second condition is never tested. When the first condition is TRUE, its associated statement is executed and control passes to the UPDATE statement.

Another example of an IF-THEN-ELSE statement is Example 4-5.

Example 4-5 Extended IF-THEN Statement

SQL> DECLARE
  2    grade CHAR(1);
  3  BEGIN
  4    grade := 'B';
  5  
  6    IF grade = 'A' THEN
  7      DBMS_OUTPUT.PUT_LINE('Excellent');
  8    ELSIF grade = 'B' THEN
  9      DBMS_OUTPUT.PUT_LINE('Very Good');
 10    ELSIF grade = 'C' THEN
 11      DBMS_OUTPUT.PUT_LINE('Good');
 12    ELSIF grade = 'D' THEN
 13      DBMS_OUTPUT. PUT_LINE('Fair');
 14    ELSIF grade = 'F' THEN
 15      DBMS_OUTPUT.PUT_LINE('Poor');
 16    ELSE
 17      DBMS_OUTPUT.PUT_LINE('No such grade');
 18    END IF;
 19  END;
 20  /
Very Good
 
PL/SQL procedure successfully completed.
 
SQL>
Using the Simple CASE Statement
Like the IF statement, the CASE statement selects one sequence of statements to execute. However, to select the sequence, the CASE statement uses a selector rather than multiple Boolean expressions. A selector is an expression whose value is used to select one of several alternatives.

You can rewrite the code in Example 4-5 using the CASE statement, as shown in Example 4-6.

Example 4-6 Simple CASE Statement

SQL> DECLARE
  2    grade CHAR(1);
  3  BEGIN
  4    grade := 'B';
  5  
  6    CASE grade
  7      WHEN 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent');
  8      WHEN 'B' THEN DBMS_OUTPUT.PUT_LINE('Very Good');
  9      WHEN 'C' THEN DBMS_OUTPUT.PUT_LINE('Good');
 10      WHEN 'D' THEN DBMS_OUTPUT.PUT_LINE('Fair');
 11      WHEN 'F' THEN DBMS_OUTPUT.PUT_LINE('Poor');
 12      ELSE DBMS_OUTPUT.PUT_LINE('No such grade');
 13    END CASE;
 14  END;
 15  /
Very Good
 
PL/SQL procedure successfully completed.
 
SQL>
The CASE statement is more readable and more efficient. When possible, rewrite lengthy IF-THEN-ELSIF statements as CASE statements.

The CASE statement begins with the keyword CASE. The keyword is followed by a selector, which is the variable grade in the last example. The selector expression can be arbitrarily complex. For example, it can contain function calls. Usually, however, it consists of a single variable. The selector expression is evaluated only once. The value it yields can have any PL/SQL data type other than BLOB, BFILE, an object type, a PL/SQL record, an index-by-table, a varray, or a nested table.

The selector is followed by one or more WHEN clauses, which are checked sequentially. The value of the selector determines which clause is executed. If the value of the selector equals the value of a WHEN-clause expression, that WHEN clause is executed. For example, in the last example, if grade equals 'C', the program outputs 'Good'. Execution never falls through; if any WHEN clause is executed, control passes to the next statement.

The ELSE clause works similarly to the ELSE clause in an IF statement. In the last example, if the grade is not one of the choices covered by a WHEN clause, the ELSE clause is selected, and the phrase 'No such grade' is output. The ELSE clause is optional. However, if you omit the ELSE clause, PL/SQL adds the following implicit ELSE clause:

ELSE RAISE CASE_NOT_FOUND;
There is always a default action, even when you omit the ELSE clause. If the CASE statement does not match any of the WHEN clauses and you omit the ELSE clause, PL/SQL raises the predefined exception CASE_NOT_FOUND.

The keywords END CASE terminate the CASE statement. These two keywords must be separated by a space.

Like PL/SQL blocks, CASE statements can be labeled. The label, an undeclared identifier enclosed by double angle brackets, must appear at the beginning of the CASE statement. Optionally, the label name can also appear at the end of the CASE statement.

Exceptions raised during the execution of a CASE statement are handled in the usual way. That is, normal execution stops and control transfers to the exception-handling part of your PL/SQL block or subprogram.

An alternative to the CASE statement is the CASE expression, where each WHEN clause is an expression. For details, see CASE Expressions.

Using the Searched CASE Statement
PL/SQL also provides a searched CASE statement, similar to the simple CASE statement, which has the form shown in Example 4-7.

The searched CASE statement has no selector, and its WHEN clauses contain search conditions that yield Boolean values, not expressions that can yield a value of any type.

The searched CASE statement in Example 4-7 is logically equivalent to the simple CASE statement in Example 4-6.

Example 4-7 Searched CASE Statement

SQL> DECLARE
  2    grade CHAR(1);
  3  BEGIN
  4    grade := 'B';
  5  
  6    CASE
  7      WHEN grade = 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent');
  8      WHEN grade = 'B' THEN DBMS_OUTPUT.PUT_LINE('Very Good');
  9      WHEN grade = 'C' THEN DBMS_OUTPUT.PUT_LINE('Good');
 10      WHEN grade = 'D' THEN DBMS_OUTPUT.PUT_LINE('Fair');
 11      WHEN grade = 'F' THEN DBMS_OUTPUT.PUT_LINE('Poor');
 12      ELSE DBMS_OUTPUT.PUT_LINE('No such grade');
 13    END CASE;
 14  END;
 15  /
Very Good
 
PL/SQL procedure successfully completed.
 
SQL>
In both Example 4-7 and Example 4-6, the ELSE clause can be replaced by an EXCEPTION part. Example 4-8 is logically equivalent to Example 4-7.

Example 4-8 Using EXCEPTION Instead of ELSE Clause in CASE Statement

SQL> DECLARE
  2    grade CHAR(1);
  3  BEGIN
  4    grade := 'B';
  5  
  6    CASE
  7      WHEN grade = 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent');
  8      WHEN grade = 'B' THEN DBMS_OUTPUT.PUT_LINE('Very Good');
  9      WHEN grade = 'C' THEN DBMS_OUTPUT.PUT_LINE('Good');
 10      WHEN grade = 'D' THEN DBMS_OUTPUT.PUT_LINE('Fair');
 11      WHEN grade = 'F' THEN DBMS_OUTPUT.PUT_LINE('Poor');
 12    END CASE;
 13  
 14    EXCEPTION
 15      WHEN CASE_NOT_FOUND THEN
 16        DBMS_OUTPUT.PUT_LINE('No such grade');
 17  END;
 18  /
Very Good
 
PL/SQL procedure successfully completed.
 
SQL>
The search conditions are evaluated sequentially. The Boolean value of each search condition determines which WHEN clause is executed. If a search condition yields TRUE, its WHEN clause is executed. If any WHEN clause is executed, control passes to the next statement, so subsequent search conditions are not evaluated.

If none of the search conditions yields TRUE, the ELSE clause is executed. The ELSE clause is optional. However, if you omit the ELSE clause, PL/SQL adds the following implicit ELSE clause:

ELSE RAISE CASE_NOT_FOUND;
Exceptions raised during the execution of a searched CASE statement are handled in the usual way. That is, normal execution stops and control transfers to the exception-handling part of your PL/SQL block or subprogram.

Guidelines for IF and CASE Statements
Avoid clumsy IF statements like those in the following example:

IF new_balance < minimum_balance THEN
  overdrawn := TRUE;
ELSE
  overdrawn := FALSE;
END IF;
IF overdrawn = TRUE THEN
  RAISE insufficient_funds;
END IF;
The value of a Boolean expression can be assigned directly to a Boolean variable. You can replace the first IF statement with a simple assignment:

overdrawn := new_balance < minimum_balance;
A Boolean variable is itself either true or false. You can simplify the condition in the second IF statement:

IF overdrawn THEN ...
When possible, use the ELSIF clause instead of nested IF statements. Your code will be easier to read and understand. Compare the following IF statements:

IF condition1 THEN statement1;
  ELSE IF condition2 THEN statement2;
    ELSE IF condition3 THEN statement3; END IF;
  END IF;
END IF;
IF condition1 THEN statement1;
  ELSIF condition2 THEN statement2;
  ELSIF condition3 THEN statement3;
END IF;
These statements are logically equivalent, but the second statement makes the logic clearer.

To compare a single expression to multiple values, you can simplify the logic by using a single CASE statement instead of an IF with several ELSIF clauses.

Controlling Loop Iterations (LOOP, EXIT, and CONTINUE Statements)
A LOOP statement executes a sequence of statements multiple times. PL/SQL provides the following loop statements:

Basic LOOP
WHILE LOOP
FOR LOOP
Cursor FOR LOOP
To exit a loop, PL/SQL provides the following statements:

EXIT
EXIT-WHEN
To exit the current iteration of a loop, PL/SQL provides the following statements:

CONTINUE
CONTINUE-WHEN
You can put EXIT and CONTINUE statements anywhere inside a loop, but not outside a loop. To complete a PL/SQL block before it reaches its normal end, use the RETURN statement (see RETURN Statement).

For the syntax of the LOOP, EXIT, and CONTINUE statements, see Chapter 13, "PL/SQL Language Elements."

Topics:

Using the Basic LOOP Statement
Using the EXIT Statement
Using the EXIT-WHEN Statement
Using the CONTINUE Statement
Using the CONTINUE-WHEN Statement
Labeling a PL/SQL Loop
Using the WHILE-LOOP Statement
Using the FOR-LOOP Statement
For information about the cursor FOR-LOOP, see Cursor FOR LOOP.

Using the Basic LOOP Statement
The simplest LOOP statement is the basic loop, which encloses a sequence of statements between the keywords LOOP and END LOOP, as follows:

LOOP
  sequence_of_statements
END LOOP;
With each iteration of the loop, the sequence of statements is executed, then control resumes at the top of the loop.

You can use CONTINUE and CONTINUE-WHEN statements in a basic loop, but to prevent an infinite loop, you must use an EXIT or EXIT-WHEN statement.

For the syntax of the basic loop, see LOOP Statements.

Using the EXIT Statement
When an EXIT statement is encountered, the loop completes immediately and control passes to the statement immediately after END LOOP, as Example 4-9 shows.

For the syntax of the EXIT statement, see EXIT Statement.

Example 4-9 EXIT Statement

SQL> DECLARE
  2    x NUMBER := 0;
  3  BEGIN
  4    LOOP
  5      DBMS_OUTPUT.PUT_LINE
  6        ('Inside loop:  x = ' || TO_CHAR(x));
  7  
  8      x := x + 1;
  9  
 10      IF x > 3 THEN
 11        EXIT;
 12      END IF;
 13    END LOOP;
 14    -- After EXIT, control resumes here
 15  
 16    DBMS_OUTPUT.PUT_LINE
 17      (' After loop:  x = ' || TO_CHAR(x));
 18  END;
 19  /
Inside loop:  x = 0
Inside loop:  x = 1
Inside loop:  x = 2
Inside loop:  x = 3
After loop:  x = 4
 
PL/SQL procedure successfully completed.
 
SQL>
Using the EXIT-WHEN Statement
When an EXIT-WHEN statement is encountered, the condition in the WHEN clause is evaluated. If the condition is true, the loop completes and control passes to the statement immediately after END LOOP. Until the condition is true, the EXIT-WHEN statement acts like a NULL statement (except for the evaluation of its condition) and does not terminate the loop. A statement inside the loop must change the value of the condition, as in Example 4-10.

The EXIT-WHEN statement replaces a statement of the form IF ... THEN ... EXIT. Example 4-10 is logically equivalent to Example 4-9.

For the syntax of the EXIT-WHEN statement, see EXIT Statement.

Example 4-10 Using an EXIT-WHEN Statement

SQL> DECLARE
  2    x NUMBER := 0;
  3  BEGIN
  4    LOOP
  5      DBMS_OUTPUT.PUT_LINE
  6        ('Inside loop:  x = ' || TO_CHAR(x));
  7  
  8      x := x + 1;
  9  
 10      EXIT WHEN x > 3;
 11    END LOOP;
 12  
 13    -- After EXIT statement, control resumes here
 14    DBMS_OUTPUT.PUT_LINE
 15      ('After loop:  x = ' || TO_CHAR(x));
 16  END;
 17  /
Inside loop:  x = 0
Inside loop:  x = 1
Inside loop:  x = 2
Inside loop:  x = 3
After loop:  x = 4
 
PL/SQL procedure successfully completed.
 
SQL>
Using the CONTINUE Statement
When a CONTINUE statement is encountered, the current iteration of the loop completes immediately and control passes to the next iteration of the loop, as in Example 4-11.

A CONTINUE statement cannot cross a subprogram or method boundary.

For the syntax of the CONTINUE statement, see CONTINUE Statement.

Example 4-11 CONTINUE Statement

SQL> DECLARE
  2    x NUMBER := 0;
  3  BEGIN
  4    LOOP -- After CONTINUE statement, control resumes here
  5      DBMS_OUTPUT.PUT_LINE ('Inside loop:  x = ' || TO_CHAR(x));
  6      x := x + 1;
  7  
  8      IF x < 3 THEN
  9        CONTINUE;
 10      END IF;
 11  
 12      DBMS_OUTPUT.PUT_LINE
 13        ('Inside loop, after CONTINUE:  x = ' || TO_CHAR(x));
 14  
 15      EXIT WHEN x = 5;
 16    END LOOP;
 17  
 18    DBMS_OUTPUT.PUT_LINE (' After loop:  x = ' || TO_CHAR(x));
 19  END;
 20  /
Inside loop:  x = 0
Inside loop:  x = 1
Inside loop:  x = 2
Inside loop, after CONTINUE:  x = 3
Inside loop:  x = 3
Inside loop, after CONTINUE:  x = 4
Inside loop:  x = 4
Inside loop, after CONTINUE:  x = 5
After loop:  x = 5
 
PL/SQL procedure successfully completed.
 
SQL>
Note:
As of Release 11.1, CONTINUE is a PL/SQL keyword. If your program invokes a subprogram named CONTINUE, you will get a warning.
Using the CONTINUE-WHEN Statement
When a CONTINUE-WHEN statement is encountered, the condition in the WHEN clause is evaluated. If the condition is true, the current iteration of the loop completes and control passes to the next iteration. Until the condition is true, the CONTINUE-WHEN statement acts like a NULL statement (except for the evaluation of its condition) and does not terminate the iteration. However, the value of the condition can vary from iteration to iteration, so that the CONTINUE terminates some iterations and not others.

The CONTINUE-WHEN statement replaces a statement of the form IF ... THEN ... CONTINUE. Example 4-12 is logically equivalent to Example 4-11.

A CONTINUE-WHEN statement cannot cross a subprogram or method boundary.

For the syntax of the CONTINUE-WHEN statement, see CONTINUE Statement.

Example 4-12 CONTINUE-WHEN Statement

SQL> DECLARE
  2    x NUMBER := 0;
  3  BEGIN
  4    LOOP -- After CONTINUE statement, control resumes here
  5      DBMS_OUTPUT.PUT_LINE ('Inside loop:  x = ' || TO_CHAR(x));
  6      x := x + 1;
  7      CONTINUE WHEN x < 3;
  8      DBMS_OUTPUT.PUT_LINE
  9        ('Inside loop, after CONTINUE:  x = ' || TO_CHAR(x));
 10      EXIT WHEN x = 5;
 11    END LOOP;
 12    DBMS_OUTPUT.PUT_LINE (' After loop:  x = ' || TO_CHAR(x));
 13  END;
 14  /
Inside loop:  x = 0
Inside loop:  x = 1
Inside loop:  x = 2
Inside loop, after CONTINUE:  x = 3
Inside loop:  x = 3
Inside loop, after CONTINUE:  x = 4
Inside loop:  x = 4
Inside loop, after CONTINUE:  x = 5
After loop:  x = 5
 
PL/SQL procedure successfully completed.
 
SQL>
Labeling a PL/SQL Loop
Like PL/SQL blocks, loops can be labeled. The optional label, an undeclared identifier enclosed by double angle brackets, must appear at the beginning of the LOOP statement. The label name can also appear at the end of the LOOP statement. When you nest labeled loops, use ending label names to improve readability.

With either form of EXIT statement, you can exit not only the current loop, but any enclosing loop. Simply label the enclosing loop that you want to exit. Then, use the label in an EXIT statement, as in Example 4-13. Every enclosing loop up to and including the labeled loop is exited.

With either form of CONTINUE statement, you can complete the current iteration of the labeled loop and exit any enclosed loops.

Example 4-13 Labeled Loops

SQL> DECLARE
  2    s  PLS_INTEGER := 0;
  3    i  PLS_INTEGER := 0;
  4    j  PLS_INTEGER;
  5  BEGIN
  6    <<outer_loop>>
  7    LOOP
  8      i := i + 1;
  9      j := 0;
 10      <<inner_loop>>
 11      LOOP
 12        j := j + 1;
 13        s := s + i * j; -- Sum several products
 14        EXIT inner_loop WHEN (j > 5);
 15        EXIT outer_loop WHEN ((i * j) > 15);
 16      END LOOP inner_loop;
 17    END LOOP outer_loop;
 18    DBMS_OUTPUT.PUT_LINE
 19      ('The sum of products equals: ' || TO_CHAR(s));
 20  END;
 21  /
The sum of products equals: 166
 
PL/SQL procedure successfully completed.
 
SQL>
Using the WHILE-LOOP Statement
The WHILE-LOOP statement executes the statements in the loop body as long as a condition is true:

WHILE condition LOOP
  sequence_of_statements
END LOOP;
Before each iteration of the loop, the condition is evaluated. If it is TRUE, the sequence of statements is executed, then control resumes at the top of the loop. If it is FALSE or NULL, the loop is skipped and control passes to the next statement. See Example 1-12 for an example using the WHILE-LOOP statement.

The number of iterations depends on the condition and is unknown until the loop completes. The condition is tested at the top of the loop, so the sequence might execute zero times.

Some languages have a LOOP UNTIL or REPEAT UNTIL structure, which tests the condition at the bottom of the loop instead of at the top, so that the sequence of statements is executed at least once. The equivalent in PL/SQL is:

LOOP
  sequence_of_statements
  EXIT WHEN boolean_expression
END LOOP;
To ensure that a WHILE loop executes at least once, use an initialized Boolean variable in the condition, as follows:

done := FALSE;
WHILE NOT done LOOP
  sequence_of_statements
  done := boolean_expression
END LOOP;
A statement inside the loop must assign a new value to the Boolean variable to avoid an infinite loop.

Using the FOR-LOOP Statement
Simple FOR loops iterate over a specified range of integers (lower_bound .. upper_bound). The number of iterations is known before the loop is entered. The range is evaluated when the FOR loop is first entered and is never re-evaluated. If lower_bound equals upper_bound, the loop body is executed once.

As Example 4-14 shows, the sequence of statements is executed once for each integer in the range 1 to 500. After each iteration, the loop counter is incremented.

Example 4-14 Simple FOR-LOOP Statement

SQL> BEGIN
  2    FOR i IN 1..3 LOOP
  3      DBMS_OUTPUT.PUT_LINE (TO_CHAR(i));
  4    END LOOP;
  5  END;
  6  /
1
2
3
 
PL/SQL procedure successfully completed.
 
SQL>
By default, iteration proceeds upward from the lower bound to the higher bound. If you use the keyword REVERSE, iteration proceeds downward from the higher bound to the lower bound. After each iteration, the loop counter is decremented. You still write the range bounds in ascending (not descending) order.

Example 4-15 Reverse FOR-LOOP Statement

SQL> BEGIN
  2    FOR i IN REVERSE 1..3 LOOP
  3      DBMS_OUTPUT.PUT_LINE (TO_CHAR(i));
  4    END LOOP;
  5  END;
  6  /
3
2
1
 
PL/SQL procedure successfully completed.
 
SQL>
Inside a FOR loop, the counter can be read but cannot be changed. For example:

SQL> BEGIN
  2    FOR i IN 1..3 LOOP
  3      IF i < 3 THEN
  4         DBMS_OUTPUT.PUT_LINE (TO_CHAR(i));
  5      ELSE
  6         i := 2;
  7      END IF;
  8    END LOOP;
  9  END;
 10  /
       i := 2;
       *
ERROR at line 6:
ORA-06550: line 6, column 8:
PLS-00363: expression 'I' cannot be used as an assignment target
ORA-06550: line 6, column 8:
PL/SQL: Statement ignored
 
SQL>
A useful variation of the FOR loop uses a SQL query instead of a range of integers. This technique lets you run a query and process all the rows of the result set with straightforward syntax. For details, see Cursor FOR LOOP.

Topics:

How PL/SQL Loops Repeat
Dynamic Ranges for Loop Bounds
Scope of the Loop Counter Variable
Using the EXIT Statement in a FOR Loop
How PL/SQL Loops Repeat
The bounds of a loop range can be either literals, variables, or expressions, but they must evaluate to numbers. Otherwise, PL/SQL raises the predefined exception VALUE_ERROR. The lower bound need not be 1, but the loop counter increment or decrement must be 1.

Example 4-16 Several Types of FOR-LOOP Bounds

SQL> DECLARE
  2    first  INTEGER := 1;
  3    last   INTEGER := 10;
  4    high   INTEGER := 100;
  5    low    INTEGER := 12;
  6  BEGIN
  7    -- Bounds are numeric literals:
  8  
  9    FOR j IN -5..5 LOOP
 10      NULL;
 11    END LOOP;
 12  
 13    -- Bounds are numeric variables:
 14  
 15    FOR k IN REVERSE first..last LOOP
 16      NULL;
 17    END LOOP;
 18  
 19    -- Lower bound is numeric literal,
 20    -- Upper bound is numeric expression:
 21  
 22    FOR step IN 0..(TRUNC(high/low) * 2) LOOP
 23      NULL;
 24    END LOOP;
 25  END;
 26  /
 
PL/SQL procedure successfully completed.
 
SQL>
Internally, PL/SQL assigns the values of the bounds to temporary PLS_INTEGER variables, and, if necessary, rounds the values to the nearest integer. The magnitude range of a PLS_INTEGER is -2147483648 to 2147483647, represented in 32 bits. If a bound evaluates to a number outside that range, you get a numeric overflow error when PL/SQL attempts the assignment. See PLS_INTEGER and BINARY_INTEGER Data Types.

Some languages provide a STEP clause, which lets you specify a different increment (5 instead of 1, for example). PL/SQL has no such structure, but you can easily build one. Inside the FOR loop, simply multiply each reference to the loop counter by the new increment.

Example 4-17 assigns today's date to elements 5, 10, and 15 of an index-by table.

Example 4-17 Changing the Increment of the Counter in a FOR-LOOP Statement

SQL> DECLARE
  2    TYPE DateList IS TABLE OF DATE INDEX BY PLS_INTEGER;
  3    dates DateList;
  4  BEGIN
  5    FOR j IN 1..3 LOOP
  6      dates(j*5) := SYSDATE;
  7    END LOOP;
  8  END;
  9  /
 
PL/SQL procedure successfully completed.
 
SQL>
Dynamic Ranges for Loop Bounds
PL/SQL lets you specify the loop range at run time by using variables for bounds as shown in Example 4-18.

Example 4-18 Specifying a LOOP Range at Run Time

SQL> CREATE TABLE temp (  2    emp_no NUMBER,  3    email_addr VARCHAR2(50)  4  );Table created.SQL> SQL> DECLARE
  2    emp_count NUMBER;
  3  BEGIN
  4    SELECT COUNT(employee_id) INTO emp_count
  5      FROM employees;
  6  
  7    FOR i IN 1..emp_count LOOP
  8      INSERT INTO temp
  9        VALUES(i, 'to be added later');
 10    END LOOP;
 11  END;
 12  /
 
PL/SQL procedure successfully completed.
 
SQL>
If the lower bound of a loop range is larger than the upper bound, the loop body is not executed and control passes to the next statement, as Example 4-19 shows.

Example 4-19 FOR-LOOP with Lower Bound > Upper Bound

SQL> CREATE OR REPLACE PROCEDURE p
  2    (limit IN INTEGER) IS
  3  BEGIN
  4    FOR i IN 2..limit LOOP
  5      DBMS_OUTPUT.PUT_LINE
  6        ('Inside loop, limit is ' || i);
  7    END LOOP;
  8  
  9    DBMS_OUTPUT.PUT_LINE
 10        ('Outside loop, limit is ' || TO_CHAR(limit));
 11  END;
 12  /
 
Procedure created.
 
SQL> BEGIN
  2    p(3);
  3  END;
  4  /
Inside loop, limit is 2
Inside loop, limit is 3
Outside loop, limit is 3
 
PL/SQL procedure successfully completed.
 
SQL> BEGIN
  2    p(1);
  3  END;
  4  /
Outside loop, limit is 1
 
PL/SQL procedure successfully completed.
 
SQL>
Scope of the Loop Counter Variable
The loop counter is defined only within the loop. You cannot reference that variable name outside the loop. After the loop exits, the loop counter is undefined, asExample 4-20 shows.

Example 4-20 Referencing Counter Variable Outside Loop

SQL> BEGIN
  2    FOR i IN 1..3 LOOP
  3      DBMS_OUTPUT.PUT_LINE
  4        ('Inside loop, i is ' || TO_CHAR(i));
  5    END LOOP;
  6  
  7    DBMS_OUTPUT.PUT_LINE
  8      ('Outside loop, i is ' || TO_CHAR(i));
  9  END;
 10  /
    ('Outside loop, i is ' || TO_CHAR(i));
                                      *
ERROR at line 8:
ORA-06550: line 8, column 39:
PLS-00201: identifier 'I' must be declared
ORA-06550: line 7, column 3:
PL/SQL: Statement ignored
 
SQL>
You need not declare the loop counter because it is implicitly declared as a local variable of type INTEGER. It is safest not to give a loop variable the same name as an existing variable, because the local declaration hides the global declaration, as Example 4-21 shows.

Example 4-21 Using Existing Variable as Loop Variable

SQL> DECLARE
  2    i NUMBER := 5;
  3  BEGIN
  4    FOR i IN 1..3 LOOP
  5      DBMS_OUTPUT.PUT_LINE
  6        ('Inside loop, i is ' || TO_CHAR(i));
  7    END LOOP;
  8  
  9    DBMS_OUTPUT.PUT_LINE
 10        ('Outside loop, i is ' || TO_CHAR(i));
 11  END;
 12  /
Inside loop, i is 1
Inside loop, i is 2
Inside loop, i is 3
Outside loop, i is 5
 
PL/SQL procedure successfully completed.
 
SQL>
To reference the global variable in Example 4-21, you must use a label and dot notation, as in Example 4-22.

Example 4-22 Referencing Global Variable with Same Name as Loop Counter

SQL> <<main>>
  2  DECLARE
  3    i NUMBER := 5;
  4  BEGIN
  5    FOR i IN 1..3 LOOP
  6      DBMS_OUTPUT.PUT_LINE
  7        ('local: ' || TO_CHAR(i) || ', global: ' || TO_CHAR(main.i));
  8    END LOOP;
  9  END main;
 10  /
local: 1, global: 5
local: 2, global: 5
local: 3, global: 5
 
PL/SQL procedure successfully completed.
 
SQL>
The same scope rules apply to nested FOR loops. In Example 4-23, the inner and outer loop counters have the same name, and the inner loop uses a label and dot notation to reference the counter of the outer loop.

Example 4-23 Referencing Outer Counter with Same Name as Inner Counter

SQL> BEGIN
  2  <<outer_loop>>
  3    FOR i IN 1..3 LOOP
  4      <<inner_loop>>
  5      FOR i IN 1..3 LOOP
  6        IF outer_loop.i = 2 THEN
  7          DBMS_OUTPUT.PUT_LINE
  8            ( 'outer: ' || TO_CHAR(outer_loop.i) || ' inner: '
  9              || TO_CHAR(inner_loop.i));
 10        END IF;
 11      END LOOP inner_loop;
 12    END LOOP outer_loop;
 13  END;
 14  /
outer: 2 inner: 1
outer: 2 inner: 2
outer: 2 inner: 3
 
PL/SQL procedure successfully completed.
 
SQL>
Using the EXIT Statement in a FOR Loop
The EXIT statement lets a FOR loop complete early. In Example 4-24, the loop normally executes ten times, but as soon as the FETCH statement fails to return a row, the loop completes no matter how many times it has executed.

Example 4-24 EXIT in a FOR LOOP

SQL> DECLARE
  2     v_employees employees%ROWTYPE;
  3     CURSOR c1 is SELECT * FROM employees;
  4  BEGIN
  5    OPEN c1;
  6    -- Fetch entire row into v_employees record:
  7    FOR i IN 1..10 LOOP
  8      FETCH c1 INTO v_employees;
  9      EXIT WHEN c1%NOTFOUND;
 10      -- Process data here
 11    END LOOP;
 12    CLOSE c1;
 13  END;
 14  /
 
PL/SQL procedure successfully completed.
 
SQL>
Suppose you must exit early from a nested FOR loop. To complete not only the current loop, but also any enclosing loop, label the enclosing loop and use the label in an EXIT statement as shown in Example 4-25. To complete the current iteration of the labeled loop and exit any enclosed loops, use a label in a CONTINUE statement.

Example 4-25 EXIT with a Label in a FOR LOOP

SQL> DECLARE
  2     v_employees employees%ROWTYPE;
  3     CURSOR c1 is SELECT * FROM employees;
  4  BEGIN
  5    OPEN c1;
  6  
  7    -- Fetch entire row into v_employees record:
  8    <<outer_loop>>
  9    FOR i IN 1..10 LOOP
 10      -- Process data here
 11      FOR j IN 1..10 LOOP
 12        FETCH c1 INTO v_employees;
 13        EXIT outer_loop WHEN c1%NOTFOUND;
 14        -- Process data here
 15      END LOOP;
 16    END LOOP outer_loop;
 17  
 18    CLOSE c1;
 19  END;
 20  /
 
PL/SQL procedure successfully completed.
 
SQL>
Sequential Control (GOTO and NULL Statements)
Unlike the IF and LOOP statements, the GOTO and NULL statements are not crucial to PL/SQL programming. The GOTO statement is seldom needed. Occasionally, it can simplify logic enough to warrant its use. The NULL statement can improve readability by making the meaning and action of conditional statements clear.

Overuse of GOTO statements can result in code that is hard to understand and maintain. Use GOTO statements sparingly. For example, to branch from a deeply nested structure to an error-handling routine, raise an exception rather than use a GOTO statement. PL/SQL's exception-handling mechanism is explained in Chapter 11, "Handling PL/SQL Errors."

Topics:

Using the GOTO Statement
GOTO Statement Restrictions
Using the NULL Statement
Using the GOTO Statement
The GOTO statement branches to a label unconditionally. The label must be unique within its scope and must precede an executable statement or a PL/SQL block. When executed, the GOTO statement transfers control to the labeled statement or block.

Example 4-26 Simple GOTO Statement

SQL> DECLARE
  2    p  VARCHAR2(30);
  3    n  PLS_INTEGER := 37;
  4  BEGIN
  5    FOR j in 2..ROUND(SQRT(n)) LOOP
  6      IF n MOD j = 0 THEN
  7        p := ' is not a prime number';
  8        GOTO print_now;
  9      END IF;
 10    END LOOP;
 11  
 12    p := ' is a prime number';
 13  
 14    <<print_now>>
 15    DBMS_OUTPUT.PUT_LINE(TO_CHAR(n) || p);
 16  END;
 17  /
37 is a prime number
 
PL/SQL procedure successfully completed.
 
SQL>
A label can appear only before a block (as in Example 4-22) or before a statement (as in Example 4-26), not within a statement, as in Example 4-27.

Example 4-27 Incorrect Label Placement

SQL> DECLARE
  2    done  BOOLEAN;
  3  BEGIN
  4    FOR i IN 1..50 LOOP
  5      IF done THEN
  6        GOTO end_loop;
  7      END IF;
  8      <<end_loop>>
  9    END LOOP;
 10  END;
 11  /
  END LOOP;
  *
ERROR at line 9:
ORA-06550: line 9, column 3:
PLS-00103: Encountered the symbol "END" when expecting one of the following:
( begin case declare exit for goto if loop mod null raise
return select update while with <an identifier>
<a double-quoted delimited-identifier> <a bind variable> <<
continue close current delete fetch lock insert open rollback
savepoint set sql execute commit forall merge pipe purge
 
SQL>
To correct Example 4-27, add a NULL statement, as in Example 4-28.

Example 4-28 Using a NULL Statement to Allow a GOTO to a Label

SQL> DECLARE
  2    done  BOOLEAN;
  3  BEGIN
  4    FOR i IN 1..50 LOOP
  5      IF done THEN
  6        GOTO end_loop;
  7      END IF;
  8      <<end_loop>>
  9      NULL;
 10    END LOOP;
 11  END;
 12  /
 
PL/SQL procedure successfully completed.
 
SQL>
A GOTO statement can branch to an enclosing block from the current block, as in Example 4-29.

Example 4-29 Using a GOTO Statement to Branch to an Enclosing Block

SQL> DECLARE
  2    v_last_name  VARCHAR2(25);
  3    v_emp_id     NUMBER(6) := 120;
  4  BEGIN
  5    <<get_name>>
  6    SELECT last_name INTO v_last_name
  7      FROM employees
  8        WHERE employee_id = v_emp_id;
  9  
 10    BEGIN
 11      DBMS_OUTPUT.PUT_LINE (v_last_name);
 12      v_emp_id := v_emp_id + 5;
 13  
 14      IF v_emp_id < 120 THEN
 15        GOTO get_name;
 16      END IF;
 17    END;
 18  END;
 19  /
Weiss
 
PL/SQL procedure successfully completed.
 
SQL>
The GOTO statement branches to the first enclosing block in which the referenced label appears.

GOTO Statement Restrictions
A GOTO statement cannot branch into an IF statement, CASE statement, LOOP statement, or sub-block.

A GOTO statement cannot branch from one IF statement clause to another, or from one CASE statement WHEN clause to another.

A GOTO statement cannot branch from an outer block into a sub-block (that is, an inner BEGIN-END block).

A GOTO statement cannot branch out of a subprogram. To end a subprogram early, either use the RETURN statement or have GOTO branch to a place right before the end of the subprogram.

A GOTO statement cannot branch from an exception handler back into the current BEGIN-END block. However, a GOTO statement can branch from an exception handler into an enclosing block.

The GOTO statement in Example 4-30 branches into an IF statement, causing an error.

Example 4-30 GOTO Statement Cannot Branch into IF Statement

SQL> DECLARE
  2    valid BOOLEAN := TRUE;
  3  BEGIN
  4    GOTO update_row;
  5  
  6    IF valid THEN
  7      <<update_row>>
  8      NULL;
  9    END IF;
 10  END;
 11  /
  GOTO update_row;
  *
ERROR at line 4:
ORA-06550: line 4, column 3:
PLS-00375: illegal GOTO statement; this GOTO cannot branch to label
'UPDATE_ROW'
ORA-06550: line 6, column 12:
PL/SQL: Statement ignored
 
 
SQL>
Using the NULL Statement
The NULL statement does nothing except pass control to the next statement. Some languages refer to such an instruction as a no-op (no operation). For its syntax, see NULL Statement.

In Example 4-31, the NULL statement emphasizes that only salespersons receive commissions.

Example 4-31 Using the NULL Statement to Show No Action

SQL> DECLARE
  2    v_job_id  VARCHAR2(10);
  3    v_emp_id  NUMBER(6) := 110;
  4  BEGIN
  5    SELECT job_id INTO v_job_id
  6      FROM employees
  7        WHERE employee_id = v_emp_id;
  8  
  9    IF v_job_id = 'SA_REP' THEN
 10      UPDATE employees
 11        SET commission_pct = commission_pct * 1.2;
 12    ELSE
 13      NULL;  -- Employee is not a sales rep
 14    END IF;
 15  END;
 16  /
 
PL/SQL procedure successfully completed.
 
SQL>
The NULL statement is a handy way to create placeholders and stub subprograms. In Example 4-32, the NULL statement lets you compile this subprogram, then fill in the real body later. Using the NULL statement might raise an unreachable code warning if warnings are enabled. See Overview of PL/SQL Compile-Time Warnings.

Example 4-32 Using NULL as a Placeholder When Creating a Subprogram

SQL> CREATE OR REPLACE PROCEDURE award_bonus
  2    (emp_id NUMBER,
  3     bonus NUMBER) AS
  4  BEGIN    -- Executable part starts here
  5    NULL;  -- Placeholder
  6           -- (raises "unreachable code" if warnings enabled)
  7  END award_bonus;
  8  /
 
Procedure created.
 
SQL>
You can use the NULL statement to indicate that you are aware of a possibility, but that no action is necessary. In Example 4-33, the NULL statement shows that you have chosen not to take any action for unnamed exceptions.

Example 4-33 Using the NULL Statement in WHEN OTHER Clause

SQL> CREATE OR REPLACE FUNCTION f
  2    (a INTEGER,
  3     b INTEGER)
  4    RETURN INTEGER
  5  AS
  6  BEGIN
  7    RETURN (a/b);
  8  EXCEPTION
  9    WHEN ZERO_DIVIDE THEN
 10      ROLLBACK;
 11    WHEN OTHERS THEN
 12      NULL;
 13  END;
 14  /
 
Function created.
 
SQL>
See Example 1-16, "Creating a Standalone PL/SQL Procedure".