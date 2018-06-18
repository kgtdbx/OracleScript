/*
UTL_CALL_STACK: Fine-grained execution call stack package (12.1)View All Scripts Login and Run Script
Script Name
UTL_CALL_STACK: Fine-grained execution call stack package (12.1)
Description
UTL_CALL_STACK, introduced in Oracle Database 12c, offers fine grained information about your execution call stack, as well as an API to the error stack and back trace. Or, as the doc states: "The UTL_CALL_STACK package provides an interface to provide information about currently executing subprograms. Functions return subprogram names, unit names, owner names, edition names, and line numbers for given dynamic depths. Other functions return error stack information." http://docs.oracle.com/database/121/ARPLS/u_call_stack.htm#ARPLS74078
Category
PL/SQL General
Contributor
Steven Feuerstein (Oracle)
Created
Tuesday February 02, 2016
*/
--Statement 1
CREATE OR REPLACE PACKAGE pkg1 AUTHID DEFINER
IS 
   PROCEDURE proc1; 
END pkg1;
/

--Statement 2
--The FORMAT_CALL_STACK function in DBMS_UTILITY only shows you the name of the program unit in the call stack (i.e., the package name, but not the function within the package). UTL_CALL_STACK only shows you the name of the package subprogram, but even the name of nested (local) subprograms within those. VERY COOL!
--Down to Subprogram Name!

CREATE OR REPLACE PACKAGE BODY pkg1 
IS 
   PROCEDURE proc1 
   IS 
      PROCEDURE nested_in_proc1 
      IS 
      BEGIN 
         DBMS_OUTPUT.put_line (
            '*** "Traditional" Call Stack using FORMAT_CALL_STACK');

         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);
 
         DBMS_OUTPUT.put_line (
            '*** Fully Qualified Nested Subprogram vis UTL_CALL_STACK'); 

         DBMS_OUTPUT.put_line ( 
            utl_call_stack.concatenate_subprogram ( 
               utl_call_stack.subprogram (1))); 
      END; 
   BEGIN 
      nested_in_proc1; 
   END; 
END pkg1;
/

--Statement 3
--First, you will see the "Traditional" formatted call stack, next the fully-qualified name of the top of that stack, culled out of the "mess" with the UTL_CALL_STACK API.
--The Call Stack Output

set serveroutput on
BEGIN 
   pkg1.proc1; 
END;

--Statement 4
--Need to get the line number on which an error was raised? You can stick with DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, sure. But now you can also opt for the UTL_CALL_STACK backtrace functions!
--Backtrace Info, Too!

CREATE OR REPLACE FUNCTION backtrace_to 
   RETURN VARCHAR2 AUTHID DEFINER 
IS 
BEGIN 
   RETURN    
      utl_call_stack.backtrace_unit(utl_call_stack.backtrace_depth)||' line '||utl_call_stack.backtrace_line(utl_call_stack.backtrace_depth); 
END; 
/

--Statement 5
CREATE OR REPLACE PACKAGE pkg1 AUTHID DEFINER 
IS 
   PROCEDURE proc1; 
 
   PROCEDURE proc2; 
END;
/

--Statement 6
CREATE OR REPLACE PACKAGE BODY pkg1 
IS 
   PROCEDURE proc1 
   IS 
      PROCEDURE nested_in_proc1 
      IS 
      BEGIN 
         RAISE VALUE_ERROR; 
      END; 
   BEGIN 
      nested_in_proc1; 
   END; 
 
   PROCEDURE proc2 
   IS 
   BEGIN 
      proc1; 
   EXCEPTION 
      WHEN OTHERS 
      THEN 
         RAISE NO_DATA_FOUND; 
   END; 
END pkg1;
/

--Statement 7
CREATE OR REPLACE PROCEDURE proc3 AUTHID DEFINER 
IS 
BEGIN 
   pkg1.proc2; 
END;
/

--Statement 8
BEGIN 
   proc3; 
EXCEPTION 
   WHEN OTHERS 
   THEN 
      DBMS_OUTPUT.put_line (backtrace_to);
END;
/

--
select backtrace_to() from dual;