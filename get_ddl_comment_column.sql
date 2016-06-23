ops$tkyte%ORA9IR2> CREATE TABLE test_column (col1 VARCHAR2(1));

Table created.

ops$tkyte%ORA9IR2> COMMENT ON COLUMN test_column.col1 IS 'Client''s address';

Comment created.

ops$tkyte%ORA9IR2>
ops$tkyte%ORA9IR2> DECLARE
  2      ln_comment_handle       NUMBER;
  3      ln_comment_trans_handle NUMBER;
  4      lt_comment_ddls         sys.ku$_ddls;
  5  BEGIN
  6      ln_comment_handle       := dbms_metadata.OPEN(object_type => 'COMMENT');
  7      ln_comment_trans_handle := dbms_metadata.add_transform(handle => ln_comment_handle
  8                                                            ,NAME   => 'DDL');
  9
 10      dbms_metadata.set_filter(handle => ln_comment_handle
 11                              ,NAME   => 'BASE_OBJECT_NAME'
 12                              ,VALUE  => 'TEST_COLUMN');
 13
 14      lt_comment_ddls := dbms_metadata.fetch_ddl(ln_comment_handle);
 15      DBMS_OUTPUT.PUT_LINE('Got ' || lt_comment_ddls(1).ddltext);
 16  END;
 17  /
Got  COMMENT ON COLUMN "OPS$TKYTE"."TEST_COLUMN"."COL1" IS 'Client''s address'