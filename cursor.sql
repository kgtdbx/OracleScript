
!!!!!!!!!!!!!!!!!
We use EXIT WHEN cur%NOTFOUND; when doing FETCH cur INTO cur_collection; based on cursor ;

We use EXIT WHEN l_table_rowtype.COUNT = 0; when we doing FETCH cur BULK COLLECT INTO l_table_rowtype LIMIT c_limit; based on index by collection type;

!!!!!!!!!!!!!!!!
Kicking the %NOTFOUND Habit 
I was very happy to learn that Oracle Database 10g will automatically optimize my cursor FOR loops to perform at speeds comparable to BULK COLLECT. 
Unfortunately, my company is still running on Oracle9i Database, so I have started converting my cursor FOR loops to BULK COLLECTs. 
I have run into a problem: I am using a LIMIT of 100, and my query retrieves a total of 227 rows, but my program processes only 200 of them. 
[The query is shown in Listing 2.] What am I doing wrong? 

Code Listing 2: BULK COLLECT, %NOTFOUND, and missing rows
PROCEDURE process_all_rows
IS
   CURSOR table_with_227_rows_cur 
   IS 
      SELECT * FROM table_with_227_rows;
   TYPE table_with_227_rows_aat IS 
      TABLE OF table_with_227_rows_cur%ROWTYPE
      INDEX BY PLS_INTEGER;
   l_table_with_227_rows table_with_227_rows_aat;
BEGIN   
   OPEN table_with_227_rows_cur;
   LOOP
      FETCH table_with_227_rows_cur 
         BULK COLLECT INTO l_table_with_227_rows LIMIT 100;
         EXIT WHEN table_with_227_rows_cur%NOTFOUND;     /* cause of missing rows */
      FOR indx IN 1 .. l_table_with_227_rows.COUNT 
      LOOP
         analyze_compensation (l_table_with_227_rows(indx));
      END LOOP;
   END LOOP;
   CLOSE table_with_227_rows_cur;
END process_all_rows;
You came so close to a completely correct conversion from your cursor FOR loop to BULK COLLECT! 
Your only mistake was that you didn''t give up the habit of using the %NOTFOUND cursor attribute in your EXIT WHEN clause.
The statement
EXIT WHEN 
table_with_227_rows_cur%NOTFOUND;
makes perfect sense when you are fetching your data one row at a time. With BULK COLLECT, however, that line of code can result in incomplete data processing, 
precisely as you described.
Let''s examine what is happening when you run your program and why those last 27 rows are left out. After opening the cursor and entering the loop, 
here is what occurs:
1. The fetch statement retrieves rows 1 through 100.
2. table_with_227_rows_cur%NOTFOUND evaluates to FALSE, and the rows are processed.
3. The fetch statement retrieves rows 101 through 200.
4. table_with_227_rows_cur%NOTFOUND evaluates to FALSE, and the rows are processed.
5. The fetch statement retrieves rows 201 through 227.
6. table_with_227_rows_cur%NOTFOUND evaluates to TRUE , and the loop is terminated?with 27 rows left to process!
When you are using BULK COLLECT and collections to fetch data from your cursor, 
you should never rely on the cursor attributes to decide whether to terminate your loop and data processing. 
So, to make sure that your query processes all 227 rows, replace this statement:
EXIT WHEN 
table_with_227_rows_cur%NOTFOUND; 
with
EXIT WHEN 
l_table_with_227_rows.COUNT = 0; 
Generally, you should keep all of the following in mind when working with BULK COLLECT:
The collection is always filled sequentially, starting from index value 1.
It is always safe (that is, you will never raise a NO_DATA_FOUND exception) 
to iterate through a collection from 1 to collection .COUNT when it has been filled with BULK COLLECT.
The collection is empty when no rows are fetched.
Always check the contents of the collection (with the COUNT method) to see if there are more rows to process.
Ignore the values returned by the cursor attributes, especially %NOTFOUND.


!!!!!!!!!!!!!!!!!!          

