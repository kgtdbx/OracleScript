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

 ------------------How to test------------------ 
Assume we have global cursor in package bodi as

--create or replace PACKAGE FACILITIES_LOANS is

  cursor cFacilitiesBaseLoans(inTheDate in date, inDate in date, inFonixDate in date,
                              inCollateralDate in date, inMortgageDimTime in number,inId in varchar2) is
            select
            inTheDate the_date,
            inFonixDate fonix_date,
            inCollateralDate collateral_date,
            dc.cust_ssn,
            nvl(bal.loan_balance,0) dw_loan_balance ,
            nvl(bal.loan_balance_isk,0) dw_loan_balance_isk,
            nvl(bal.indexation,0) indexation,
            nvl(bal.in_arrears,0) in_arrears,
            nvl(bal.accrued_interest,0) accrued_interest,
            nvl(bal.penalty_interest,0) penalty_interest,
            nvl(bal.payment_adjustment_amount,0) payment_adjustment_amount,
            nvl(bal.interest_in_arrears,0) interest_in_arrears,
            ...
            from valholl.fct_loan_balance bal
            left join valholl.dim_time dt on dt.dimension_key=bal.dim_time
            left join valholl.dim_loan dl on dl.dimension_key=bal.dim_loan
            left join valholl.dim_loan_type dlt on dlt.dimension_key=bal.dim_loan_type
            left join valholl.dim_product p on p.dimension_key = bal.dim_product
            left join valholl.dim_gl_account gl on gl.dimension_key=bal.dim_gl_account
            left join valholl.dim_currency cur on cur.dimension_key=case when dl.currency='RFÍ' then 92807 else bal.dim_currency end   -- fiff á meðan ekki er búið að laga í gegnum dim lyklunina alla leið í DW
            left join valholl.dim_currency_rate curr on curr.dim_currency=cur.dimension_key and curr.dim_time=bal.dim_time
            left join valholl.dim_customer dc on dc.dimension_key=bal.dim_customer
      ...
      where
      ( bal.asset_liability = 'a'  or overdraft_limit > 0
         or dl.id in ( select n.branch||'-'||n.ledger||'-'||n.account from utgardur.md_nostro_ln_corr n
                      where the_date=inDate)
      )
      and bal.active='Y';
 
-----------run-----------------
 
/*
sete serveroutput on
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

