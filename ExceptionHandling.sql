Exception Handling
https://community.oracle.com/thread/699262

/*
Frequently I see questions and issues around the use of Exception/Error Handling in PL/SQL.  
More often than not the issue comes from the questioners misunderstanding about how PL/SQL is constructed and executed, 
so I thought I'd write a small article covering the key concepts to give a clear picture of how it all hangs together. 
(Note: the examples are just showing examples of the exception handling structure, and should not be taken as truly valid code for ways of handling things)
*/
 

Exception Handling

Contents
1. Understanding Execution Blocks (part 1)
2. Execution of the Execution Block
3. Exceptions
4. Understanding Execution Blocks (part 2)
5. How to continue exection of statements after an exception
6. User defined exceptions
7. Line number of exception
8. Exceptions within code within the exception block


1. Understanding Execution Blocks (part 1)
The first thing that one needs to understand is almost taking us back to the basics of PL/SQL... how a PL/SQL execution block is constructed.

Essentially an execution block is made of 3 sections...

 
+---------------------------+
|    Declaration Section    |
+---------------------------+
|    Statements  Section    |
+---------------------------+
|     Exception Section     |
+---------------------------+


The Declaration section is the part defined between the PROCEDURE/FUNCTION header or the DECLARE keyword (for anonymous blocks) and the BEGIN keyword.  (Optional section)

The Statements section is where your code goes and lies between the BEGIN keyword and the EXCEPTION keyword (or END keyword if there is no EXCEPTION section).  (Mandatory section)

The Exception section is where any exception handling goes and lies between the EXCEPTION keyword at the END keyword. (Optional section)

 

Example of an anonymous block...

DECLARE
  .. declarative statements go here ..
BEGIN
  .. code statements go here ..
EXCEPTION
  .. exception handlers go here ..
END;

 

Example of a procedure/function block...

[CREATE OR REPLACE] (PROCEDURE|FUNCTION) <proc or fn name> [(<parameters>)] [RETURN <datatype>] (IS|AS)
  .. declarative statements go here ..
BEGIN
  .. code statements go here ..
EXCEPTION
  .. exception handlers go here ..
END;

--(Note: The same can also be done for packages, but let's keep it simple)


2. Execution of the Execution Block
This may seem a simple concept, but it's surprising how many people have issues showing they haven't grasped it.  
When an Execution block is entered, the declaration section is processed, creating a scope of variables, types , cursors, etc. 
to be visible to the execution block and then execution enters into the Statements section.  
Each statment in the statements section is executed in turn and when the execution completes the last statment the execution block is exited back to whatever called it.


3. Exceptions
Exceptions generally happen during the execution of statements in the Statements section.  
When an exception happens the execution of statements jumps immediately into the exception section.  
In this section we can specify what exceptions we wish to 'capture' or 'trap' and do one of the two following things...


(Note: The exception section still has access to all the declared items in the declaration section)

 

3.i) Handle the exception
We do this when we recognise what the exception is (most likely it's something we expect to happen) and we have a means of dealing with it so that our application can continue on.

Example...

(without the exception handler the exception is passed back to the calling code, in this case SQL*Plus)

SQL> ed
Wrote file afiedt.buf

  1  declare
  2    v_name VARCHAR2(20);
  3  begin
  4    select ename
  5    into   v_name
  6    from   emp
  7    where  empno = &empno;
  8    dbms_output.put_line(v_name);
  9* end;
SQL> /
Enter value for empno: 123
old   7:   where  empno = &empno;
new   7:   where  empno = 123;
declare
*
ERROR at line 1:
ORA-01403: no data found
ORA-06512: at line 4

 

(with an exception handler, we capture the exception, handle it how we want to, and the calling code is happy that there is no error for it to report)

SQL> ed
Wrote file afiedt.buf

  1  declare
  2    v_name VARCHAR2(20);
  3  begin
  4    select ename
  5    into   v_name
  6    from   emp
  7    where  empno = &empno;
  8    dbms_output.put_line(v_name);
  9  exception
10    when no_data_found then
11      dbms_output.put_line('There is no employee with this employee number.');
12* end;
SQL> /
Enter value for empno: 123
old   7:   where  empno = &empno;
new   7:   where  empno = 123;
There is no employee with this employee number.

 

PL/SQL procedure successfully completed.

 

 

3.ii) Raise the exception
We do this when:-
a) we recognise the exception, handle it but still want to let the calling code know that it happened
b) we recognise the exception, wish to log it happened and then let the calling code deal with it
c) we don't recognise the exception and we want the calling code to deal with it

 

Example of b)

