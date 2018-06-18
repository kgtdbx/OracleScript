/*
Oracle 12c UTL_CALL_STACK for Easier Debugging
Original article
Submitted by Johnjayking on Sun, 2017-01-08 03:34
*/
/*
UTL_CALL_STACK
Oracle has provided PL/SQL debug aids for a long time; perhaps your show currently uses one or more of the following

dbms_utility.format_call_stack
dbms_utility.format_error_backtrace
dbms_utility.format_error_stack
Oracle 12c adds the UTL_CALL_STACK package providing greater insight into the stack.

UTL_CALL_STACK includes the following functions

BACKTRACE_DEPTH Number of items in backtrace
BACKTRACE_LINE Line number of unit in backtrace
BACKTRACE_UNIT Name of unit in backtrace
CURRENT_EDITION Current edition name for backtrace unit
CONCATENATE_SUBPROGRAM Concatenated unit name
DYNAMIC_DEPTH Number of subprograms on call stack
ERROR_DEPTH Number of errors on error stack
ERROR_MSG Error message for specified error
ERROR_NUMBER Error number for specified error
LEXICAL_DEPTH Lexical nesting level of subprogram
OWNER Backtrace unit owner name
UNIT_LINE Line number in backtrace unit
SUBPROGRAM Name of backtrace unit*/

--Example Procedure using UTL_STACK_TRACE
create or replace procedure Print_Call_Stack 
as
 DEPTH pls_integer := UTL_CALL_STACK.dynamic_depth();
 procedure printheaders
 is
 begin
 dbms_output.put_line( 'Lexical Depth Line Name' );
 dbms_output.put_line( 'Depth Number ' );
 dbms_output.put_line( '------- ----- ---- ----' );
 end printheaders;
 procedure print
 is
 begin
 printheaders;
 for stunit in reverse 1..DEPTH loop
 dbms_output.put_line(rpad( UTL_CALL_STACK.lexical_depth(stunit), 10 )||rpad( stunit, 7)||rpad(to_char(UTL_CALL_STACK.unit_line(stunit),'99'), 9 )||UTL_CALL_STACK.concatenate_subprogram(utl_call_stack.subprogram (1)));
 end loop;
 end print;
begin
 print;
end;
/

--Example PL/SQL Package to Test (does not directly call UTL_CALL_STACK)
create or replace package TestPkg is
 procedure proc_a;
 end TestPkg;
 / 
 create or replace package body TestPkg is
 procedure proc_a
 is
 procedure proc_b
 is
 procedure proc_c
 is
 procedure proc_d is
 begin
 Print_Call_Stack();
 raise program_error;
 end proc_d;
 begin
 proc_d();
 end proc_c;
 begin
 proc_c();
 end proc_b;
 begin
 proc_b();
 end proc_a;
 end TestPkg;
 
--UTL_CALL_STACK Output
/*Executing the package results in a stack trace; the second set of output below shows the dbms_output results from UTL_CALL_STACK. 
The first batch of output lines is part of the normal stack trace. 
The second set was generated using UTL_CALL_STACK and shows how the program managed to get to the point of the failure.
*/


 begin TestPkg.proc_a; end;
 
 /*
 Error report -
 ORA-06501: PL/SQL: program error
 ORA-06512: at "JOHN.TESTPKG", line 11
 ORA-06512: at "JOHN.TESTPKG", line 14
 ORA-06512: at "JOHN.TESTPKG", line 17
 ORA-06512: at "JOHN.TESTPKG", line 20
 ORA-06512: at line 1
 06501. 00000 - "PL/SQL: program error"
 *Cause: This is an internal error message. An error has 
 been detected in a PL/SQL program.
 *Action: Contact Oracle Support Services.
Lexical Depth Line Name
Depth Number 
------- ------ --------- ----
1 6 20 TESTPKG.PROC_A
2 5 17 TESTPKG.PROC_A.PROC_B
3 4 14 TESTPKG.PROC_A.PROC_B.PROC_C
4 3 10 TESTPKG.PROC_A.PROC_B.PROC_C.
 PROC_D
0 2 26 PRINT_CALL_STACK
1 1 17 PRINT_CALL_STACK.PRINT
Conclusion
UTL_CALL_STACK is NOT a user-oriented feature; it is directly squarely at the PL/SQL Developer and the DBA who need help determining not just where in a nest of PL/SQL calls an error occurred but HOW you got there!
*/
