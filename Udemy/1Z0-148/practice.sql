alter pluggable database all open;

alter session set container=orclpdb1;

Show con_name;

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
*** C. Privileges granted through roles are never in effect when running definer?s rights procedures.
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
A . va. LAST and va. LIMIT will return the same value.
***B . va. LAST and va. COUNT will return the same value.
C . va. LIMIT and va. COUNT will return the same value.
D . va. LIMIT and va. NEXT (199) will return the same value.
E . va. LAST will return 200.
***F . va. NEXT (199) will return NUL
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
"¦
RETUNRN total;
END;
/
B. CREATE FUNCTION totalEmp (sal IN NUMBER) RETURN NUMBER IS total NUMBER :=0;
BEGIN
"¦
RETUNRN total;
END;
/
C. CREATE FUNCTION totalEmp (sal IN PLS_INTEGER) RETURN NUMBER IS total NUMBER :=0;
BEGIN
"¦
RETUNRN total;
END;
/
D. CREATE FUNCTION totalEmp (sal IN BINARY_FLOAT) RETURN NUMBER IS total NUMBER :=0;
BEGIN
"¦
RETUNRN total;
END;
/
E. CREATE FUNCTION totalEmp (sal IN POSITIVEN) RETURN NUMBER IS total NUMBER :=0;
BEGIN
"¦
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

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

--###############################--