SQL> ed
Wrote file afiedt.buf

  1  declare
  2    v_name VARCHAR2(20);
  3    v_empno NUMBER := &empno;
  4  begin
  5    select ename
  6    into   v_name
  7    from   emp
  8    where  empno = v_empno;
  9    dbms_output.put_line(v_name);
10  EXCEPTION
11    WHEN no_data_found THEN
12      INSERT INTO sql_errors (txt)
13      VALUES ('Search for '||v_empno||' failed.');
14      COMMIT;
15      RAISE;
16* end;
SQL> /
Enter value for empno: 123
old   3:   v_empno NUMBER := &empno;
new   3:   v_empno NUMBER := 123;
declare
*
ERROR at line 1:
ORA-01403: no data found
ORA-06512: at line 15


SQL> select * from sql_errors;

TXT
-----------------------------------------------------
Search for 123 failed.

SQL>

 

Example of c)

SQL> ed
Wrote file afiedt.buf

  1  declare
  2    v_name VARCHAR2(20);
  3    v_empno NUMBER := &empno;
  4  begin
  5    select ename
  6    into   v_name
  7    from   emp
  8    where  empno = v_empno;
  9    dbms_output.put_line(v_name);
10  EXCEPTION
11    WHEN no_data_found THEN
12      INSERT INTO sql_errors (txt)
13      VALUES ('Search for '||v_empno||' failed.');
14      COMMIT;
15      RAISE;
16    WHEN others THEN
17      RAISE;
18* end;
SQL> /
Enter value for empno: 'ABC'
old   3:   v_empno NUMBER := &empno;
new   3:   v_empno NUMBER := 'ABC';
declare
*
ERROR at line 1:
ORA-06502: PL/SQL: numeric or value error: character to number conversion error
ORA-06512: at line 3


SQL> select * from sql_errors;

TXT
-------------------------------------------------------------------------------
Search for 123 failed.

SQL>

 

As you can see from the sql_errors log table, no log was written so the WHEN others exception was the exception that raised the error to the calling code (SQL*Plus)


4. Understanding Execution Blocks (part 2)
Ok, so now we understand the very basics of an execution block and what happens when an exception happens.  Let's take it a step further...

Execution blocks are not just a single simple block in most cases.  Often, during our statements section we have a need to call some reusable code and we do that by calling a procedure or function.  Effectively this nests the procedure or function's code as another execution block within the current statement section so, in terms of execution, we end up with something like...

 

+---------------------------------+
|    Declaration Section          |
+---------------------------------+
|    Statements  Section          |
|            .                    |
|  +---------------------------+  |
|  |    Declaration Section    |  |
|  +---------------------------+  |
|  |    Statements  Section    |  |
|  +---------------------------+  |
|  |     Exception Section     |  |
|  +---------------------------+  |
|            .                    |
+---------------------------------+
|     Exception Section           |
+---------------------------------+

 

Example... (Note: log_trace just writes some text to a table for tracing)

SQL> create or replace procedure a as
  2    v_dummy NUMBER := log_trace('Procedure A''s Declaration Section');
  3  begin
  4    v_dummy := log_trace('Procedure A''s Statement Section');
  5    v_dummy := 1/0; -- cause an exception
  6  exception
  7    when others then
  8      v_dummy := log_trace('Procedure A''s Exception Section');
  9      raise;
10  end;
11  /

Procedure created.

 

SQL> create or replace procedure b as
  2    v_dummy NUMBER := log_trace('Procedure B''s Declaration Section');
  3  begin
  4    v_dummy := log_trace('Procedure B''s Statement Section');
  5    a; -- HERE the execution passes to the declare/statement/exception sections of A
  6  exception
  7    when others then
  8      v_dummy := log_trace('Procedure B''s Exception Section');
  9      raise;
10  end;
11  /

Procedure created.

 

SQL> exec b;
BEGIN b; END;

*
ERROR at line 1:
ORA-01476: divisor is equal to zero
ORA-06512: at "SCOTT.B", line 9
ORA-06512: at line 1


SQL> select * from code_trace;

TXT
-------------------------------------------------------------------------
Procedure B's Declaration Section
Procedure B's Statement Section
Procedure A's Declaration Section
Procedure A's Statement Section
Procedure A's Exception Section
Procedure B's Exception Section

 

6 rows selected.

 

SQL>

 

Likewise, execution blocks can be nested deeper and deeper.


5. How to continue exection of statements after an exception
One of the common questions asked is how to return execution to the statement after the one that created the exception and continue on.

Well, firstly, you can only do this for statements you expect to raise an exception, such as when you want to check if there is no data found in a query.

 

