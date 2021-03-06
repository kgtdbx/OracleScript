--alter pluggable database all open;

--alter session set container=orclpdb1;

--Show con_name;

ALTER USER hr1 identified by hr10753;

--Sources:
--https://www.exam4training.com/oracle-1z0-148-oracle-database-12c-advanced-pl-sql-online-training/


--1 .Which option could expose your code to SQL injection attacks?
/*
You are designing and developing a complex database application built using many dynamic SQL statements. Which option could expose your code to SQL injection attacks?
A. Using bind variables instead of directly concatenating parameters into dynamic SQL statements
B. Using automated tools to generate code
***C. Not validating parameters which are concatenated into dynamic SQL statements
D. Validating parameters before concatenating them into dynamic SQL statements
E. Having excess database privileges
*/

--###############################--

--2. Examine this code executed as SYS:
create user spider IDENTIFIED BY spider DEFAULT TABLESPACE users quota UNLIMITED on users;
create role dynamic_table_role;
grant create table to dynamic_table_role;
grant create  session, create PROCEDURE to spider;
grant dynamic_table_role to spider with admin option;
alter user spider DEFAULT role all except dynamic_table_role;

/*
show con_name
alter pluggable database all open;
alter session set container=orclpdb1;
*/
/*
What is the reason for this error?
A. The procedure needs to be granted the DYNAMIC_TABLE_ROLE role.
B. The EXECUTE IMMEDIATE clause is not supported with roles.
*** C. Privileges granted through roles are never in effect when running definer's rights procedures.
D. The user SPIDER needs to be granted the CREATE TABLE privilege and the procedure needs to be granted the DYNAMIC_TABLE_ROLE.
*/

sqlplus spider/spider@orclpdb1

--spider
CREATE or replace PROCEDURE dproc 
/*authid current_user*/ --add to avoid error
AS
BEGIN
EXECUTE IMMEDIATE 'create table demo(id integer)';
END;
/
set role dynamic_table_role;

exec dproc;

--###############################--
Examine the following SQL statement:
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3;
/*
What is the result of executing this statements?
A . The PL/SQL optimize level for some existing PL/SQL units will be changed as an immediate result.
B . The PL/SQL optimize level for subsequently complied PL/SQL units will be set to 3 and inlining will be enabled.
***C . The PL/SQL optimize level for subsequently compiled PL/SQL units will be set to 3 and inlining will be disabled.
D . This statement will fail because PLSQL_OPTIMIZE_LEVEL can only be set at the system level,
*/
--###############################--
Examine this block:

set serveroutput on
declare
type va$ is varray(200) of number;
va va$ :=va$();
begin
va.extend(100);
DBMS_OUTPUT.PUT_LINE(va.last||'  '|| va.limit||'  '|| va.count||'  '|| va.next(199));
end;
/

Which two will be correct after line 5?
A. va.LAST and va.LIMIT will return the same value.
***B. va.LAST and va.COUNT will return the same value.
C. va.LIMIT and va.COUNT will return the same value.
D. va.LIMIT and va.NEXT (199) will return the same value.
E. va.LAST will return 200.
***F. va.NEXT (199) will return NUL
--###############################--
The STUDENTS table exists in your schema.

Examine the DECLARE section of a PL/SQL block:

declare
type studentcur_t is ref cursor return students%rowtype;
type teachercur_t is ref cursor;

cursor1 studentcur_t;
cursor2 teachercur_t;
cursor3 sys_refcursor;
BEGIN
OPEN cursor3 FOR SELECT * FROM students;
cursor1 :=cursor3;
END;
/

Which two blocks are valid?
***A . BEGINOPEN cursor3 FOR SELECT * FROM students;cursor1 :=cursor3;END;
B . BEGINOPEN stcur;cursor1 :=stcur;END;
C . BEGINOPEN cursor1 FOR SELECT * FROM students;stcur :=cursor1;END;
D . BEGINOPEN stcur;cursor3 :=stcur;END;
***E . BEGINOPEN cursor1 FOR SELECT * FROM students;cursor2 :=cursor1;END;

declare
type studentcur_t is ref cursor return EMPLOYEES%ROWTYPE;
type teachercur_t is ref cursor;

cursor1 studentcur_t;
cursor2 teachercur_t;
cursor3 sys_refcursor;

--BEGIN OPEN cursor3 FOR SELECT * FROM EMPLOYEES; cursor1 :=cursor3; END;
--BEGIN OPEN stcur; cursor1 :=stcur; END;
--BEGIN OPEN cursor1 FOR SELECT * FROM EMPLOYEES; stcur :=cursor1; END;
--BEGIN OPEN stcur; cursor3 :=stcur; END;
--BEGIN OPEN cursor1 FOR SELECT * FROM EMPLOYEES; cursor2 :=cursor1; END;
/
--###############################--
Which codes executes successfully?
A . CREATE PACKAGE pkg ASTYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);PROCEDURE calc_price (price_rec IN OUT rec_typ);END pkg;/CREATE PACAKGE BODY pkg ASPROCEDURE calc_price (price_rec IN OUT rec_typ) ASBEGINprice_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;END calc_price;END pkg;/DECLARE1_rec pkg. rec_typ;BEGIN1_rec_price :=100;1_rec.inc_pct :=50;EXECUTE IMMEDIATE ?BEGIN pkg. calc_price (:rec); END;? USING IN OUT 1_rec;END;
B . CREATE PACKAGE pkg ASTYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);END pkg;/CREATE PROCEDURE calc_price (price_rec IN OUT pkg. rec_typ) ASBEGINprice_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;END/DECLARE1_rec pkg.rec_typ;BEGINEXECUTE IMMEDIATE ?BEGIN calc_price (:rec); END;? USING IN OUT 1_rec (100, 50);END;
C . CREATE PACKAGE pkg ASTYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);END pkg;/CREATE PROCEDURE calc_price (price_rec IN OUT pkg. rec_typ) ASBEGINprice_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;END ;/DECLARE1_rec pkg. rec_typ;BEGIN1_rec_price :=100;1_rec.inc_pct :=50;EXECUTE IMMEDIATE ?BEGIN calc_price (1_rec); END;?;END;
D . DECLARETYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);1_rec rec-typ;PROCEDURE calc_price (price_rec IN OUT rec_typ) ASBEGINprice_rec.price := price-rec.price+ (price_rec.price * price_rec.inc_pct)/100;END;BEGIN1_rec_price :=100;1_rec.inc_pct :=50;EXECUTE IMMEDIATE ?BEGIN calc_price (:rec); END;? USING IN OUT 1_rec;END;

--A
CREATE PACKAGE pkg 
AS 
TYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);
PROCEDURE calc_price (price_rec IN OUT rec_typ);
END pkg;
/

CREATE PACKAGE BODY pkg 
AS
PROCEDURE calc_price (price_rec IN OUT rec_typ) 
AS
BEGIN
price_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;
END calc_price;
END pkg;
/

DECLARE
l_rec pkg.rec_typ;
BEGIN
l_rec_price :=100;
l_rec.inc_pct :=50;
EXECUTE IMMEDIATE 'BEGIN pkg. calc_price (:rec); END;' using in out l_rec;
end;

--B
CREATE or replace PACKAGE pkg 
AS
TYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);
END pkg;
/
CREATE or replace PROCEDURE calc_price (price_rec IN OUT pkg.rec_typ) 
AS
BEGIN
price_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;
END;
/

