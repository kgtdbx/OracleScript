DECLARE
   /*
    * Source data cursor and associative array type. Needed to
    * enable LIMIT-based fetching...
    */
   CURSOR cur IS
      SELECT * FROM src;

   TYPE aat IS TABLE OF cur%ROWTYPE
                  INDEX BY PLS_INTEGER;

   aa                aat;

   n                 PLS_INTEGER := 0;

   /* "Exceptions encountered in FORALL" exception... */
   bulk_exceptions   EXCEPTION;
   PRAGMA EXCEPTION_INIT (bulk_exceptions, -24381);

   /* FORALL error-logging... */
   PROCEDURE error_logging IS
      /* Associative array type of the exceptions table... */
      TYPE aat_exception IS TABLE OF tgt_exceptions%ROWTYPE
                               INDEX BY PLS_INTEGER;

      aa_exceptions   aat_exception;

      v_indx          PLS_INTEGER;

      /* Emulate DML error logging behaviour... */
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
         v_indx := SQL%BULK_EXCEPTIONS (i).ERROR_INDEX;

         /* Populate as many values as available... */
         aa_exceptions (i).ora_err_number$ :=
            SQL%BULK_EXCEPTIONS (i).ERROR_CODE;
         aa_exceptions (i).ora_err_mesg$ :=
            SQLERRM (SQL%BULK_EXCEPTIONS (i).ERROR_CODE * -1);
         aa_exceptions (i).ora_err_tag$ := 'FORALL ERROR LOGGING';
         aa_exceptions (i).ora_err_optyp$ := 'I';
         aa_exceptions (i).n1 := aa (v_indx).n1;
         aa_exceptions (i).d1 := aa (v_indx).d1;
         aa_exceptions (i).v1 := aa (v_indx).v1;
         aa_exceptions (i).v2 := aa (v_indx).v2;
      END LOOP;

      /* Load the exceptions into the exceptions table... */
      FORALL i IN INDICES OF aa_exceptions
         INSERT INTO tgt_exceptions
              VALUES aa_exceptions (i);

      COMMIT;
   END error_logging;
BEGIN
   OPEN cur;

   LOOP
      FETCH cur
      BULK COLLECT INTO aa
      LIMIT 100;

      EXIT WHEN aa.COUNT = 0;

      BEGIN
         FORALL i IN INDICES OF aa SAVE EXCEPTIONS
            INSERT INTO tgt
                 VALUES aa (i);
      EXCEPTION
         WHEN bulk_exceptions THEN
            n := n + SQL%ROWCOUNT;
            error_logging ();
      END;

      COMMIT;
   END LOOP;

   CLOSE cur;

   DBMS_OUTPUT.put_line (n || ' rows inserted.');
END;
/


--######################################--
set serveroutput on

CREATE OR REPLACE PROCEDURE plch_check_balance (
   balance_in IN NUMBER)
   AUTHID DEFINER
IS
BEGIN
   IF balance_in < 0
   THEN
      RAISE VALUE_ERROR;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
END;
/

BEGIN
   plch_check_balance (-1);
END;
/

CREATE OR REPLACE PROCEDURE plch_check_balance (
   balance_in IN NUMBER)
   AUTHID DEFINER
IS
BEGIN
   IF balance_in < 0
   THEN
      RAISE VALUE_ERROR;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

BEGIN
   plch_check_balance (-1);
END;
/

CREATE OR REPLACE PROCEDURE plch_check_balance (
   balance_in IN NUMBER)
   AUTHID DEFINER
IS
BEGIN
   IF balance_in < 0
   THEN
      RAISE VALUE_ERROR;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (   'ORA-'
         || TO_CHAR (UTL_CALL_STACK.error_number (1), 'fm00000')
         || ': '
         || UTL_CALL_STACK.error_msg (1));
END;
/

BEGIN
   plch_check_balance (-1);
END;
/

DROP PROCEDURE plch_check_balance
/