If you consider what's been shown above you could put any statement you expect to cause an exception inside it's own procedure or function with it's own exception section to handle the exception without raising it back to the calling code.  However, the nature of procedures and functions is really to provide a means of re-using code, so if it's a statement you only use once it seems a little silly to go creating individual procedures for these.

 

Instead, you nest execution blocks directly, to give the same result as shown in the diagram at the start of part 4 of this article.

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure b (p_empno IN VARCHAR2) as
  2    v_dummy NUMBER := log_trace('Procedure B''s Declaration Section');
  3  begin
  4    v_dummy := log_trace('Procedure B''s Statement Section');
  5    -- Here we start another execution block nested in the first one...
  6    declare
  7      v_dummy NUMBER := log_trace('Nested Block Declaration Section');
  8    begin
  9      v_dummy := log_trace('Nested Block Statement Section');
10      select empno
11        into   v_dummy
12        from   emp
13       where  empno = p_empno; -- Note: the parameters and variables from
                                     parent execution block are available to use!
14    exception
15      when no_data_found then
16        -- This is an exception we can handle so we don't raise it
17        v_dummy := log_trace('No employee was found');
18        v_dummy := log_trace('Nested Block Exception Section - Exception Handled');
19      when others then
20        -- Other exceptions we can't handle so we raise them
21        v_dummy := log_trace('Nested Block Exception Section - Exception Raised');
22        raise;
23    end;
24    -- ...Here endeth the nested execution block
25    -- As the nested block handled it's exception we come back to here...
26    v_dummy := log_trace('Procedure B''s Statement Section Continued');
27  exception
28    when others then
29      -- We'll only get to here if an unhandled exception was raised
30      -- either in the nested block or in procedure b's statement section
31      v_dummy := log_trace('Procedure B''s Exception Section');
32      raise;
33* end;
SQL> /

Procedure created.

 

SQL> exec b(123);

 

PL/SQL procedure successfully completed.

 

SQL> select * from code_trace;

TXT
---------------------------------------------------------------------------------------
Procedure B's Declaration Section
Procedure B's Statement Section
Nested Block Declaration Section
Nested Block Statement Section
No employee was found
Nested Block Exception Section - Exception Handled
Procedure B's Statement Section Continued

 

7 rows selected.

 

SQL> truncate table code_trace;

Table truncated.

 

SQL> exec b('ABC');
BEGIN b('ABC'); END;

*
ERROR at line 1:
ORA-01722: invalid number
ORA-06512: at "SCOTT.B", line 32
ORA-06512: at line 1


SQL> select * from code_trace;

TXT
---------------------------------------------------------------------------------------
Procedure B's Declaration Section
Procedure B's Statement Section
Nested Block Declaration Section
Nested Block Statement Section
Nested Block Exception Section - Exception Raised
Procedure B's Exception Section

 

6 rows selected.

 

SQL>

 

 

You can see from this that, very simply, the code that we expected may have an exception was able to either handle the exception and return to the outer execution block to continue execution, or if an unexpected exception occurred then it was able to be raised up to the outer exception section.


6. User defined exceptions
There are three sorts of 'User Defined' exceptions.  There are logical situations (e.g. business logic) where, for example, certain criteria are not met to complete a task, and there are existing Oracle errors that you wish to give a name to in order to capture them in the exception section.  The third is raising your own exception messages with our own exception numbers.  Let's look at the first one...

 

Let's say I have tables which detail stock availablility and reorder levels...

 

SQL> select * from reorder_level;

   ITEM_ID STOCK_LEVEL
---------- -----------
         1          20
         2          20
         3          10
         4           2
         5           2

 

SQL> select * from stock;

   ITEM_ID ITEM_DESC  STOCK_LEVEL
---------- ---------- -----------
         1 Pencils             10
         2 Pens                 2
         3 Notepads            25
         4 Stapler              5
         5 Hole Punch           3

SQL>

 

Now, our Business has told the administrative clerk to check stock levels and re-order anything that is below the re-order level, but not to hold stock of more than 4 times the re-order level for any particular item.  As an IT department we've been asked to put together an application that will automatically produce the re-order documents upon the clerks request and, because our company is so tight-ar*ed about money, they don't want to waste any paper with incorrect printouts so we have to ensure the clerk can't order things they shouldn't.

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6      from stock s join reorder_level r on (s.item_id = r.item_id)
  7      where s.item_id = p_item_id;
  8    --
  9    v_stock cur_stock_reorder%ROWTYPE;