/*  --https://blogs.oracle.com/oraclemagazine/working-with-cursors
Choosing the Right Way to Query 
This article has shown that the PL/SQL language offers many different ways, ranging from the simplest SELECT-INTO implicit query to the much more complicated cursor variable, to use cursors to fetch data from relational tables into local variables.

Here are some guidelines to help you decide which technique to use:

When fetching a single row, use SELECT-INTO or EXECUTE IMMEDIATE-INTO (if your query is dynamic). Do not use an explicit cursor or a cursor FOR loop.

When fetching all the rows from a query, use a cursor FOR loop unless the body of the loop executes one or more DML statements (INSERT, UPDATE, DELETE, or MERGE). In such a case, you will want to switch to BULK COLLECT and FORALL.

Use an explicit cursor when you need to fetch with BULK COLLECT, but limit the number of rows returned with each fetch.

Use an explicit cursor when you are fetching multiple rows but might conditionally exit before all rows are fetched.

Use a cursor variable when the query you are fetching from varies at runtime (but isn’t necessarily dynamic) and especially when you need to pass a result back to a non-PL/SQL host environment.

Use EXECUTE IMMEDIATE to query data only when you cannot fully construct the SELECT statement while writing your code.

Move SELECT-INTOs into Functions
PL/SQL developers frequently need to retrieve data for a single row in a table, specified (usually) by a primary key value, and often find themselves writing the same primary key lookup again and again. A much better approach is to move each of your SELECT-INTO queries into a function whose sole purpose is to serve up the requested row. So instead of this:

DECLARE
   l_employee   employees%ROWTYPE;
BEGIN
   SELECT *
     INTO l_employee
     FROM employees
    WHERE employee_id = 138;
   DBMS_OUTPUT.put_line (
      l_employee.last_name);
END;
you would first create a function:

CREATE OR REPLACE FUNCTION row_for_employee_id (
   employee_id_in IN employees.employee_id%TYPE)
   RETURN employees%ROWTYPE
IS
   l_employee   employees%ROWTYPE;
BEGIN
   SELECT *
     INTO l_employee
     FROM employees e
    WHERE e.employee_id = 
       row_for_employee_id.employee_id_in;
   RETURN l_employee;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END;
Then the anonymous block for your primary key lookup would be DECLARE l_employee employees%ROWTYPE; BEGIN l_employee := row_for_employee_id (138); DBMS_OUTPUT.put_line ( l_employee.last_name); END;

Best of all, the next time you need to get a row from the employees table for an ID, you’ll just call the function.

There are two big advantages to this approach:

Your productivity increases, because you can write less code and rely on prebuilt, pretested, reusable programs.

If you ever need to change the way you look up that single row, you’ll make the change in one place (the “single point of definition”) and all programs that call the function will immediately use the improved version.

Note that I included in the function an exception handler that traps NO_DATA_FOUND and simply returns a NULL record. During execution of a SELECT-INTO, the absence of data is often not actually an error but, rather, just a data condition. So it is quite common to trap the exception and return an indicator that no row was found. (NULL is usually, but not necessarily, a good indicator of this state of affairs.) The programmer who calls the function gets to decide how to treat the NO_DATA_FOUND condition.

*/