DECLARE
l_rec pkg.rec_typ;
BEGIN 
EXECUTE IMMEDIATE 'BEGIN pkg.calc_price(:rec); END; ' using in out l_rec(100,50);
end;
/

--C
CREATE or replace PACKAGE pkg 
AS
TYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);
END pkg;
/
CREATE or replace PROCEDURE calc_price (price_rec IN OUT pkg. rec_typ) 
AS
BEGIN
price_rec.price := price_rec.price + (price_rec.price * price_rec.inc_pct)/100;
END;
/
DECLARE
l_rec pkg. rec_typ;
BEGIN
l_rec_price :=100;
l_rec.inc_pct :=50;
EXECUTE IMMEDIATE 'BEGIN calc_price (l_rec); end;';
END;

--D
DECLARE
TYPE rec_typ IS RECORD (price NUMBER, inc_pct NUMBER);
l_rec rec_typ;

PROCEDURE calc_price (price_rec IN OUT rec_typ) 
AS
BEGIN
price_rec.price := price_rec.price+ (price_rec.price * price_rec.inc_pct)/100;
END;

BEGIN
l_rec_price :=100;
l_rec.inc_pct :=50;
EXECUTE IMMEDIATE 'BEGIN calc_price (:rec); END;' USING IN OUT l_rec;
END;
/

--###############################--
PLSQL_OPTIMIZE_LEVEL PARAMETER is set to 3.

Which two statements are true?

A . Calls to TESTPROC will always be inlined as it is compiled with PLSQL_OPTIMIZE_LEVEL=3.
***B . Calls to TESTPROC are never inlined in both lines commented as Call1 and Call 2.
***C . Calls to TESTPROC are not inlined in the line commented as Call 1.
D . Calls to TESTPROC are inlined in both lines commented as Call 1 and Call 2.
E . Calls to TESTPROC might be inlined in the line commented as Call 2.

/*
The INLINE pragma only affects the following types of statements.

Assignment
Call
Conditional
CASE
CONTINUE-WHEN
EXECUTE IMMEDIATE
EXIT-WHEN
LOOP
RETURN

In each case, it affects every call to specified subprogram from the statement.
The optimizer can choose to ignore an INLINE pragma setting of "YES" if it believes inlining is undesirable, but a setting of "NO" will always prevent inlining.
The compiler inlines subprograms early in the optimization process, which may preventing later, more powerful optimizations taking place. 
As a result, performance almost always improves with inlining, but in some cases it may not be effective.
*/
--###############################--
Which two statements describe actions developers can take to make their application less vulnerable to security attacks?
A . Include the AUTHID DEFINER clause in stored program units.
***B . Do not concatenate unchecked user input into dynamically constructed SQL statements.
C . Switch from using DBMS_SQL to EXECUTE IMMEDIAT
***D . Include the AUTHID CURRENT_USER clause in stored program units.
E . Increase the amount of code that is accessible to users by default.
--###############################--
Which statement is correct about DBMS_LOB.SETOPTIONS and DBMS_LOB.GETOPTIONS for SecureFiles?
A . DBMS_LOB.GETOPTIONS can only be used for BLOB data types.
***B . DBMS_LOB.SETOPTIONS can perform operations on individual SecureFiles but not an entire column.
***C . DBMS_LOB.SETOPTIONS can set option types COMPRESS, DUPLICATE, and ENCRYP
???D . If a table was not created with compression specified in the store as securefile clause then DBMS_LOB.SETOPTIONS can be used to enable it later.

--The method DBMS_LOB.SETOPTIONS() can be used to enable and disable compression on individual SecureFiles LOBs. See "SETOPTIONS()"
--https://docs.oracle.com/cd/E11882_01/appdev.112/e18294/adlob_smart.htm#ADLOB46109
/*
GETOPTIONS()
This function obtains the compression, deduplication and encryption settings of individual SecureFiles LOBs. An integer corresponding to a pre-defined constant based on the option type is returned.

Note that you cannot turn compression or deduplication on or off for an entire SecureFiles LOB column that has these features disabled.

See the Oracle Database PL/SQL Packages and Types Reference for more details on this function. See the Oracle Call Interface Programmer's Guide for more information on the corresponding OCI LOB function OCILobGetContentType().

SETOPTIONS()
This procedure sets compression, deduplication and encryption features. It enables the features to be set on a per-LOB basis, overriding the default LOB settings. 
This call incurs a round trip to the server to make the changes persistent.

You cannot turn compression or deduplication on or off for a SecureFiles LOB column that does not have those features enabled. 
GETOPTIONS() and SETOPTIONS() work on individual SecureFiles LOBs. 
You can turn off a feature on a particular SecureFiles LOB and turn on a feature that has been turned off by SETOPTIONS(), 
but you cannot turn on an option that has not been given to the SecureFiles LOB when the table was created.
*/
--###############################--
CREATE or replace PACKAGE pkg 
IS
TYPE rec_typ IS RECORD (pdt_id integer, pdt_name varchar2(25));
TYPE tab_typ IS TABLE OF rec_typ INDEX BY PLS_INTEGER;
x tab_typ;
END pkg;
/

CREATE or replace FUNCTION f (x pkg.tab_typ) return varchar2 
IS
r varchar2(100);
BEGIN
for i in 1..x.count loop
r:=r||' '||x(i).pdt_id||x(i).pdt_name;
end loop;
return r;
END f;
/


Which two subprograms will be created successfully?
***A . CREATE FUNCTION p4 (y pkg.tab_typ) RETURN pkg.tab_typ ISBEGINEXECUTE IMMEDIATE ?SELECT pdt_id, pdt_name FROM TABLE (:b)?BULT COLLECT INTO pkg.x USING y;RETURN pkg.x;END p4;
B . CREATE PROCEDURE p1 (y IN OUT pkg.tab_typ) ISBEGINEXECUTE IMMEDIATE ?SELECT f (:b) FROM DUAL? INTO y USING pkg.x;END p1;
***C . CREATE PROCEDURE p2 (v IN OUT VARCHAR2) ISBEGINEXECUTE IMMEDIATE ?SELECT f (:b) FROM DUAL? INTO v USING pkg.x;END p2;
D . CREATE FUNCTION p3 RETURN pkg. tab_typ ISBEGINEXECUTE IMMEDIATE ?SELECT f (:b) FROM DUAL? INTO pkg.x;END p3;
E . CREATE PROCEDURE p5 (y pkg. rec_typ) ISBEGINEXECUTE IMMEDIATE ?SELECT pdt_name FROM TABLE (:b)? BULK COLLECT INTO y USING pkg.x;END p5;

--A
CREATE FUNCTION p4 (y pkg.tab_typ) 
RETURN pkg.tab_typ IS
BEGIN
EXECUTE IMMEDIATE 'SELECT pdt_id, pdt_name FROM TABLE (:b)' BULK COLLECT INTO pkg.x USING y;
RETURN pkg.x;
END p4;
/

--B
CREATE PROCEDURE p1 (y IN OUT pkg.tab_typ) 
IS
BEGIN
EXECUTE IMMEDIATE 'SELECT f (:b) FROM DUAL' INTO y USING pkg.x;
END p1;
/
--Error(19,50): PLS-00597: expression 'Y' in the INTO list is of wrong type

--C
CREATE PROCEDURE p2 (v IN OUT VARCHAR2) IS
BEGIN
EXECUTE IMMEDIATE 'SELECT f (:b) FROM DUAL' INTO v USING pkg.x;
END p2;
/

