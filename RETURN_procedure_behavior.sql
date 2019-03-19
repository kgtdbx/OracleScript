--https://docs.oracle.com/cd/B14117_01/appdev.101/b10807/13_elems040.htm

DECLARE
   FUNCTION num_rows (table_name VARCHAR2) RETURN user_tables.num_rows%TYPE
   IS
        howmany user_tables.num_rows%TYPE;
   BEGIN
      EXECUTE IMMEDIATE 'SELECT num_rows FROM user_tables ' ||
         'WHERE table_name = ''' || UPPER(table_name) || ''''
         INTO howmany;
-- A function can compute a value, then return that value.
      RETURN howmany;
   END num_rows;

   FUNCTION double_it(n NUMBER) RETURN NUMBER
   IS
   BEGIN
-- A function can also return an expression.
      RETURN n * 2;
   END double_it;

   PROCEDURE print_something
   IS
   BEGIN
      dbms_output.put_line('Message 1.');
-- A procedure can end early by issuing RETURN with no value.
      RETURN;
      dbms_output.put_line('Message 2 (never printed).');
   END;
BEGIN
   dbms_output.put_line('EMPLOYEES has ' || num_rows('employees') || ' rows.');
   dbms_output.put_line('Twice 100 is ' || double_it(n => 100) || '.');
   print_something;
END;
/