/*  -- from http://www.oracle.com/technetwork/issue-archive/2013/13-mar/o23plsql-1906474.html
The central purpose of the Oracle PL/SQL language is to make it as easy and efficient as possible to query and change the contents of tables in a database. 
You must, of course, use the SQL language to access tables, and each time you do so, you use a cursor to get the job done. 
A cursor is a pointer to a private SQL area that stores information about the processing of a SELECT or data manipulation language (DML) statement (INSERT, UPDATE, DELETE, or MERGE). 
Cursor management of DML statements is handled by Oracle Database, but PL/SQL offers several ways to define and manipulate cursors to execute SELECT statements. 
This article focuses on the most-common ways programmers execute SELECT statements in PL/SQL, namely 

- Using the SELECT-INTO statement

- Fetching from an explicit cursor

- Using a cursor FOR loop

- Using EXECUTE IMMEDIATE INTO for dynamic queries

- Using cursor variables 

If the SELECT statement identifies more than one row to be fetched, Oracle Database will raise the TOO_MANY_ROWS exception. 
If the statement doesn’t identify any rows to be fetched, Oracle Database will raise the NO_DATA_FOUND exception.


Here are some things to keep in mind when working with explicit cursors:

- If the query does not identify any rows, Oracle Database will not raise NO_DATA_FOUND. Instead, the cursor_name%NOTFOUND attribute will return TRUE.

- Your query can return more than one row, and Oracle Database will not raise TOO_MANY_ROWS.

- When you declare a cursor in a package (that is, not inside a subprogram of the package) and the cursor is opened, it will stay open until you explicitly close it or your session is terminated.

- When the cursor is declared in a declaration section (and not in a package), Oracle Database will also automatically close it when the block in which it is declared terminates. 
    It is still, however, a good idea to explicitly close the cursor yourself. If the cursor is moved to a package, you will have the now necessary CLOSE already in place. 
    And if it is local, then including a CLOSE statement will also show other developers and your manager that you are paying attention. 

    
Using the Cursor FOR Loop
The cursor FOR loop is an elegant and natural extension of the numeric FOR loop in PL/SQL. 
With a numeric FOR loop, the body of the loop executes once for every integer value between the low and high values specified in the range. 
With a cursor FOR loop, the body of the loop is executed for each row returned by the query.
  */


BEGIN
   FOR employee_rec IN (
        SELECT *
          FROM employees
         WHERE department_id = 10)
   LOOP
      DBMS_OUTPUT.put_line (
         employee_rec.last_name);
   END LOOP;
END;
 
--You can also use a cursor FOR loop with an explicitly declared cursor: 

DECLARE
   CURSOR employees_in_10_cur
   IS
      SELECT *
        FROM employees
       WHERE department_id = 10;
BEGIN
   FOR employee_rec 
   IN employees_in_10_cur
   LOOP
      DBMS_OUTPUT.put_line (
         employee_rec.last_name);
   END LOOP;
END;
  
/*
The nice thing about the cursor FOR loop is that Oracle Database opens the cursor, declares a record by using %ROWTYPE against the cursor, fetches each row into a record, 
and then closes the loop when all the rows have been fetched (or the loop terminates for any other reason).

Best of all, Oracle Database automatically optimizes cursor FOR loops to perform similarly to BULK COLLECT queries (covered in “Bulk Processing with BULK COLLECT and FORALL,” 
in the September/October 2012 issue of Oracle Magazine). So even though your code looks as if you are fetching one row at a time, 
Oracle Database will actually fetch 100 rows at a time—and enable you to work with each row individually.
*/  
  
/*
Cursor Variables
A cursor variable is, as you might guess from its name, a variable that points to a cursor or a result set. 
Unlike with an explicit cursor, you can pass a cursor variable as an argument to a procedure or a function. There are several excellent use cases for cursor variables, including the following: 

Pass a cursor variable back to the host environment that called the program unit—the result set can be “consumed” for display or other processing.

Construct a result set inside a function, and return a cursor variable to that set. This is especially handy when you need to use PL/SQL, in addition to SQL, to build the result set.

Pass a cursor variable to a pipelined table function—a powerful but quite advanced optimization technique. 
A full explanation of cursor variables, including the differences between strong and weak REF CURSOR types, is beyond the scope of this article.

Instead, I will show the basic syntax for working with cursor variables and identify situations in which you might consider using this feature.

Cursor variables can be used with either embedded (static) or dynamic SQL. 
Listing 2 includes the names_for function, which returns a cursor variable that fetches either employee or department names, depending on the argument passed to the function.
*/

--Code Listing 2: Block and description of the names_for function, which returns a cursor variable 