10  begin
11    OPEN cur_stock_reorder;
12    FETCH cur_stock_reorder INTO v_stock;
13    IF cur_stock_reorder%NOTFOUND THEN
14      RAISE no_data_found;
15    END IF;
16    CLOSE cur_stock_reorder;
17    --
18    IF v_stock.stock_level >= v_stock.reorder_level THEN
19      -- Stock is not low enough to warrant an order
20      DBMS_OUTPUT.PUT_LINE('Stock has not reached re-order level yet!');
21    ELSE
22      IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
23        -- Required amount is over-ordering
24        DBMS_OUTPUT.PUT_LINE('Quantity specified is too much.  Max for this item: '
                                 ||to_char(v_stock.reorder_limit-v_stock.stock_level));
25      ELSE
26        DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
27        -- Here goes our code to print the order
28      END IF;
29    END IF;
30    --
31  exception
32    WHEN no_data_found THEN
33      CLOSE cur_stock_reorder;
34      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
35* end;
SQL> /

Procedure created.

 

SQL> exec re_order(10,100);
Invalid Item ID.

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(3,40);
Stock has not reached re-order level yet!

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(1,100);
Quantity specified is too much.  Max for this item: 70

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(2,50);
Order OK.  Printing Order...

 

PL/SQL procedure successfully completed.

 

SQL>

 

Ok, so that code works, but it's a bit messy with all those nested IF statements. Is there a cleaner way perhaps?  Wouldn't it be nice if we could set up our own exceptions...

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6      from stock s join reorder_level r on (s.item_id = r.item_id)
  7      where s.item_id = p_item_id;
  8    --
  9    v_stock cur_stock_reorder%ROWTYPE;
10    --
11    -- Let's declare our own exceptions for business logic...
12    exc_not_warranted EXCEPTION;
13    exc_too_much      EXCEPTION;
14  begin
15    OPEN cur_stock_reorder;
16    FETCH cur_stock_reorder INTO v_stock;
17    IF cur_stock_reorder%NOTFOUND THEN
18      RAISE no_data_found;
19    END IF;
20    CLOSE cur_stock_reorder;
21    --
22    IF v_stock.stock_level >= v_stock.reorder_level THEN
23      -- Stock is not low enough to warrant an order
24      RAISE exc_not_warranted;
25    END IF;
26    --
27    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
28      -- Required amount is over-ordering
29      RAISE exc_too_much;
30    END IF;
31    --
32    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
33    -- Here goes our code to print the order
34    --
35  exception
36    WHEN no_data_found THEN
37      CLOSE cur_stock_reorder;
38      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
39    WHEN exc_not_warranted THEN
40      DBMS_OUTPUT.PUT_LINE('Stock has not reached re-order level yet!');
41    WHEN exc_too_much THEN
42      DBMS_OUTPUT.PUT_LINE('Quantity specified is too much.  Max for this item: '
                              ||to_char(v_stock.reorder_limit-v_stock.stock_level));
43* end;
SQL> /

Procedure created.

 

SQL> exec re_order(10,100);
Invalid Item ID.

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(3,40);
Stock has not reached re-order level yet!

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(1,100);
Quantity specified is too much.  Max for this item: 70

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(2,50);
Order OK.  Printing Order...

 

PL/SQL procedure successfully completed.

 

SQL>

 

That's better.  And now we don't have to use all those nested IF statements and worry about it accidently getting to code that will print the order out as, once one of our user defined exceptions is raised, execution goes from the Statements section into the Exception section and all handling of errors is done in one place.

 

Now for the second sort of user defined exception...

 

A new requirement has come in from the Finance department who want to have details shown on the order that show a re-order 'indicator' based on the formula ((maximum allowed stock - current stock)/re-order quantity), so this needs calculating and passing to the report...

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6            ,(((r.stock_level*4)-s.stock_level)/p_quantity) as finance_factor
  7      from stock s join reorder_level r on (s.item_id = r.item_id)
  8      where s.item_id = p_item_id;
  9    --
10    v_stock cur_stock_reorder%ROWTYPE;
11    --
12    -- Let's declare our own exceptions for business logic...
13    exc_not_warranted EXCEPTION;
14    exc_too_much      EXCEPTION;
15  begin
16    OPEN cur_stock_reorder;
17    FETCH cur_stock_reorder INTO v_stock;
18    IF cur_stock_reorder%NOTFOUND THEN
19      RAISE no_data_found;
20    END IF;
21    CLOSE cur_stock_reorder;
22    --
23    IF v_stock.stock_level >= v_stock.reorder_level THEN
24      -- Stock is not low enough to warrant an order
25      RAISE exc_not_warranted;
26    END IF;
27    --
28    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
29      -- Required amount is over-ordering
30      RAISE exc_too_much;
31    END IF;
32    --
33    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
34    -- Here goes our code to print the order, passing the finance_factor
35    --
36  exception
37    WHEN no_data_found THEN
38      CLOSE cur_stock_reorder;
39      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
40    WHEN exc_not_warranted THEN
41      DBMS_OUTPUT.PUT_LINE('Stock has not reached re-order level yet!');
42    WHEN exc_too_much THEN
43      DBMS_OUTPUT.PUT_LINE('Quantity specified is too much.  Max for this item: '
                              ||to_char(v_stock.reorder_limit-v_stock.stock_level));