--D

CREATE FUNCTION p3 RETURN pkg.tab_typ IS
BEGIN
EXECUTE IMMEDIATE 'SELECT f (:b) FROM DUAL' INTO pkg.x;
END p3;
/
--Error(18,54): PLS-00597: expression 'PKG.X' in the INTO list is of wrong type

--E

CREATE PROCEDURE p5 (y pkg. rec_typ) IS
BEGIN
EXECUTE IMMEDIATE 'SELECT pdt_name FROM TABLE (:b)' BULK COLLECT INTO y USING pkg.x;
END p5;
/
--Error(18,71): PLS-00403: expression 'Y' cannot be used as an INTO-target of a SELECT/FETCH statement


--###############################--
create table test_tbl(id number, object blob);

delete test_tbl;
insert into test_tbl values(1,to_blob('01'));
insert into test_tbl values(2,to_blob('11'));
commit;

create trigger trig_at after update on test_tbl
begin
dbms_output.put_line('It was updated');
end;

set SERVEROUTPUT ON
declare
denst_lob blob;
src_lob blob;
begin
select object into denst_lob from test_tbl where id = 2 for update;
select object into src_lob from test_tbl where id = 1;
dbms_lob.append(denst_lob,src_lob);
end;
/

What is the outcome of this anonymous PL/SQL block?
A. "It was updated" is displayed.
***B. Successful completion without printing "It was updated".
C. A NO_DATA_FOUND exception is thrown.
D. ORA-06502: PL/SQL: numeric or value error: invalid LOB locator specified
E. ORA-22920: row containing the LOB value is not locked

--###############################--
Which two statements are correct in Oracle Database 12c?
A. For native compilation, PLSQL_OPTIMIZE_LEVEL should be set to 2.
B. Native compilation is the default compilation method
C. Native compilation should be used during development.
***D. Natively compiles code is stored in the SYSTEM tablespace.
***E. To change a PL/SQL object from interpreted to native code, set the PLSQL_CODE_TYPE to NATIVE and recompile it.
--
SELECT name, value
FROM v$parameter
WHERE name ='plsql_optimize_level' ;
--
SELECT name, value
FROM v$parameter
WHERE name ='plsql_code_type' ;
--
drop procedure p1;
create or replace procedure p1 
is
begin
dbms_output.put_line('P1');
end;

select * from user_plsql_object_settings
where name ='P1';

ALTER SESSION SET plsql_code_type=native; --you can do alter system, but this for DBA

--still the P1  =INTERPRETED
select * from user_plsql_object_settings
where name ='P1'

--so we should compile again 

create or replace procedure p1 
is
begin
dbms_output.put_line('P1');
end;

--or 
alter procedure p1 compile  plsql_code_type=native;

select * from user_plsql_object_settings
where name ='P1'


--###############################--
declare
type varchar_type1 is varray(3) of varchar2(15);
type varchar_type2 is varray(3) of varchar2(15);
type varchar_type3 is varray(3) of varchar2(15);
type nested_type is table of varchar_type3;
--n_table1 nested_type:= varchar_type3('AB1','AB2','AB3');
list_A varchar_type1:=varchar_type1('Seattle', 'Tokyo', 'Paris');
list_B varchar_type1;
list_C varchar_type2;
begin
list_B:=list_A;
--list_C := list_A;
end;
/

What will be the outcome?
A. It will fail compile because of errors at lines 11 and 12.
***B. It will fail compile because of errors at lines 6 and 12.
C. It will fail compile because of error at line 7.
D. It will fail compile and execute successfully.
E. It will fail compile because of errors at lines 5 and 6.

--###############################--
create table dept (dept_id number(3) not null, emp_id number(3) not null);
delete dept;
insert into dept values(1,1);
commit;

connect hr/hr0753

create or replace function emp_count(p_dept_id number) return number
--AUTHID CURRENT_USER
is
l_ctr number;
begin
select count(*) into l_ctr from dept where dept_id=p_dept_id;
return l_ctr;
end emp_count;
/
sho err

grant execute on hr.emp_count to hr1;

create or replace view emp_counts_vw
--BEQUEATH CURRENT_USER
as
select dept_id,emp_count(dept_id) no_of_emps
from dept
group by dept_id;

grant select on emp_counts_vw to hr1;

connect hr1/hr10753
--
set SERVEROUTPUT ON
declare
type dept_list_type is table of dept.dept_id%type;
l_dept dept_list_type;
e_count number;

begin
--if l_dept.count is null then
--if l_dept IS EMPTY then
if CARDINALITY (l_dept) IS NULL then
select no_of_emps into e_count
from hr.emp_counts_vw where dept_id =1;
DBMS_OUTPUT.PUT_LINE('Dept ID:1' ||' No of Emps: '||e_count);
end if;
end;
/

Which three modifications must be done to endure the anonymous block displays the output form the BRANCH2.DEF DEPT table?
A. Change the IF condition in the anonymous block to 1_dept IS EMPTY.
***B. Change the IF condition in the anonymous block to CARDINALITY (1_dept) IS NULL.
C. Add BEQUEATH DEFINER to the EMP_COUNT_VW view.
***D. Add BEQUEATH CURRENT_USER to the EMP_COUNTS_VW view.
E. IN BRANCH2 execute GRANT INHERIT PRIVILEGES ON USER branch2 TO branch1;
***F. Add AUTHID CURRENT_USER to the EMP_COUNT function.

--###############################--
Consider a function totalEmp () which takes a number as an input parameter and returns the total number of employees who have a salary higher than that parameter.
Examine this PL/SQL package AS

Which two definitions of totalEmp () result in an implicit conversion by Oracle Database on executing this PL/SQL block?
A. CREATE FUNCTION totalEmp (sal IN NUMBER) RETURN NUMBER IS total NUMBER :=0;
BEGIN

RETUNRN total;
END;
/
B. CREATE FUNCTION totalEmp (sal IN NUMBER) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETUNRN total;
END;
/
C. CREATE FUNCTION totalEmp (sal IN PLS_INTEGER) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETUNRN total;
END;
/
D. CREATE FUNCTION totalEmp (sal IN BINARY_FLOAT) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETUNRN total;
END;
/
E. CREATE FUNCTION totalEmp (sal IN POSITIVEN) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETUNRN total;
END; 
/

-----
create or replace package pkg is
fiveth pls_integer := 5000;
end pkg;
/
--a
CREATE or replace FUNCTION totalEmp (sal IN NUMBER) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETURN total;
END;
/
--b
--same as a
--c
declare
a pls_integer := pkg.fiveth;
c number;
begin
c:= totalemp (a);
end;
/
--d
CREATE or replace FUNCTION totalEmp (sal IN BINARY_FLOAT) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETURN total;
END;
/
-- e
CREATE or replace FUNCTION totalEmp (sal IN POSITIVEN) RETURN NUMBER IS total NUMBER :=0;
BEGIN
RETURN total;
END;
/

--###############################--
Which two statements are true about PL/SQL AOIs for SecureFiles?
A. DBMS_LOB can be used to compress SecureFiles columns.
***B. When using DBMS_DATAPUMP, if SecureFiles LOB data needs to be encrypted then ENCRYPTION=ALL must be specified.
C. If a BasicFiles LOB locator is passed to DBMS_LOB.ISSECUREFILE, an exception will be raised.
***D. An online redefinition of SecureFiles by DBMS_REDEFINIITON can be performed with PDML (Parallel DML).
--###############################--
Which two can be used to find details of parameters for overloaded PL/SQL routines?
A. ALL-DEPENDENCIES
***B. ALL_PROCEDURES
C. ALL_DESCRIBE
D. ALL_SOURCE
***E. ALL_ARGUMENTS