CREATE OR REPLACE FUNCTION names_for (
       name_type_in IN VARCHAR2)
    RETURN SYS_REFCURSOR
 IS
    l_return   SYS_REFCURSOR;
 BEGIN
    CASE name_type_in
       WHEN 'EMP'
       THEN
          OPEN l_return FOR
               SELECT last_name
                 FROM employees
             ORDER BY employee_id;
       WHEN 'DEPT'
       THEN
          OPEN l_return FOR
               SELECT department_name
                 FROM departments
             ORDER BY department_id;
    END CASE;

    RETURN l_return;
 END names_for;
  
--  Here is a block that uses the names_for function to display all the names in the departments table: 

DECLARE
   l_names   SYS_REFCURSOR;
   l_name    VARCHAR2 (32767);
BEGIN
   l_names := names_for ('DEPT');

   LOOP
      FETCH l_names INTO l_name;

      EXIT WHEN l_names%NOTFOUND;
      DBMS_OUTPUT.put_line (l_name);
   END LOOP;

   CLOSE l_names;
END;


--
  CREATE OR REPLACE FUNCTION row_for_employee_id (
   employee_id_in IN employees.employee_id%TYPE)
   RETURN employees%ROWTYPE
IS
   l_employee   employees%ROWTYPE;
BEGIN
   SELECT *
     INTO l_employee
     FROM employees e
    WHERE e.employee_id = 
       row_for_employee_id.employee_id_in;

   RETURN l_employee;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END;
  
  

  Best practices for knowing your LIMIT and kicking %NOTFOUND  
http://www.oracle.com/technetwork/issue-archive/2008/08-mar/o28plsql-095155.html  
  
  
  
  
  
--I showed you how to do this, you simply code: 

begin
  for x in (select first_name, salary from employee ) 
  loop
     dbms_output.put_line( x.first_name || ' ' || x.salary );
  end loop;
end;
/

---------------------------
declare
   cursor c is select ... from ...;
   l_rec c%rowtype;
begin
   open c;
   loop
      fetch c into l_rec;
      EXIT WHEN C%NOTFOUND;
      process l_rec here...
   end loop;
   close c;
end;
/
---------------------------
declare 
--If you EXPECT the query to return more then one row, you would code: 

for x in ( select * from t where ... ) 
loop 
-- process the X record here 
end loop; 

--If you expect the query to return AT LEAST one record and AT MOST one record, you would code: 
begin 
select * into .... 
from t where .... 
process.... 
exception 
when NO_DATA_FOUND then 
error handling code when no record is found 
when TOO_MANY_ROWS then 
error handling code when too many records are found 
end; 

--If you just want the FIRST record 
declare 
c1 cursor for select * from t where ... 
begin 
open c1; 
fetch c1 into .. 
if ( c1%notfound ) then 
error handling for no record found 
end if; 
close c1; 
end; 

-----------------------------------------------

begin
  FOR CUR IN (SELECT * FROM irds_schedule)
LOOP

  for cus in (SELECT a.instrument_id, a.market_dt  
              FROM (
                     SELECT ich.instrument_id,ich.market_dt, DENSE_RANK()
                     OVER (PARTITION BY ich.instrument_id ORDER BY ich.market_dt DESC) cnt
                     FROM index_constituent_h ich
                     WHERE 1=1
                     GROUP BY ich.instrument_id, ich.market_dt
                     )a
                      WHERE  a.cnt=cur.day_retention)
    loop
      
    dbms_output.put_line( 'instrument_id ' || cus.instrument_id||' ' || 'market_dt '|| cus.market_dt);
    
      end loop;
END LOOP;
end;
----------íåÿâíûé êóðñîð------------
--set autoprint off
variable b_rows_del varchar2(30)
declare
v_emp_id employees.employee_id%type :=106;
begin
delete from employees e where e.employee_id = v_emp_id;
:b_rows_del:= (sql%rowcount||' rows deleted');
end;
/
print b_rows_del
------------------------------------