44* end;
SQL> /

Procedure created.

 

SQL> exec re_order(2,40);
Order OK.  Printing Order...

 

PL/SQL procedure successfully completed.

 

SQL> exec re_order(2,0);
BEGIN re_order(2,0); END;

*
ERROR at line 1:
ORA-01476: divisor is equal to zero
ORA-06512: at "SCOTT.RE_ORDER", line 17
ORA-06512: at line 1


SQL>

 

 

Hmm, there's a problem if the person specifies a re-order quantity of zero.  It raises an unhandled exception.
Well, we could put a condition/check into our code to make sure the parameter is not zero, but again we would be wrapping our code in an IF statement and not dealing with the exception in the exception handler.

We could do as we did before and just include a simple IF statement to check the value and raise our own user defined exception but, in this instance the error is standard Oracle error (ORA-01476) so we should be able to capture it inside the exception handler anyway... however...

 

EXCEPTION
  WHEN ORA-01476 THEN

 

... is not valid.  What we need is to give this Oracle error a name.

This is done by declaring a user defined exception as we did before and then associating that name with the error number using the PRAGMA EXCEPTION_INIT statement in the declaration section.

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6            ,(((r.stock_level*4)-s.stock_level)/p_quantity) as finance_factor
  7      from stock s join reorder_level r on (s.item_id = r.item_id)
  8      where s.item_id = p_item_id;
  9    --
10    v_stock cur_stock_reorder%ROWTYPE;
11    --
12    -- Let's declare our own exceptions for business logic...
13    exc_not_warranted EXCEPTION;
14    exc_too_much      EXCEPTION;
15    --
16    exc_zero_quantity EXCEPTION;
17    PRAGMA EXCEPTION_INIT(exc_zero_quantity, -1476);
18  begin
19    OPEN cur_stock_reorder;
20    FETCH cur_stock_reorder INTO v_stock;
21    IF cur_stock_reorder%NOTFOUND THEN
22      RAISE no_data_found;
23    END IF;
24    CLOSE cur_stock_reorder;
25    --
26    IF v_stock.stock_level >= v_stock.reorder_level THEN
27      -- Stock is not low enough to warrant an order
28      RAISE exc_not_warranted;
29    END IF;
30    --
31    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
32      -- Required amount is over-ordering
33      RAISE exc_too_much;
34    END IF;
35    --
36    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
37    -- Here goes our code to print the order, passing the finance_factor
38    --
39  exception
40    WHEN exc_zero_quantity THEN
41      DBMS_OUTPUT.PUT_LINE('Quantity of 0 (zero) is invalid.');
42    WHEN no_data_found THEN
43      CLOSE cur_stock_reorder;
44      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
45    WHEN exc_not_warranted THEN
46      DBMS_OUTPUT.PUT_LINE('Stock has not reached re-order level yet!');
47    WHEN exc_too_much THEN
48      DBMS_OUTPUT.PUT_LINE('Quantity specified is too much.  Max for this item: '
                              ||to_char(v_stock.reorder_limit-v_stock.stock_level));
49* end;
SQL> /

Procedure created.

SQL> exec re_order(2,0);
Quantity of 0 (zero) is invalid.

PL/SQL procedure successfully completed.

SQL>

 

Lastly, let's look at raising our own exceptions with our own exception numbers...

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6            ,(((r.stock_level*4)-s.stock_level)/p_quantity) as finance_factor
  7      from stock s join reorder_level r on (s.item_id = r.item_id)
  8      where s.item_id = p_item_id;
  9    --
10    v_stock cur_stock_reorder%ROWTYPE;
11    --
12    exc_zero_quantity EXCEPTION;
13    PRAGMA EXCEPTION_INIT(exc_zero_quantity, -1476);
14  begin
15    OPEN cur_stock_reorder;
16    FETCH cur_stock_reorder INTO v_stock;
17    IF cur_stock_reorder%NOTFOUND THEN
18      RAISE no_data_found;
19    END IF;
20    CLOSE cur_stock_reorder;
21    --
22    IF v_stock.stock_level >= v_stock.reorder_level THEN
23      -- Stock is not low enough to warrant an order
24      [b]RAISE_APPLICATION_ERROR(-20000, 'Stock has not reached re-order level yet!');[/b]
25    END IF;
26    --
27    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
28      -- Required amount is over-ordering
29      RAISE_APPLICATION_ERROR(-20001, 'Quantity specified is too much.  Max for this item: '
                                          ||to_char(v_stock.reorder_limit-v_stock.stock_level));
