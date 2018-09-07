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
variable    ONERRORNUMBER NUMBER;
variable    OVERRORMESSAGE VARCHAR2(200);

exec SKJALINA.FOREIGNPAYMENTS.PGETFOREIGNPAYMENTSSEARCH(date'2002-07-01',date'2012-08-01',null,null,null,null,'4406861259',null,NULL,NULL,1,100,:ONERRORNUMBER,:OVERRORMESSAGE,:rc );
print rc;

--