function GetBindings(InHostProductId in number )
    return varchar2
    is
        v2ReturnValue varchar2(500);
        cursor cBinding (InHostProductId in number)
           is select b.binding_value 
              from (select binding_value, host_product_num 
                      from v_prdct_depos_internet_bnk_mv
                     union
                    select binding_value, host_product_num
                      from v_prdct_depos_sales_office_mv) b
                     where b.host_product_num = InHostProductId;
    begin
           open cBinding(InHostProductId);
             fetch cBinding into v2ReturnValue;
                  if ( cBinding%notfound ) then 
                    v2ReturnValue:=null;
                  end if; 
           close cBinding;
    return v2ReturnValue; 
    end;
  ------------------How to test------------------ 
  
/*
set serveroutput on
variable rc refcursor;
exec products_pak.GetProductsForAccountsCreaInd( :rc );
print rc;
*/

set sqlblanklines on
set serveroutput on
--variable ret number;
DECLARE
TYPE tFacilitiesBaseLoansNew IS TABLE OF FACILITIES_LOANS.cFacilitiesBaseLoansNew%ROWTYPE
        INDEX BY PLS_INTEGER;
l_FacilitiesBaseLoansNew tFacilitiesBaseLoansNew;	 
v_Return NUMBER;
BEGIN
OPEN FACILITIES_LOANS.cFacilitiesBaseLoansNew(inTheDate => date'2018-01-31', 
							    inDate =>date'2018-01-31', 
							    inFonixDate =>date'2018-01-31',
							    inCollateralDate =>date'2018-01-31', 
							    inMortgageDimTime =>35586,
							    inId => 321406);
LOOP
      FETCH FACILITIES_LOANS.cFacilitiesBaseLoansNew
         BULK COLLECT INTO l_FacilitiesBaseLoansNew LIMIT 1;

         EXIT WHEN FACILITIES_LOANS.cFacilitiesBaseLoansNew%NOTFOUND;     /* cause of missing rows */

      FOR indx IN 1 .. l_FacilitiesBaseLoansNew.COUNT 
      LOOP
         v_Return:=FACILITIES_LOANS.PAYMENTSLEFTNEW( INFACILITIES => l_FacilitiesBaseLoansNew(indx));
      END LOOP;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);   
   CLOSE FACILITIES_LOANS.cFacilitiesBaseLoansNew;
--  :ret := v_Return;
--DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
END;
/
--print ret;
--/


--second variant
set serveroutput on
DECLARE
l_FacilitiesBaseLoansNew FACILITIES_LOANS.cFacilitiesBaseLoansNew%ROWTYPE;
v_Return NUMBER;
BEGIN
open FACILITIES_LOANS.cFacilitiesBaseLoansNew(inTheDate => date'2018-03-31', 
							    inDate =>date'2018-03-31', 
							    inFonixDate =>date'2018-03-31',
							    inCollateralDate =>date'2018-03-31', 
							    inMortgageDimTime =>35586,
							    inId => 321406);
   loop
      fetch FACILITIES_LOANS.cFacilitiesBaseLoansNew into l_FacilitiesBaseLoansNew;
      EXIT WHEN FACILITIES_LOANS.cFacilitiesBaseLoansNew%NOTFOUND;
    -- select FACILITIES_LOANS.PAYMENTSLEFTNEW( INFACILITIES => l_FacilitiesBaseLoansNew) into v_Return from dual;  --error
    v_Return:= l_FacilitiesBaseLoansNew.payments_left;
    --v_Return:=FACILITIES_LOANS.PAYMENTSLEFTNEW( INFACILITIES => l_FacilitiesBaseLoansNew);
   end loop;
   close FACILITIES_LOANS.cFacilitiesBaseLoansNew;
  DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
END;
/