30    END IF;
31    --
32    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
33    -- Here goes our code to print the order, passing the finance_factor
34    --
35  exception
36    WHEN exc_zero_quantity THEN
37      DBMS_OUTPUT.PUT_LINE('Quantity of 0 (zero) is invalid.');
38    WHEN no_data_found THEN
39      CLOSE cur_stock_reorder;
40      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
41    WHEN OTHERS THEN
42      RAISE;
43* end;
SQL> /

Procedure created.

SQL> exec re_order(2,100);
BEGIN re_order(2,100); END;

*
ERROR at line 1:
ORA-20001: Quantity specified is too much.  Max for this item: 78
ORA-06512: at "SCOTT.RE_ORDER", line 42
ORA-06512: at line 1


SQL> exec re_order(3,40);
BEGIN re_order(3,40); END;

*
ERROR at line 1:
ORA-20000: Stock has not reached re-order level yet!
ORA-06512: at "SCOTT.RE_ORDER", line 42
ORA-06512: at line 1


SQL>

 

As you can see from this we have raised exceptions with our own error numbers.  You can use any number from -20000 to -20999 for your own error messages.

As with previous examples, these error numbers can be associated with exception names using the EXCEPTION datatypes and the PRAGMA EXCEPTION_INIT statements in the declaration section.


So there we have it, capturing existing Oracle errors and handling business logic through raising exceptions of our own.


7. Line number / Source of exception
One of the common problems people experience when they use exceptions is actually knowing which line of their code the error occured on.  The problem here is that when you include an exception section in your execution block and then you raise an error from there to the calling code, the calling code sees the exception as having orginated from the line of code in the exception section that raised the error rather than the original line of code.  Look at that last example from the previous section of this article.  It shows that the error happened on line 42 of the re_order procedure, but if we look at line 42, that is the RAISE; statement in the exception block, not the actual line of code where the exception happened.

 

So how do we find out where the error occurred?

 

One answer (perhaps the simplest) is to remove the actual exception handler that is dealing with that error...

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6            ,(((r.stock_level*4)-s.stock_level)/p_quantity) as finance_factor
  7      from stock s join reorder_level r on (s.item_id = r.item_id)
  8      where s.item_id = p_item_id;
  9    --
10    v_stock cur_stock_reorder%ROWTYPE;
11    --
12    exc_zero_quantity EXCEPTION;
13    PRAGMA EXCEPTION_INIT(exc_zero_quantity, -1476);
14  begin
15    OPEN cur_stock_reorder;
16    FETCH cur_stock_reorder INTO v_stock;
17    IF cur_stock_reorder%NOTFOUND THEN
18      RAISE no_data_found;
19    END IF;
20    CLOSE cur_stock_reorder;
21    --
22    IF v_stock.stock_level >= v_stock.reorder_level THEN
23      -- Stock is not low enough to warrant an order
24      RAISE_APPLICATION_ERROR(-20000, 'Stock has not reached re-order level yet!');
25    END IF;
26    --
27    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
28      -- Required amount is over-ordering
29      RAISE_APPLICATION_ERROR(-20001, 'Quantity specified is too much.  Max for this item: '
                                         ||to_char(v_stock.reorder_limit-v_stock.stock_level));
30    END IF;
31    --
32    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
33    -- Here goes our code to print the order, passing the finance_factor
34    --
35  exception
36    WHEN exc_zero_quantity THEN
37      DBMS_OUTPUT.PUT_LINE('Quantity of 0 (zero) is invalid.');
38    WHEN no_data_found THEN
39      CLOSE cur_stock_reorder;
40      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
41* end;
SQL> /

Procedure created.

SQL> exec re_order(3,40);
BEGIN re_order(3,40); END;

*
ERROR at line 1:
ORA-20000: Stock has not reached re-order level yet!
ORA-06512: at "SCOTT.RE_ORDER", line 24
ORA-06512: at line 1


SQL>

 

Now, because the code is not capturing the exception itself, the original line number is passed up until it gets to a point where it is handled (in this case where it is displayed by SQL*Plus)

An alternative is to use the DBMS_UTILITY.FORMAT_ERROR_BACKTRACE function.  Whilst this doesn't provide the error itself, it does provide a full trace back through execution blocks to the source of the error.

 

