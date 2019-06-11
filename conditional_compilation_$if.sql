http://stevenfeuersteinonplsql.blogspot.com/2019/04/setting-and-using-your-own-conditional.html


This post is the fourth in my series on conditional compilation. You will find links to the entire series at the bottom.

In this post, I explore how to set and use conditional compilation flags (also known as inquiry directives and referred to below as ccflags) used in $IF statements, and control which code will be included or excluded when compilation occurs.

In theory, you don't need ccflags at all. You could just create a package with static constants, like DBMS_DB_VERSION, and then reference those constants in $IF statements. That makes sense when many different compilation units (packages, procedures, triggers, functions, object types) need to be consistently controlled by the same settings. With the package approach, when you change a value for the constant, the dependent program units will be invalidated, and upon recompilation, will be compiled with the new values.

If, on the other hand, you want to add conditional compilation logic to a single unit, or a handful, then you might find a package dedicated to this purpose to be a bit too much. For this situation, you might consider using an inquiry directive instead. You know you're looking at a ccflag or inquiry directive, when you see an identifier prefixed by "$$".

An inquiry directive gets its value from the compilation environment, in three different ways:
from a PL/SQL compilation parameter
from a predefined ccflag
from a user-defined ccflag
Compilation Parameters
PL/SQL offers the following compilation parameters as inquiry directives:

$$PLSCOPE_SETTINGS - the current settings for PL/Scope for a program unit

$$PLSQL_CCFLAGS - the current settings for user-defined ccflags for a program unit

$$PLSQL_CODE_TYPE - the type of code, NATIVE or INTERPRETED

$$PLSQL_OPTIMIZE_LEVEL - the optimization level used to compile the program unit

$$PLSQL_WARNINGS - compile-time warnings setting  for the program unit

$$NLS_LENGTH_SEMANTICS - NLS length semantics for the program unit

--Here's a procedure you can use to display the current values for these parameters in your session (available for download in this LiveSQL script):
BEGIN
  DBMS_OUTPUT.PUT_LINE('$$PLSCOPE_SETTINGS = '     || $$PLSCOPE_SETTINGS);
  DBMS_OUTPUT.PUT_LINE('$$PLSQL_CCFLAGS = '        || $$PLSQL_CCFLAGS);
  DBMS_OUTPUT.PUT_LINE('$$PLSQL_CODE_TYPE = '      || $$PLSQL_CODE_TYPE);
  DBMS_OUTPUT.PUT_LINE('$$PLSQL_OPTIMIZE_LEVEL = ' || $$PLSQL_OPTIMIZE_LEVEL);
  DBMS_OUTPUT.PUT_LINE('$$PLSQL_WARNINGS = '       || $$PLSQL_WARNINGS);
  DBMS_OUTPUT.PUT_LINE('$$NLS_LENGTH_SEMANTICS = ' || $$NLS_LENGTH_SEMANTICS);
END;
This same information is stored persistently in the database for every program unit and is available through the USER/ALL_PLSQL_OBJECT_SETTINGS view, as in:
SELECT *
  FROM all_plsql_object_settings
 WHERE name = 'PROGRAM_NAME'
Predefined CCFlags
As of Oracle Database 19c, the ccflags automatically defined for any program unit are:

$$PLSQL_LINE - A PLS_INTEGER literal whose value is the number of the source line on which the directive appears in the current PL/SQL unit.

$$PLSQL_UNIT - A VARCHAR2 literal that contains the name of the current PL/SQL unit. If the current PL/SQL unit is an anonymous block, then $$PLSQL_UNIT contains a NULL value.

$$PLSQL_UNIT_OWNER - A VARCHAR2 literal that contains the name of the owner of the current PL/SQL unit. If the current PL/SQL unit is an anonymous block, then $$PLSQL_UNIT_OWNER contains a NULL value.

$$PLSQL_UNIT_TYPE - A VARCHAR2 literal that contains the type of the current PL/SQL unit—ANONYMOUS BLOCK, FUNCTION, PACKAGE, PACKAGE BODY, PROCEDURE, TRIGGER, TYPE, or TYPE BODY. Inside an anonymous block or non-DML trigger, $$PLSQL_UNIT_TYPE has the value ANONYMOUS BLOCK.

You might be disappointed, however, in how you can use these flags. Selective directives ($IF) must contain only static expressions, which means they are resolved at compilation time, which means in the world of Oracle Database, that you can only work with integer and Boolean values.

So this code will compile:
PROCEDURE test_cc
IS
BEGIN
   $IF $$PLSQL_UNIT IS NULL $THEN
   -- Include this line
   $END
   NULL;
END;
but this gives me a headache:
PROCEDURE test_cc
IS
BEGIN
   $IF $$PLSQL_UNIT = 'TEST_CC' $THEN
   -- Include this line
   $END
   NULL;
END;