--------------------------------
DECLARE
  CURSOR c (location NUMBER DEFAULT 1700) IS
    SELECT d.department_name,
           e.last_name manager,
           l.city
    FROM departments d, employees e, locations l
    WHERE l.location_id = location
      AND l.location_id = d.location_id
      AND d.department_id = e.department_id
    ORDER BY d.department_id;
 
  PROCEDURE print_depts IS
    dept_name  departments.department_name%TYPE;
    mgr_name   employees.last_name%TYPE;
    city_name  locations.city%TYPE;
  BEGIN
    LOOP
      FETCH c INTO dept_name, mgr_name, city_name;
      EXIT WHEN c%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(dept_name || ' (Manager: ' || mgr_name || ')');
    END LOOP;
  END print_depts;
 
BEGIN
  DBMS_OUTPUT.PUT_LINE('DEPARTMENTS AT HEADQUARTERS:');
  DBMS_OUTPUT.PUT_LINE('--------------------------------');
  OPEN c;
  print_depts; 
  DBMS_OUTPUT.PUT_LINE('--------------------------------');
  CLOSE c;
 
  DBMS_OUTPUT.PUT_LINE('DEPARTMENTS IN CANADA:');
  DBMS_OUTPUT.PUT_LINE('--------------------------------');
  OPEN c(1800); -- Toronto
  print_depts; 
  CLOSE c;
  OPEN c(1900); -- Whitehorse
  print_depts; 
  CLOSE c;
END;
/
------------------------------------------
--test sys refcursor----
--type in spec of package 
Type cuForeignPaymentsSearch is ref cursor;

-- procedure in body
PROCEDURE pGetForeignPaymentsSearch 
  ( 
    IdDateFrom              IN    DATE,
    IdDateTo                IN    DATE,
    IvCurrency              IN    VARCHAR2,
    IvStatus                IN    VARCHAR2,
    InForeignAmountFrom     IN    NUMBER,
	InForeignAmountTo       IN    NUMBER,
    IvPayerSSN              IN    VARCHAR2,
    IvSearchText            IN    VARCHAR2,
    IvOrderColumn           IN    VARCHAR2,
    IvOrderAscending        IN    VARCHAR2, 
    InFirstRowNumber        IN    NUMBER,
    InLastRowNumber         IN    NUMBER,
    OnErrorNumber           OUT   NUMBER,
    OvErrorMessage          OUT   VARCHAR2,
    OcuForeignPayments      OUT   cuForeignPaymentsSearch
  ) is
 orderColumn VARCHAR2(50):='I.DAGS_SKRAD';