select * from ALL_DEPENDENCIES;
select * from ALL_PROCEDURES;
select * from ALL_DESCRIBE;
select * from ALL_SOURCE;
select * from ALL_ARGUMENTS;

select * 
from ALL_PROCEDURES ap
join ALL_ARGUMENTS aa
on(ap.object_id = aa.object_id)
and ap.overload is not null
and aa.overload is not null
;

--###############################--
/*
Which two blocks will execute successfully?
A. BEGIN My_proc; END;
***B. BEGIN pkg2.proc3; END;
***C. BEGIN pkg2.proc2;END;
D. BEGIN pkg1.proc1a; END;
E. BEGIN pkg1.proc1b; END;
*/
------

create or replace noneditionable package pkg1 accessible by (pkg2) is
procedure proc1a;
end pkg1;
/

create or replace noneditionable package body pkg1 is
procedure proc1a is
begin
dbms_output.put_line('proc1a');
end proc1a;

procedure proc1b is
begin
proc1a;
end proc1b;
end pkg1;
/

create or replace noneditionable package pkg2 is
procedure proc2;
procedure proc3;
end pkg2;
/

create or replace noneditionable package body pkg2 is
procedure proc2 is
begin
pkg1.proc1a;
end proc2;
procedure proc3 is
begin
pkg2.proc2;
end proc3;
end pkg2;
/

--
BEGIN My_proc; END;
/

BEGIN pkg2.proc3; END;
/

BEGIN pkg2.proc2; END;
/

BEGIN pkg1.proc1a; END;
/

BEGIN pkg1.proc1b; END;
/

--###############################--
Examine this procedure created in a session where PLSQL_OPTIMIZE_LEVEL =2:

PL/SQL tracing in enabled in a user session using this command:
EXEC DBMS_TRACE.SET_PLSQL_TRACE (DBMS_TRACE.TRACE_ENABLED_LINES)
The procedure is executed using this command:
EXEC PRC_1

Examine the exhibit for the content of the PLSQL_TRACE_EVENTS table.
Why is tracing excluded from the PLSQL_TRACE_EVENTS table?
A. DBMS_TRACE.TRACE_ENABLED_LINES traces only exceptions in subprograms.
***B. PRC_1 is not compiled with debugging information.
C. Tracing is not enabled with the TRACE_ENABLED_CALLS option.
D. PRC_1 is compiled with the default AUTHID DEFINER clause.
E. Tracing will be enabled only for the second execution of PRC_1.

--
--https://dbaora.com/tracing-plsql-using-dbms_trace-oracle-database-11g-release-2-11-2/
--http://torofimofu.blogspot.com/2015/08/plsql-oracle-11g-i.html

--exec from sys
--@C:\app\product\12.2.0\dbhome_1\rdbms\admin\tracetab.sql
grant select on PLSQL_TRACE_EVENTS to public;
grant select on PLSQL_TRACE_RUNS to public;
grant execute on DBMS_TRACE to hr1;
----
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=2;

--drop procedure prc_1;
--alter procedure prc_1 compile debug;

create or replace procedure prc_1 is
begin
dbms_output.put_line('PRC_1');
end;
/

EXEC DBMS_TRACE.SET_PLSQL_TRACE (DBMS_TRACE.TRACE_ENABLED_LINES);

exec prc_1;

/*Stop tracing*/
--exec  dbms_trace.clear_plsql_trace; 

--truncate table sys.plsql_trace_events;

select event_seq, event_unit, event_unit_kind, event_comment
from sys.plsql_trace_events
--where runid=17;

begin
  dbms_trace.set_plsql_trace(dbms_trace.TRACE_ENABLED_CALLS);
  prc_1;
  dbms_trace.clear_plsql_trace;
end;
/

--###############################--

--###############################--
--HomeOracle1z0-148Which PL/SQL block will raise an exception?
--You are logged on to the SCOTT schema and the schema has EMP and DEPT tables already created: Examine this PL/SQL procedure:

--drop procedure get_tab_row_vount;

CREATE or replace PROCEDURE get_tab_row_count(p_table_name in varchar2)
as
l_sql varchar2(200);
l_count number;
begin
l_sql := 'select count(*) from '||dbms_assert.sql_object_name(p_table_name);
execute immediate  l_sql into l_count;
DBMS_OUTPUT.PUT_LINE('l_count = '||l_count);
end;
/

A. EXEC get_tab_row_count (�emp�);
B. EXEC get_tab_row_count (�SCOTT.EMP�);
C. EXEC get_tab_row_count (� "EMP" �);
D. EXEC get_tab_row_count (�DEPT�);
***E. EXEC get_tab_row_count (�DEPT, EMP�)


EXEC get_tab_row_count ('jobs');
EXEC get_tab_row_count ('HR.JOBS');
EXEC get_tab_row_count ('"JOBS"');
EXEC get_tab_row_count ('REGIONS');
EXEC get_tab_row_count ('REGIONS, JOBS');

--###############################--
This result cache is enabled for the database instance.
Examine this code for a PL/SQL function:

create or replace function get_hire_date(emp_id number) return varchar2
result_cache
is
date_hired date;
begin
select hire_date into date_hired
from hr.employees
where employee_id = emp_id;
return to_char(date_hired);
end;
/

Which two actions would ensure that the same result will be consistently returned for any session when the same input value is passed to the function?
***A. Add a parameter, fmt, and change the RETURN statement to: RETURN TO_CHAR (date_hired, fmt);
B. Set the RESULT_CACHE_MODE parameter to FORCE.
C. Increase the value for the RESULT_CACHE_MAX_SIZE parameter.
***D. Change the return type of GET_HIRE_DATE to DATE and have each session invoke the TO_CHAR function.
E. Set the RESULT_CACHE_MAX_RESULT parameter to 0.

https://docs.oracle.com/cd/E18283_01/appdev.112/e17126/subprograms.htm

select get_hire_date(101) from dual;

CREATE OR REPLACE FUNCTION get_hire_date
  (emp_id NUMBER, fmt VARCHAR) RETURN VARCHAR
  RESULT_CACHE
IS
  date_hired DATE;
BEGIN
  SELECT hire_date INTO date_hired
    FROM HR.EMPLOYEES
      WHERE EMPLOYEE_ID = emp_id;
  RETURN TO_CHAR(date_hired, fmt);
END;
/

select get_hire_date(101, 'dd/mm/yyyy') from dual;

CREATE OR REPLACE FUNCTION get_hire_date
  (emp_id NUMBER) RETURN date
  RESULT_CACHE
IS
  date_hired DATE;
BEGIN
  SELECT hire_date INTO date_hired
    FROM HR.EMPLOYEES
      WHERE EMPLOYEE_ID = emp_id;
  RETURN TO_CHAR(date_hired);
END;
/

select get_hire_date(101) from dual;

--###############################--

Examine the incomplete code:

create type numlist is table of number;
/