SQL> ed
Wrote file afiedt.buf

  1  create or replace procedure re_order(p_item_id NUMBER, p_quantity NUMBER) is
  2    cursor cur_stock_reorder is
  3      select s.stock_level
  4            ,r.stock_level as reorder_level
  5            ,(r.stock_level*4) as reorder_limit
  6            ,(((r.stock_level*4)-s.stock_level)/p_quantity) as finance_factor
  7      from stock s join reorder_level r on (s.item_id = r.item_id)
  8      where s.item_id = p_item_id;
  9    --
10    v_stock cur_stock_reorder%ROWTYPE;
11    --
12    exc_zero_quantity EXCEPTION;
13    PRAGMA EXCEPTION_INIT(exc_zero_quantity, -1476);
14  begin
15    OPEN cur_stock_reorder;
16    FETCH cur_stock_reorder INTO v_stock;
17    IF cur_stock_reorder%NOTFOUND THEN
18      RAISE no_data_found;
19    END IF;
20    CLOSE cur_stock_reorder;
21    --
22    IF v_stock.stock_level >= v_stock.reorder_level THEN
23      -- Stock is not low enough to warrant an order
24      RAISE_APPLICATION_ERROR(-20000, 'Stock has not reached re-order level yet!');
25    END IF;
26    --
27    IF v_stock.stock_level + p_quantity > v_stock.reorder_limit THEN
28      -- Required amount is over-ordering
29      RAISE_APPLICATION_ERROR(-20001, 'Quantity specified is too much.  Max for this item: '
                                         ||to_char(v_stock.reorder_limit-v_stock.stock_level));
30    END IF;
31    --
32    DBMS_OUTPUT.PUT_LINE('Order OK.  Printing Order...');
33    -- Here goes our code to print the order, passing the finance_factor
34    --
35  exception
36    WHEN exc_zero_quantity THEN
37      DBMS_OUTPUT.PUT_LINE('Quantity of 0 (zero) is invalid.');
38    WHEN no_data_found THEN
39      CLOSE cur_stock_reorder;
40      DBMS_OUTPUT.PUT_LINE('Invalid Item ID.');
41    WHEN OTHERS THEN
42      DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
43      RAISE;
44* end;
SQL> /

Procedure created.

SQL> exec re_order(3,40);
ORA-06512: at "SCOTT.RE_ORDER", line 24

BEGIN re_order(3,40); END;

*
ERROR at line 1:
ORA-20000: Stock has not reached re-order level yet!
ORA-06512: at "SCOTT.RE_ORDER", line 43
ORA-06512: at line 1


SQL>

 

 

Another issue often encountered is when there are nested execution blocks that raise, capture, raise again etc. the exceptions.  It can be quite messy to keep track of the source of an error, so a good error logging mechanism writing the error information as it happens to a table using autonomous transactions and the information in the DBMS_UTILITY.FORMAT_ERROR_BACKTRACE is a well worthwhile method of dealing with this

 

SQL> ed
Wrote file afiedt.buf

  1  begin
  2    begin
  3      begin
  4        raise no_data_found;
  5      exception
  6        when others then
  7          raise_application_error(-20000,'nesting level 3 exception');
  8      end;
  9    exception
10      when others then
11        raise_application_error(-20000,'nesting level 2 exception');
12    end;
13  exception
14    when others then
15      raise_application_error(-20000,'nesting level 1 exception');
16* end;
SQL> /
begin
*
ERROR at line 1:
ORA-20000: nesting level 1 exception
ORA-06512: at line 15

 

Here we can only see that an error occured in the top level of execution.

There is another parameter on RAISE_APPLICATION_ERROR we can use if we are using that procedure in our code...

SQL> ed
Wrote file afiedt.buf

  1  begin
  2    begin
  3      begin
  4        raise no_data_found;
  5      exception
  6        when others then
  7          raise_application_error(-20000,'nesting level 3 exception', true);
  8      end;
  9    exception
10      when others then
11        raise_application_error(-20000,'nesting level 2 exception', true);
12    end;
13  exception
14    when others then
15      raise_application_error(-20000,'nesting level 1 exception', true);
16* end;
SQL> /
begin
*
ERROR at line 1:
ORA-20000: nesting level 1 exception
ORA-06512: at line 15
ORA-20000: nesting level 2 exception
ORA-20000: nesting level 3 exception
ORA-01403: no data found

 

This propagates the error stack back up to the calling level, so at least now we can see that the error occured at the 3rd nested level and that it was a "no data found" error.

 

Finally, if we incorporate the DBMS_UTILITY.FORMAT_ERROR_BACKTRACE with that we can show all the information back down to the actual line where the error occurred.