PLS-00174: a static boolean expression must be used
Consequently, these predefined flags are mostly used for tracing and logging purposes, as in:
CREATE OR REPLACE PROCEDURE using_predefined_ccflags
   AUTHID DEFINER
IS
   myvar   INTEGER := 100;
BEGIN
   DBMS_OUTPUT.put_line (
      'On line ' || $$plsql_line || ' value of myar is ' || myvar);
   RAISE PROGRAM_ERROR;      
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Failure in program unit ' ||
            $$plsql_unit_owner || '.' ||
            $$plsql_unit_type || '.' ||
            $$plsql_unit);
END;
/

BEGIN
   using_predefined_ccflags;
END;
/

Procedure created.
Statement processed.
On line 7 value of myar is 100
Failure in program unit SCOTT.PROCEDURE.USING_PREDEFINED_CCFLAGS
User-defined CCFLags
User-defined ccflags are defined by setting the PLSQL_CCFlags parameter before your program unit is compiled. You can set ccflags in this way at the session or program unit level. Here are some examples:
ALTER SESSION SET plsql_ccflags = 'Flag1:10, Flag2:true'
/

ALTER PROCEDURE myproc
COMPILE SET PLSQL_CCFlags = 'Flag1:10, Flag2:true' REUSE SETTINGS
/
Since these are user-defined, you can use them for, well, just about anything. You can turn on and off tracing, or the amount of tracing. You can include or exclude chunks of code depending on features your users have paid for. You can expose otherwise private packaged subprograms in the package specification so you can test them directly, and then make sure they are hidden in production.

--Here's an example of that use case (also in LiveSQL):
ALTER SESSION SET PLSQL_CCFLAGS = 'show_private_joke_programs:TRUE'
/

CREATE OR REPLACE PACKAGE sense_of_humor
IS
   PROCEDURE calc_how_funny (
      joke_in               IN       VARCHAR2
    , funny_rating_out      OUT      NUMBER
    , appropriate_age_out   OUT      NUMBER
   );
$IF $$show_private_joke_programs $THEN
   FUNCTION humor_level ( joke_in IN VARCHAR2 )
      RETURN NUMBER;
            
    FUNCTION maturity_level ( joke_in IN VARCHAR2 )
      RETURN NUMBER;
$END         
END;
/

CREATE OR REPLACE PACKAGE BODY sense_of_humor
IS
   FUNCTION humor_level ( joke_in IN VARCHAR2 )
      RETURN NUMBER
   IS
   BEGIN
      -- Some really interesting code here...
      RETURN NULL;
   END humor_level;

   FUNCTION maturity_level ( joke_in IN VARCHAR2 )
      RETURN NUMBER
   IS
   BEGIN
      -- Some really interesting code here...
      RETURN NULL;
   END maturity_level;

   PROCEDURE calc_how_funny (
      joke_in               IN       VARCHAR2
    , funny_rating_out      OUT      NUMBER
    , appropriate_age_out   OUT      NUMBER
   )
   IS
   BEGIN
      funny_rating_out := humor_level ( joke_in );
      appropriate_age_out := maturity_level ( joke_in );
   END calc_how_funny;
END;
/

Tips for Using CCFlags
Don't Assume Anything
By which I mean: don't assume that user-defined ccflags have been set before compilation for use in production.

If a ccflag has not been defined with an ALTER command, it is evaluated to NULL.

So the behavior of your code in production should be, whenever possible, determined by the value of all of your ccflags set to NULL. That way, if for any reason the code is compiled without the proper ALTER statement run, you will not be dealing with a big mess.

Keep CCFlag Settings with Code
One way to avoid the problem described above is to keep all the ccflag settings needed for a particular program unit in the file for that unit itself. Then, whenever you need to compile that program unit, the ccflags are set first, and then the compilation occurs.

Check for Undefined CCFlags

--Use the compile-time warnings feature of PL/SQL to reveal any ccflags that have not been set at the time of compilation. Here's an example:
ALTER SESSION SET plsql_warnings = 'ENABLE:ALL'
/

CREATE OR REPLACE PACKAGE sense_of_humor AUTHID DEFINER
IS
   PROCEDURE calc_how_funny (
      joke_in               IN       VARCHAR2
    , funny_rating_out      OUT      NUMBER
    , appropriate_age_out   OUT      NUMBER
   );
$IF $$show_private_joke_programs $THEN
   FUNCTION humor_level ( joke_in IN VARCHAR2 )
      RETURN NUMBER;
$END         
END;
/

PLW-06003: unknown inquiry directive '$$SHOW_PRIVATE_JOKE_PROGRAMS'
Conditional Compilation Series
1. An introduction to conditional compilation
2. Viewing conditionally compiled code: what will be run?
3. Writing code to support multiple versions of Oracle Database
4. Setting and using your own conditional compilation flags