create or replace procedure list_sal (dept_id number) 
is
sql_stmt varchar2(200);
ret integer;
empids numlist;
sal numlist;
curid NUMBER; --D
src_cur SYS_REFCURSOR; -- F
begin
curid := dbms_sql.open_cursor;
sql_stmt := 'select employee_id, salary from employees where department_id = :id';
dbms_sql.parse(curid, sql_stmt, dbms_sql.native);
dbms_sql.bind_variable(curid, 'id', 'dept_id');
ret := dbms_sql.execute(curid);
src_cur := DBMS_SQL.TO_REFCURSOR(curid); --B
fetch src_cur bulk collect into empids, sal;
if empids.count > 0 then
for i in 1..empids.count loop
dbms_output.put_line(empids(i) || ' ' || sal(i));
end loop;
end if;
close src_cur;
end;
/

exec list_sal(50);

Which three lines of code must be added for it to successfully compile?
A. curid := DBMS_SQL.TO_CURSOR_NUMBER (src_cur);
***B. src_cur := DBMS_SQL.TO_REFCURSOR (curid);
C. src_cur= NUMBER;
***D. curid NUMBER;
E. curid SYS_FEFCURSOR;
***F. src_cur SYS_REFCURSOR;


--###############################--
Examine these statements:
create type tp_rec# as object(col1 number, col2 number);
/
create type tp_test# as table of tp_rec#;
/

declare
wk# tp_tes#t := tp_test#();
begin
for i in 1..100 loop
wk#(i).col1:=i;
wk#(i)col2:=i;
end loop;
end;
/

Which two corrections will allow this anonymous block to execute successfully?
A. Add wk# .NEXT; before the 7th line.
B. Add i PLS_INTEGER; before the 3rd line.
***C. Add wk#. EXTEND (1); before the 5th line.
D. Change line #2 to wk# tp_test# := tp_test# (tp_rec# ());
***E. Replace lines 5 and 6 with wk# (i) := tp_rec# (i, i);

declare
wk# tp_test#:= tp_test#();
begin
for i in 1..100 loop
wk#.EXTEND (i);
wk#(i) := tp_rec#(i, i);
end loop;
end;
/

--###############################--
Select a valid reason for using VARRAYS.
A. When the amount of data to be held in the collection is widely variable.
***B. As a column in a table when you want to retrieve the collection data for certain rows by ranges of values.
C. When you want to delete elements from the middle of the collection.
D. As a column in a table when you want to store no more than 10 elements in each row�s collection.


CREATE OR REPLACE TYPE num_varray_t AS VARRAY (20) OF NUMBER;
/
CREATE TABLE tab_use_va_col( ID NUMBER, NUMBERS num_varray_t);
/

--###############################--
Examine this query executed as SYS and its output:
Which two observations are true based on the output?
A. The client-side result cache and the server-side result cache are enabled.
B. All distinct query results are cached for the duration of a SYS user session.
C. Repetitive SQL queries and PL/SQL function results are cached and automatically used from the cache across all SYS user sessions.
D. The result cache exists but which SQL queries are cached depends on the value of the RESULT_CACHE_MODE parameter.
E. Repetitive SQL queries executed on permanent non-dictionary objects may have faster response times.

select DBMS_RESULT_CACHE.STATUS() from dual;
--
SHOW PARAMETER RESULT_CACHE_MODE
--


--https://oracle-base.com/articles/11g/query-result-cache-11gr1
--Set up the following schema objects to see how the SQL query cache works.

CREATE TABLE qrc_tab ( id  NUMBER);

INSERT INTO qrc_tab VALUES (1);
INSERT INTO qrc_tab VALUES (2);
INSERT INTO qrc_tab VALUES (3);
INSERT INTO qrc_tab VALUES (4);
INSERT INTO qrc_tab VALUES (5);

connect as sys
grant execute on SYS.DBMS_LOCK to hr;

CREATE OR REPLACE FUNCTION slow_function(p_id  IN  qrc_tab.id%TYPE)
  RETURN qrc_tab.id%TYPE DETERMINISTIC AS
BEGIN
  DBMS_LOCK.sleep(1);
  RETURN p_id;
END;
/

SET TIMING ON

--The function contains a one second sleep so we can easily detect if it has been executed by checking the elapsed time of the query.
--Test It
--Query the test table using the slow function and check out the elapsed time. Each run takes approximately five seconds, one second sleep for each row queried.

SELECT slow_function(id) FROM qrc_tab;

Elapsed: 00:00:05.15

--Adding the RESULT_CACHE hint to the query tells the server to attempt to retrieve the information from the result cache. If the information is not present, it will cache the results of the query provided there is enough room in the result cache. Since we have no cached results, we would expect the first run to take approximately five seconds, but subsequent runs to be much quicker.
SELECT /*+ result_cache */ slow_function(id) FROM qrc_tab;

Elapsed: 00:00:05.20

SELECT /*+ result_cache */ slow_function(id) FROM qrc_tab;

Elapsed: 00:00:00.15
SQL>
RESULT_CACHE_MODE
The default action of the result cache is controlled by the RESULT_CACHE_MODE parameter. When it is set to MANUAL, the RESULT_CACHE hint must be used for a query to access the result cache.
SHOW PARAMETER RESULT_CACHE_MODE

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
result_cache_mode                    string      MANUAL
SQL>
If we set the RESULT_CACHE_MODE parameter to FORCE, the result cache is used by default, but we can bypass it using the NO_RESULT_CACHE hint.
ALTER SESSION SET RESULT_CACHE_MODE=FORCE;

SELECT slow_function(id) FROM qrc_tab;

Elapsed: 00:00:00.14

SELECT /*+ no_result_cache */ slow_function(id) FROM qrc_tab;

Elapsed: 00:00:05.14
--
Scalar Subquery Caching
The query result cache does not work with scalar subquery caching.
SELECT (SELECT /*+ result_cache */ slow_function(id) FROM dual) AS result FROM qrc_tab;
Elapsed: 00:00:05.03
--
SELECT (SELECT /*+ result_cache */ slow_function(id) FROM dual) FROM qrc_tab;
Elapsed: 00:00:05.03


--###############################--
Execute the query:
SELECT remap_schema FROM dual;
Which is the correct output from the query?

create or replace function remap_scema return clob is
h number;
th number;
doc clob;
begin
h := dbms_metadata.open('TABLE');
dbms_metadata.set_filter(h, 'SCHEMA', user);
dbms_metadata.set_filter(h, 'NAME', 'EMPLOYEES');
th := dbms_metadata.add_transform(h, 'MODIFY');
dbms_metadata.set_remap_param(th, 'REMAP_SCHEMA', user, null);
dbms_metadata.set_remap_param(th, 'REMAP_TABLESPACE', 'USERS', 'SYSAUX');
th := dbms_metadata.add_transform(h, 'DDL');
dbms_metadata.set_transform_param(th, 'SEGMENT_ATTRIBUTES', false);
doc := dbms_metadata.fetch_clob(h);
dbms_metadata.CLOSE(h);
return doc;
end remap_scema;

select remap_scema() from dual; 


