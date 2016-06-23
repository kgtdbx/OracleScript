DECLARE

   v_file    CLOB;
   v_buffer  VARCHAR2(32767);
   v_name    VARCHAR2(128) := 'clob2file_buffered.txt';
   v_lines   PLS_INTEGER := 0;
   v_eol     VARCHAR2(2);
   v_eollen  PLS_INTEGER;
   c_maxline CONSTANT PLS_INTEGER := 32767;

BEGIN

   v_eol := CASE
               WHEN DBMS_UTILITY.PORT_STRING LIKE 'IBMPC%'
               THEN CHR(13)||CHR(10)
               ELSE CHR(10)
            END;
   v_eollen := LENGTH(v_eol);

   DBMS_LOB.CREATETEMPORARY(v_file, TRUE);

   FOR r IN (SELECT x || ',' || y || ',' || z AS csv
             FROM   source_data)
   LOOP

      IF LENGTH(v_buffer) + v_eollen + LENGTH(r.csv) <= c_maxline THEN
         v_buffer := v_buffer || v_eol || r.csv;
      ELSE
         IF v_buffer IS NOT NULL THEN
            DBMS_LOB.WRITEAPPEND(
               v_file, LENGTH(v_buffer) + v_eollen, v_buffer || v_eol
               );
         END IF;
         v_buffer := r.csv;
      END IF;

      v_lines := v_lines + 1;

   END LOOP;

   IF LENGTH(v_buffer) > 0 THEN
      DBMS_LOB.WRITEAPPEND(
         v_file, LENGTH(v_buffer) + v_eollen, v_buffer || v_eol
         );
   END IF;

   DBMS_XSLPROCESSOR.CLOB2FILE(v_file, 'DUMP_DIR', v_name);
   DBMS_LOB.FREETEMPORARY(v_file);

   DBMS_OUTPUT.PUT_LINE('File='||v_name||'; Lines='||v_lines);

END;
/