begin

    CASE IvOrderColumn
        WHEN 'SendDt'  THEN orderColumn:='DAGS_SKRAD';
        WHEN 'CostAmt' THEN orderColumn:='KOSTNADUR';
        WHEN 'CurrencyCd' THEN orderColumn:='MYNT';
        WHEN 'ForeignAmt' THEN orderColumn:='ERLEND_FJARHAED';
        WHEN 'RecipientName' THEN orderColumn:='NAFN_VIDTAKANDA';
        WHEN 'StatusCd' THEN orderColumn:='STADA';
        ELSE orderColumn:='I.DAGS_SKRAD'; --SendDt
    END CASE;

      OPEN OcuForeignPayments FOR
        WITH ResultList
            AS( 
                SELECT  TRUNC(I.DAGS_SKRAD) DAGS_SKRAD,
                        EG.BUNKANUMER,
                        EG.LINUNUMER,
                        EG.MYNT,
                        EG.ERLEND_FJARHAED,
                        EG.KOSTNADUR, 
                        EG.MYNT_GREIDANDA, 
                        EG.GENGI_FYRIR_SKULDFAERSLU,
                        EG.NAFN_VIDTAKANDA,
                        decode(EG.GENGI,1,EG.GENGI_FYRIR_SKULDFAERSLU,EG.GENGI) GENGI,
                        EG.STADA,
                        TRUNC(EG.DAGS_FRAMKV) DAGS_FRAMKV, 
                        (EG.BANKI_GREIDANDA || '-' || EG.HOFUDBOK_GREIDANDA || '-' || EG.REIKNINGSNUMER_GREIDANDA) AS UTREIKNINGUR,
                        nvl(EG.ISLENSK_UPPHAED,(EG.ERLEND_FJARHAED*decode(EG.GENGI,1,EG.GENGI_FYRIR_SKULDFAERSLU,EG.GENGI))) ISK_FJARHAED,
                        I.STADA AS INNTAK_STADA, 
                        I.notandi, 
                        EG.upphaed_greidanda, 
                        EG.AUDKENNI_I_IBAS,
                        ROWNUM as rn
                FROM
                    SKJALINA.ERLEND_GREIDSLA EG, SKJALINA.INNTAK I
                WHERE
                    EG.BUNKANUMER = I.BUNKANUMER AND 
                    EG.kennitala_greidanda = IvPayerSSN AND 
                    I.DAGS_SKRAD between IdDateFrom AND IdDateTo+1 AND
                    EG.MYNT = NVL(IvCurrency,EG.MYNT) AND
                    EG.STADA = NVL(IvStatus,EG.STADA) AND
                    EG.ERLEND_FJARHAED >= NVL(InForeignAmountFrom,EG.ERLEND_FJARHAED) AND
                    EG.ERLEND_FJARHAED <= NVL(InForeignAmountTo,EG.ERLEND_FJARHAED) 
                ORDER BY
                    orderColumn DESC, I.DAGS_SKRAD DESC,EG.NAFN_VIDTAKANDA,EG.ERLEND_FJARHAED) 
     SELECT t.*, (Select count(1) from ResultList) RowsCount
        FROM  ResultList t
     where t.rn BETWEEN InFirstRowNumber AND InLastRowNumber;          
end;


--test
set serveroutput on
variable    rc refcursor;
exec SKJALINA.FOREIGNPAYMENTS.PGETFOREIGNPAYMENTSSEARCH(date'2002-07-01',:rc );
print rc;

--
--for sql developer
set serveroutput on
DECLARE
    orderColumn VARCHAR2(50):='I.DAGS_SKRAD';
    IvOrderColumn VARCHAR2(50):='CurrencyCd';       
    IvOrderAscending VARCHAR2(50):='ACS';   
    rc sys_refcursor;