A. CREATE TABLE "EMP" ("EMPNO" NUMBER (4,0), "ENAME" VARCHAR2 (10), "JOB" VARCHAR2 (9), "MGR" NUMBER (4,0), "HIREDATE" DATE, "SAL"
NUMBER (7,2) , "COMM" NUMBER (7,2), "DEPTNO" NUMBER (2,0),
CONSTRAINT "PK_EMP" PRIMARY KEY ("EMPNO")
USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255
STORAGE (INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2417483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CHACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ENABLE,
CONSTRAINT "FK_DEPTNO" FOREIGN KEY ("DEPTNO")
REFERENCES "DEPT" ("DEPTNO") ENABLE
) SEGMENT CREATION IMMEDIATE
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE (INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS"

***B. CREATE TABLE "EMP" ("EMPNO" NUMBER (4, 0), "ENAME" VARCHAR2 (10), "JOB" VARCHAR2 (9), "MGR" NUMBER (4, 0), "HIREDATE" DATE, "SAL"
NUMBER (7, 2), "COMM" NUMBER (7, 2), "DEPTNO" NUMBER (2, 0), CONSTRAINT "PK_EMP" PRIMARY KEY ("EMPNO")
USING INDEX ENABLE,
CONSTRAINT "FK_DEPTNO" FOREIGN KEY ("DEPTNO")
REFERENCES "DEPT" ("DEPTNO") ENABLE)

C. CREATE TABLE "SCOTT". "EMP" ("EMPNO" NUMBER (4, 0), "ENAME" VARCHAR2 (10), "JOB" VARCHAR2 (9), "MGR" NUMBER (4, 0), "HIREDATE"
DATE, "SAL" NUMBER (7, 2), "COMM" NUMBER (7, 2), "DEPTNO" NUMBER (2, 0), CONSTRAINT "PK_EMP" PRIMARY KEY ("EMPNO")
USING INDEX ENABLE,
CONSTRAINT "FK_DEPTNO" FOREIGN KEY ("DEPTNO")
REFERENCES "DEPT" ("DEPTNO") ENABLE)

D. CREATE TABLE "EMP" ("EMPNO" NUMBER (4,0), "ENAME" VARCHAR2 (10), "JOB" VARCHAR2 (9), "MGR" NUMBER (4,0), "HIREDATE" DATE, "SAL"
NUMBER (7, 2) , "COMM" NUMBER (7, 2), "DEPTNO" NUMBER (2,0),
CONSTRAINT "PK_EMP" PRIMARY KEY ("EMPNO")
USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255
STORAGE (INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2417483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CHACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "SYSAUX" ENABLE,
CONSTRAINT "FK_DEPTNO" FOREIGN KEY ("DEPTNO")
REFERENCES "DEPT" ("DEPTNO") ENABLE
) SEGMENT CREATION IMMEDIATE
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
NOCOMPRESS LOGGING
STORAGE (INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "SYSAUX"

--###############################--
The anonymous block fails with:

declare
type databuf_arr is table of clob index by binary_integer;
pdatabuf databuf_arr;
begin
dbms_lob.createtemporary(pdatabuf(1), true, dbms_lob.session);
end;
/

ERROR at line 1:
ORA-01403: no data found ORA-06512: at line 5
Which two are valid options to prevent this error from occurring?


A. Line 5 should be replaced with:
DBMS_LOB.CREATETEMPORARY (pdatabuf (1), TRUE, DBMS_LOB.CALL);

B. Line 5 should be replaced with:
DBMS_LOB.CREATETEMPORARY (pdatabuf (1), FALSE, DBMS_LOB.SESSION);

***C. Rewrite the block as:
DECLARE
TYPE databuf_arr IS TABLE OF CLOB INDEX BY BINATY_INTEGER; pdatabuf databuf_arr;
PROCEDURE mytemplob (x OUT CLOB) IS
BEGIN
DBMS_LOB.CREATETEMPORARY (x, TRUE, DBMS_LOB, SESSION);
END; BEGIN mytemplob (pdatabuf (1));
END;
/

***D. pdatabuf (1) := NULL; --should be added after line 4.

E. Line 5 should be replaced with:
DBMS_LOB.CREATETEMPORARY (pdatabuf, TRUE, DBMS_LOB.SESSION);

�-C
DECLARE
TYPE databuf_arr IS TABLE OF CLOB INDEX BY BINArY_INTEGER;
pdatabuf databuf_arr;
PROCEDURE mytemplob (x OUT CLOB) IS
BEGIN
DBMS_LOB.CREATETEMPORARY (x, TRUE, DBMS_LOB.SESSION);
END;
BEGIN
mytemplob (pdatabuf (1));
END;
/
�-D
declare
type databuf_arr is table of clob index by binary_integer;
pdatabuf databuf_arr;
begin
pdatabuf (1) := NULL; -- d
dbms_lob.createtemporary(pdatabuf(1), true, dbms_lob.session); -- def
end;
/
--###############################--
Examine this block of code used to calculate the price increase for all the productivity by 1% and then by 2%.
set serveroutput on
DECLARE
incr_percent NUMBER :=.01;
CURSOR pdt_cur IS
SELECT prod_name, (prod_min_price*incr_percent) inc FROM pdts;
BEGIN
FOR pdt_rec IN pdt_cur
LOOP
DBMS_OUTPUT.PUT_LINE('PROD NAME '||pdt_rec.prod_name || ' PRICE INCREMENT AMT '|| pdt_rec.inc);
incr_percent := incr_percent + .01;
END LOOP;
END;

What will be the outcome on execution?
***A. It will give an error because the calculated column in the cursor is not using a column alias in this block.
B. It will go into an endless loop because the loop exist condition is missing.
C. It will display the price increase by 1% only for all the products.
D. It will display the price increase by 1% only for the first product.
E. It will give an error because PDT_REC is not declared.


--###############################--
You created a PL/SQL function with the RESULT_CACHE clause, which calculates a percentage of total marks for each student by querying the MARKS table.
Under which two circumstances will the cache for this function not be used and the function body be executed instead?
***A. When a user fixes incorrect marks for a student, with an update to the MARKS table, and then executes the function in the same session
B. When the amount of memory allocated for the result cache is increased
C. When the function is executed in a session frequently with the same parameter value
***D. When the database administrator disables the result cache during ongoing application patching
E. When the maximum amount of server result cache memory that can be used for a single result is set to 0.

--E is not valid because this parameter range is from 1 to 100, so it is not possible to set it to 0
--###############################--

QUESTION 4
Which statement is true about the DBMS_PARALLEL_EXECUTE package?
A. DBMS_PARALLEL_EXECUTE is a SYS-owned package and can be accessed only by a user with DBA
privileges.
B. To execute chunks in parallel, users must have CREATE JOB system privilege.
C. No specific system privileges are required to create or run parallel execution tasks.
D. Only DBAs can create or run parallel execution tasks.
E. Users with CREATE TASK privilege can create or run parallel execution tasks.
Correct Answer: B
Section: (none)
Explanation
Explanation/Reference:
Reference https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_parallel_ex.htm#ARPLS67331
(security model)

--###############################--
QUESTION 5
Which two statements are true regarding edition-based redefinition (EBR)?
A. There is no default edition defined in the database.
B. EBR does not let you upgrade the database components of an application while in use.
C. You never use EBR to copy the database objects and redefine the copied objects in isolation.
D. Editions are non-schema objects.
E. When you change an editioned object, all of its dependents remain valid.
F. Tables are not editionable objects.

Correct Answer: EF
Section: (none)
Explanation
Explanation/Reference:
Reference: https://docs.oracle.com/cd/E11882_01/appdev.112/e41502/adfns_editions.htm#BABEHGAF

--###############################--
QUESTION 6
Which two blocks of code execute successfully?
A. DECLARE
SUBTYPE new_one IS BINARY_INTERGER RANGE 0..9;
my_val new_one;
BEGIN
my_val :=0;
END;
B. DECLARE
SUBTYPE new_string IS VARCHAR2 (5) NOT NULL;
my_str_new_string;
BEGIN
my_str := �abc�;
END;
C. DECLARE
SUBTYPE new_one IS NUMBER (2, 1);
my_val new_one;
BEGIN
my_val :=12.5;
END;
D. DECLARE
SUBTYPE new_one IS INTEGER RANGE 1..10 NOT NULL;
my_val new_one;
BEGIN
my_val :=2;
END;
E. DECLARE
SUBTYPE new_one IS NUMBER (1, 0);
my_val new_one;
BEGIN
my_val := -1;
END;
Correct Answer: AD
Section: (none)
Explanation
Explanation/Reference:


--###############################--
QUESTION 11
Examine this function header:
FUNCTION calc_new_sal (emp_id NUMBER) RETURN NUMBER;
You want to ensure that whenever this PL/SQL function is invoked with the same parameter value across
active sessions, the result is not recomputed.
If a DML statement is modifying a table which this function depends upon, the function result must be
recomputed at that point in time for all sessions calling this function.

Which two actions should you perform?
A. Ensure RESULT_CACHE_MAX_SIZE is greater than 0.
B. Enable the result cache by using DBMS_RESULT_CACHE.BYPASS (FALSE).
C. Add the deterministic clause to the function definition.
D. Add the RELIES_ON clause to the function definition.
E. Add the RESULT_CACHE clause to the function definition.
Correct Answer: AC

--###############################--
With SERVEROUTPUT enabled, you succesfully create the package YEARLY_LIST:

CREATE PACKAGE yearly_list IS
    TYPE list1 IS TABLE OF VRCHAR2(20) INDEX BY PLS_INTEGER;
    FUNCTION init_list1 RETURN list1;
END yearly_list;
/

CREATE PACKAGE BODY yearly_list IS
    FUNCTION init_list1 RETURN list1 IS
    create_list list1;
    BEGIN
      create_list(1):= 'Jan';
      create_list(3):= 'Feb';
      create_list(6):= 'Mar';
      create_list(8):= 'Apr';
      RETURN create_list;
    END init_list1;
END yearly_list;
/

Examine this code:

DECLARE 
    v_yrl yearly_list.create_list();
    location NUMBER :=1;
BEGIN
    WHILE location IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(v_yrl(location));
        location := v_yrl.NEXT;
    END LOOP;
END;    
/

  
You want to display the contents of CREATE_LIST.
Which two lines need to be corrected in the PL/SQL block?
A. Line 2
B. Line 3
C. Line 5
D. Line 6
E. Line 7
Correct Answer: AE
--###############################--
QUESTION 16
Examine this code:
What is the correct statement to get the value of attribute ACCOUNT_MGR after the procedure has been
executed?
A. SELECT USERENV (�ACCOUNT_MGR�) FROM dual;
B. SELECT SYS_CONTEXT (�USERENV�, �ACCOUNT_MGR�) FROM dual;
C. SELECT SYS_CONTEXT (�ORDER_CTX�, �ACCOUNT_MGR�) FROM dual;
D. SELECT SYS_CONTEXT (�ACCOUNT_MGR�, �ORDER_CTX�) FROM dual;
E. SELECT USERENV (�ORDER_CTX�) FROM dual;
Correct Answer: B
--###############################--
QUESTION 17
Which data dictionary view contains the list of procedures and functions defined within package specification
that you can execute?

A. ALL_SOURCE
B. ALL_DEPENDENCIES
C. ALL_OBJECTS
D. ALL_PROCEDURES
E. ALL_PLSQL_OBJECT_SETTINGS

Correct Answer: D
--###############################--
Examine this code:

CREATE FUNCTION emp_policy_fn (v_schema IN VARCHAR2, v_objname IN VARCHAR2)
RETURN VARCHAR2 AS
    con VARCHAR2(200);
BEGIN
  con:= 'depno=30';
  RETURN con;
END emp_policy_fn;
/

BEGIN
DBMS_RLS.ADD_POLICY(
  object_schema => 'scott',
  object_name => 'emp',
  policy_name => 'emp_policy',
  policy_function => 'emp_policy_fn',
  update_cheek => TRUE,
  statement_types => 'SELECT,UPDATE',
  sec_relevant_cols => 'sal,comm');
END;
/

Examine this DML statement executed in the SCOTT schema:
UPDATE emp SET comm = 1000 WHERE deptno= 20;

What is the outcome after executing this statement?
A. COMM is set to 1000 for all records in the EMP table where DEPTNO = 30.
B. The statement executes successfully but no rows are updated.
C. COMM is set to 1000 for all records in the EMP table where DEPTNO=20.
D. The statement fails with error ORA-28115: policy with check option violation.

Correct Answer: D

--###############################--
QUESTION 19
Identify the two correct scenarios where a function can be optimized using the function result cache feature.
A. A function which inserts multiple records into a DEPARTMENTS table as part of one-time data setup for an
HR application.
B. A function which accesses multiple tables and calculates the commission to be given to a sales
representative based on the number of products sold by that representative.
C. A function which deletes all the records from an EMPLOYEES_AUDIT table based on their LOG_DATE.
D. A function which updates the SALARY of all the employees in an EMPLOYEES table by a fixed percentage
based on their DESIGNATION.
E. A function which calculates the factorial of a given number without accessing any table.

Correct Answer: DE

--###############################--
QUESTION 20
Select the correct statement regarding BEQUEATH CURRENT_USER.
A. If a view references a PL/SQL function then BEQUEATH CURRENT_USER allows the function to execute
with DBA privileges, regardless of the invoking user�s privileges.
B. The BEQUEATH CURRENT_USER clause allows invoker�s rights functions referenced in a view to
execute with the privileges of the invoking user.
C. Any view calling a PL/SQL function with BEQUEATH CURRENT_USER in effect will execute with the
privileges of the function owner.
D. With the BEQUEATH CURRENT_USER clause, a definer�s rights function referenced in a view executes
with the privileges of the view owner, not the function owner.

Correct Answer: B
Explanation/Reference:
Reference: https://docs.oracle.com/database/121/DBSEG/dr_ir.htm#DBSEG558
--###############################--
QUESTION 21
Which tablespace is used to store the data collected by PL/Scope?
A. UNDOTBS1
B. SYSAUX
C. SYSTEM
D. TEMP
E. USERS

Correct Answer: B
Explanation/Reference:
Reference: https://docs.oracle.com/cd/B28359_01/appdev.111/b28424/adfns_plscope.htm#BABDGJAF
--###############################--
QUESTION 22
Which must be true in order to add RESULT_CACHE to a function header and have it compile successfully?
A. The IN parameters must not include BLOB, CLOB, collection or record data types.
B. The function must be created with invoker�s rights or in an anonymous block.
C. The function must be declared as a pipelined table function.
D. The function must have an OUT or an IN OUT parameter.
Correct Answer: A
Section: (none)
VCEConvert.com
Explanation
Explanation/Reference:
Reference: https://docs.oracle.com/cd/E18283_01/appdev.112/e17126/subprograms.htm#insertedID11

--###############################--
QUESTION 23
Which two statements are true with respect to fine-grained access control?
A. It is implemented by end users.
B. It can be used to implement column masking.
C. It implements security rules through functions and associates these security rules with tables, views or
synonyms.
D. Separate policies are required for queries versus INSERT/UPDATE/DELETE statements.
E. The DBMS_FGA package is used to set up fine-grained access control.

Correct Answer: CD
Explanation/Reference:
Reference: https://docs.oracle.com/cd/B19306_01/server.102/b14220/security.htm
--###############################--
DECLARE 
    TYPE ntb1 IS TABLE OF VARCHAR2(20);
    v1 ntb1:=ntb1('hello', 'word', 'test');
    TYPE ntb1 IS TABLE OF ntb1 INDEX BY PLS_INTEGER;
    v3 ntb2;
BEGIN
v3(31):=ntb1(4,5,6);
v3(32):=v1;
v3(33):=ntb1(2,5,1);
v3(31):=ntb1(1,1);
v3.DELETE;
END;
/

Which two statements are correct about the collections before v3. DELETE is executed?
A. The values of v3(31) (2) and v3 (33) (2) are identical.
B. The value of v3 (31) (3) is 6.
C. The value of v3 (31) (1) and v3 (33) (3) are identical,
D. The value of v3 (31) (1) is �hello�.
E. The values of v3 (32) (2) and v1 (2) are identical.
Correct Answer: CE
--###############################--
Which two statements are true about the DBMS_LOB package?
A. DBMS_LOB.COMPARE can compare parts of two LOBs.
B. DBMS_LOB.COMPARE returns the size difference of the compared LOBs.
C. DBMS_LOB.COMPARE is overloaded and can compare CLOBs with BLOBs.
D. If the destination LOB is a temporary LOB, the row must be locked before calling
DBMS_LOB.CONVERTTOBLOB.
E. Before calling DBMS_LOB.CONVERTTOBLOB, both the source and destination LOB instances must exist.

Correct Answer: AE
Explanation/Reference:
Reference: https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_lob.htm#BABDDFD
--###############################--
The STUDENTS table with column LAST_NAME of data type VARCHAR2 exists in your database schema.
Examine this PL/SQL block:

DECLARE
    CURSOR name_cur IS
        SELECT last_name FROM students WHERE last_name LIKE 'A%';
    TYPE l_name_type IS VARRAY(25) OF students.last_name%TYPE;
    names_varray l_name_type;
    v_index INTEGER:=0;
BEGIN
    FOR name_rec IN name_cur LOOP
        v_index:=v_index+1;
        names_varray()v_index):=name_rec.last_name;
        DBMS_OUTPUT.PUT_LINE(names_varray(v_index));
     END LOOP;
AND;

Which two actions must you perform for this PL/SQL block to execute successfully?
A. Replace the FOR loop with FOR name_rec IN names_varray.FIRST .. names_varray.LAST LOOP.
B. Replace the L_NAME_TYPE declaration with TYPE 1_name_type IS VARRAY (25) OF
SYS_REFCURSOR;
C. Add name_rec name_cur%ROWTYPE; at the end of the DECLARE section.
D. Replace the NAMES_VARRAY declaration with names_varray 1_name_type := 1_name_type ();
E. Replace the NAMES_VARRAY declaration with names_varray 1_name_type := null;
F. Add names_varray.EXTEND after the FOR �LOOP statement.
Correct Answer: EF

--###############################--
Which two blocks of code execute successfully?
A. DECLARE
TYPE tab_type IS TABLE OF NUMBER;
my_tab tab_type;
BEGIN
my_tab (1) :=1;
END;
B. DECLARE
TYPE tab_type IS TABLE OF NUMBER;
my_tab tab_type := tab_type(2);
BEGIN
my_tab(1) :=55;
END;
C. DECLARE
TYPE tab_type IS TABLE OF NUMBER;
my_tab tab_type;
BEGIN
my_tab. EXTEND (2);
my_tab (1) := 55;
END;
D. DECLARE
TYPE tab_type IS TABLE OF NUMBER;
my_tab tab_type;
BEGIN
my_tab := tab_type ();
my_tab (1) := 55;
END;
E. DECLARE
TYPE tab_type IS TABLE OF NUMBER
my_tab tab_type := tab_type (2, NULL, 50);
BEGIN
my_tab.EXTEND (3, 2);
END;

Correct Answer: BD
--###############################--
Examine this code:
CREATE FUNCTION invoice_date RETURN VARCHAR2
RESULT_CACHE AUTHID DEFINER
l_date VARCHAR2(50);
BEGIN
l_date := SYSDATE;
RETURN l_date;
END;

Users of this function may set different date formats in their sessions.
Which two modifications must be made to allow the use of your session�s date format when outputting the
cached result of this function?
A. Change the RETURN type to DATE.
B. Change AUTHID to CURRENT_USER.
C. Use the TO_CHAR function around SYSDATE, that is, 1_date := TO_CHAR (SYSDATE).
D. Change the data type of 1_date to DATE.
E. Set NLS_DATE_FORMAT to �DD-MM-YY� at the instance level.
F. Set the RESULT_CACHE_MODE parameter to FORCE.

Correct Answer: AB

--###############################--
Which statement is true about internal and external LOBs?
A. An external LOB can be loaded into an internal LOB variable using the DBMS_LOB package.
B. A NOEXIST_DIRECTORY exception can be raised when using internal and external LOBs.
C. Internal and external LOBs can be written using DBMS_LOB.
D. After an exception transfers program control outside a PL/SQL block, all references to open external LOBs
are lost.
E. When using DBMS_LOB.INSTR for internal and external LOBs, DBMS_LOB.OPEN should be called for
each LOB.

Correct Answer: DE

Explanation/Reference:
Reference: https://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_lob.htm
--###############################--
Which two statements about the PL/SQL hierarchical profiler are true?
A. Access it using the DBMS_PROFILER package.
B. Access it using the DBMS_HPROF package.
C. Profiler data is recorded in tables and published in HTML reports.
D. It is only accessible after a grant of the CREATE PROFILE privilege.
E. It helps you identify subprograms that are causing bottlenecks in application performance.
Correct Answer: BE

Explanation/Reference:
Reference: https://docs.oracle.com/cd/B28359_01/appdev.111/b28370/tuning.htm#LNPLS01214
--###############################--
QUESTION 31
Examine this Java method in class Employee, loaded into the Oracle database:
Public static int updateSalary (String name, float salary) {�}
Which PL/SQL specification can be used to publish this method?
A. CREATE FUNCTION update_salary (p_nm VARCHAR2, p_sal NUMBER)
RETURN PLS_INTEGER AS LANGUAGE JAVA
LIBRARY �Employee� NAME �updateSalary�
PARAMETERS (p_nm java.lang. String, p_sal float, RETURN int);
B. CREATE FUNCTION update_salary (p_nm VARCHAR2, p_sal NUMBER)
RETURN PLS_INTEGER AS LANGUAGE JAVA
NAME �Employee.updateSalary�
PARAMETERS (p_nm java.lang.String, p_sal float, RETURN int);
C. CREATE FUNCTION update_salary (p_nm VARCHAR2, p_sal NUMBER)
RETURN PLS_INTEGER AS LANGUAGE JAVA
NAME �Employee.updateSalary�
PARAMETERS (�name� java.lang.String, �salary� float, RETURN int);
D. CREATE FUNCTION update_salary (p_nm VARCHAR2, p_sal NUMBER)
RETURN PLS_INTEGER AS LANGUAGE JAVA
NAME �Employee.updateSalary (java.lang.String, float) return int�;
E. CREATE FUNCTION update_salary (p_nm VARCHAR2, p_sal NUMBER)
RETURN PLS_INTEGER AS LANGUAGE JAVA
NAME �int Employee.updateSalary (java.lang.String, float)�;

Correct Answer: D
--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--