SQL> ed
Wrote file afiedt.buf

  1  begin
  2    begin
  3      begin
  4        raise no_data_found;
  5      exception
  6        when others then
  7          dbms_output.put_line(dbms_utility.format_error_backtrace);
  8          raise_application_error(-20000,'nesting level 3 exception', true);
  9      end;
10    exception
11      when others then
12        dbms_output.put_line(dbms_utility.format_error_backtrace);
13        raise_application_error(-20000,'nesting level 2 exception', true);
14    end;
15  exception
16    when others then
17      dbms_output.put_line(dbms_utility.format_error_backtrace);
18      raise_application_error(-20000,'nesting level 1 exception', true);
19* end;
SQL> /
ORA-06512: at line 4

ORA-06512: at line 8

ORA-06512: at line 13

begin
*
ERROR at line 1:
ORA-20000: nesting level 1 exception
ORA-06512: at line 18
ORA-20000: nesting level 2 exception
ORA-20000: nesting level 3 exception
ORA-01403: no data found


SQL>

 

In summary there are various means and methods for tracing where the exception occurred and which method you use depends on your own requirements and needs for logging and/or handling errors.


8. Exceptions within code within the exception block
This last section of the article is just a light finishing touch to it really.
What happens when an exception occurs inside the exception section of the execution block?

Well it's quite simple really, if you haven't figured it out already...

 

There are two things that will happen... either...

a) The exception will be raised up to the exception handler of the calling execution block to be dealt with...

SQL> ed
Wrote file afiedt.buf

  1  begin
  2    begin
  3      begin
  4        raise no_data_found;
  5      exception
  6        when others then
  7          dbms_output.put_line(1/0); -- Ooops!
  8          raise_application_error(-20000,'nesting level 3 exception', true);
  9      end;
10    exception
11      when others then
12        dbms_output.put_line(dbms_utility.format_error_backtrace);
13        raise_application_error(-20000,'nesting level 2 exception', true);
14    end;
15  exception
16    when others then
17      dbms_output.put_line(dbms_utility.format_error_backtrace);
18      raise_application_error(-20000,'nesting level 1 exception', true);
19* end;
SQL> /
ORA-06512: at line 7

ORA-06512: at line 13

begin
*
ERROR at line 1:
ORA-20000: nesting level 1 exception
ORA-06512: at line 18
ORA-20000: nesting level 2 exception
ORA-01476: divisor is equal to zero
ORA-01403: no data found


SQL>

 

From this example you can see that the exception that happened on line 7 (within the exception handler) has prevented the continuing execution of the code in that exception handler and has raised the exception straight back to the nested level above (2 in this case), although we do still have the "no data found" exception on the error stack so we can detect two errors at once.  Smart eh!

 

b) The other thing that can happen is if the exception handler itself has a nested execution block...

+---------------------------------+
|    Declaration Section          |
+---------------------------------+
|    Statements  Section          |
+---------------------------------+
|     Exception Section           |
|            .                    |
|  +---------------------------+  |
|  |    Declaration Section    |  |
|  +---------------------------+  |
|  |    Statements  Section    |  |
|  +---------------------------+  |
|  |     Exception Section     |  |
|  +---------------------------+  |
|            .                    |
+---------------------------------+

 

In this case the exception will be handled, if possible, in the exception handler of that execution block before returning to the following statement in the exception handler...

 

SQL> ed
Wrote file afiedt.buf

  1  begin
  2    begin
  3      begin
  4        raise no_data_found;
  5      exception
  6        when others then
  7          [b]begin -- nested execution block in the exception handler
  8            dbms_output.put_line(1/0);
  9          exception
10            when others then
11              null; -- exception handled!
12          end;[/b]
13          raise_application_error(-20000,'nesting level 3 exception', true);
14      end;
15    exception
16      when others then
17        dbms_output.put_line(dbms_utility.format_error_backtrace);
18        raise_application_error(-20000,'nesting level 2 exception', true);
19    end;
20  exception
21    when others then
22      dbms_output.put_line(dbms_utility.format_error_backtrace);
23      raise_application_error(-20000,'nesting level 1 exception', true);
24* end;
SQL> /
ORA-06512: at line 13

ORA-06512: at line 18

begin
*
ERROR at line 1:
ORA-20000: nesting level 1 exception
ORA-06512: at line 23
ORA-20000: nesting level 2 exception
ORA-20000: nesting level 3 exception
ORA-01403: no data found


SQL>

 

By the way, I wouldn't recommend using WHEN OTHERS THEN NULL; in production code otherwise you'll prevent any real errors from being found and probably get the sack.   I just did it to demonstrate.


OK. Well I hope that's given some insight into Exceptions and Exception handling for those who need to know.  Turned out to be a slightly larger article than I intended, but I think it covers most of the basics.

 

Enjoy.