BEGIN 
 CASE IvOrderColumn
        WHEN 'SendDt'  THEN orderColumn:='DAGS_SKRAD';
        WHEN 'CostAmt' THEN orderColumn:='KOSTNADUR';
        WHEN 'CurrencyCd' THEN orderColumn:='MYNT';
        WHEN 'ForeignAmt' THEN orderColumn:='ERLEND_FJARHAED';
        WHEN 'RecipientName' THEN orderColumn:='NAFN_VIDTAKANDA';
        WHEN 'StatusCd' THEN orderColumn:='STADA';
        ELSE orderColumn:='I.DAGS_SKRAD'; --SendDt
    END CASE;
    --orderColumn:= orderColumn || ' ' || IvOrderAscending;
   --DBMS_OUTPUT.put_line(
   open rc for
   'SELECT EG.BUNKANUMER , EG.LINUNUMER , EG.KENNITALA_GREIDANDA , EG.NAFN_GREIDANDA,
         EG.HEIMILI_GREIDANDA_1 , EG.HEIMILI_GREIDANDA_2 , EG.HEIMILI_GREIDANDA_3 ,
         EG.MYNT,
         EG.ERLEND_FJARHAED  
          FROM
         SKJALINA.ERLEND_GREIDSLA EG
         WHERE  EG.kennitala_greidanda = ''5811110450''
         Order By ' ||orderColumn;
    dbms_sql.return_result(rc);
END;


--

--Example 12-18 Controlling Number of BULK COLLECT Rows with LIMIT
--https://isu.ifmo.ru/docs/doc112/appdev.112/e10472/tuning.htm

DECLARE
  TYPE numtab IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  CURSOR c1 IS
    SELECT employee_id
    FROM employees
    WHERE department_id = 80;

  empids  numtab;
  rows    PLS_INTEGER := 10;
BEGIN
  OPEN c1;
  LOOP  -- Fetch 10 rows or fewer in each iteration
    FETCH c1 BULK COLLECT INTO empids LIMIT rows;
    EXIT WHEN empids.COUNT = 0;  -- Not: EXIT WHEN c1%NOTFOUND
    DBMS_OUTPUT.PUT_LINE ('------- Results from Each Bulk Fetch --------');
    FOR i IN 1..empids.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE ('Employee Id: ' || empids(i));
    END LOOP;
  END LOOP;
  CLOSE c1;
END;
/

---------------
SET SERVEROUTPUT ON
DECLARE
    -- constants
    c_enter   constant varchar2(2) := chr(13)||chr(10);
    c_quote   constant varchar2(2) := chr(39);

    TYPE flag_tt IS TABLE OF VARCHAR2(1 CHAR);
    l_flag flag_tt;
    l_date varchar2(30) := to_char(bifrost.dagar.bankadagur_nidur(SYSDATE - 1),'dd.mm.yyyy');
    l_stmt varchar2(250);
    CURSOR mview_cur (filter_in IN VARCHAR2) 
        IS 
        SELECT mview_name
          FROM all_mviews am
         WHERE am.owner = filter_in;   
   
BEGIN  
   FOR rec IN mview_cur ('DEPOSITS') 
   LOOP  
   l_stmt := 'SELECT /*+ FIRST_ROWS(1) */ ''T'' n
                        FROM  '|| rec.mview_name||
                     ' WHERE  1=1
                         AND  to_char(reference_date, ''dd.mm.yyyy'') = '||c_quote||l_date||c_quote||
                     '   AND  ROWNUM < 2';
   
   EXECUTE IMMEDIATE l_stmt BULK COLLECT INTO l_flag;  
   --DBMS_OUTPUT.put_line (l_stmt);
   DBMS_OUTPUT.put_line (rec.mview_name||' - '||l_flag.COUNT);
   END LOOP;  
END;
/

-- using index base on date 
SET SERVEROUTPUT ON
DECLARE
    -- constants
    c_enter   constant varchar2(2) := chr(13)||chr(10);
    c_quote   constant varchar2(2) := chr(39);

    TYPE flag_tt IS TABLE OF VARCHAR2(1 CHAR);
    l_flag flag_tt;
    l_date date := bifrost.dagar.bankadagur_nidur(SYSDATE - 1);
    l_stmt varchar2(250);
    CURSOR mview_cur (filter_in IN VARCHAR2) 
        IS 
        SELECT mview_name
          FROM all_mviews am
         WHERE am.owner = filter_in;   
   
BEGIN  
   FOR rec IN mview_cur ('DEPOSITS') 
   LOOP  
   l_stmt := 'SELECT /*+ FIRST_ROWS(1) */ ''T'' n
                        FROM  '|| rec.mview_name||
                     ' WHERE  1=1
                         AND  reference_date = :l_date
                         AND  ROWNUM < 2';
   
   EXECUTE IMMEDIATE l_stmt BULK COLLECT INTO l_flag USING l_date;  
   --DBMS_OUTPUT.put_line (l_stmt);
   DBMS_OUTPUT.put_line (rec.mview_name||' - '||l_flag.COUNT);
   END LOOP;  
END;
/

----------------
set serveroutput on
declare
procedure alter_mview_copmile(ip_owner varchar2, ip_test_only boolean default true)
is
l_stmp varchar2(500);
begin
for cur in (select mview_name from all_mviews where owner = ip_owner)
loop
l_stmp :='alter materialized view '||cur.mview_name||' compile';
    begin
    if ip_test_only
    then
        dbms_output.put_line(l_stmp);
    else 
        execute immediate l_stmp;
    end if;
    exception 
        when others 
            then raise;
    end;
end loop;
end alter_mview_copmile;

begin
alter_mview_copmile('DEPOSITS');
end;
/
