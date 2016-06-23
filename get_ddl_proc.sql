CREATE OR REPLACE TYPE ddl_ty AS OBJECT (   object_name
VARCHAR2(30),   object_type VARCHAR2(30),   orig_schema
VARCHAR2(30),   orig_ddl    CLOB ) / CREATE OR REPLACE TYPE
ddl_ty_tb AS TABLE OF ddl_ty /

CREATE OR REPLACE FUNCTION get_object_ddl (input_values
SYS_REFCURSOR) RETURN ddl_ty_tb PIPELINED IS

PRAGMA AUTONOMOUS_TRANSACTION;

-- variables to be passed in by sys_refcursor */ object_name  VARCHAR2(30); object_type  VARCHAR2(30); orig_schema VARCHAR2(30);


-- setup output record of TYPE tableddl_ty out_rec ddl_ty := ddl_ty(NULL,NULL,NULL,NULL);

/* setup handles to be used for setup and fetching metadata
information handles are used to keep track of the different objects
(DDL) we will be referencing in the PL/SQL code */ hOpenOrig  
NUMBER; hModifyOrig NUMBER; hTransDDL   NUMBER; dmsf       
PLS_INTEGER; Orig_ddl  CLOB; ret        NUMBER; BEGIN   /* Strip off
Attributes not concerned with in DDL. If you are concerned with
     TABLESPACE, STORAGE, or SEGMENT information just comment out these few lines. */   dmsf := dbms_metadata.session_transform;  
dbms_metadata.set_transform_param(dmsf, 'TABLESPACE', FALSE);  
dbms_metadata.set_transform_param(dmsf, 'STORAGE', FALSE);  
dbms_metadata.set_transform_param(dmsf, 'SEGMENT_ATTRIBUTES',
FALSE);   dbms_metadata.set_transform_param(dmsf, 'PRETTY', TRUE);  
dbms_metadata.set_transform_param(dmsf, 'SQLTERMINATOR', TRUE);

  -- Loop through each of the rows passed in by the reference cursor
LOOP
    /* Fetch the input cursor into PL/SQL variables */
    FETCH input_values INTO object_name, orig_schema, object_type;
    EXIT WHEN input_values%NOTFOUND;

    hOpenOrig := dbms_metadata.open(object_type);
    dbms_metadata.set_filter(hOpenOrig,'NAME',object_name);
    dbms_metadata.set_filter(hOpenOrig,'SCHEMA',orig_schema);

    hModifyOrig := dbms_metadata.add_transform(hOpenOrig,'MODIFY');
    dbms_metadata.set_remap_param(hModifyOrig,'REMAP_SCHEMA',orig_schema,null);

    -- This states to created DDL instead of XML to be compared
    hTransDDL := dbms_metadata.add_transform(hOpenOrig ,'DDL');

    Orig_ddl := dbms_metadata.fetch_clob(hOpenOrig);

      out_rec.object_name := object_name;
      out_rec.object_type := object_type;
      out_rec.orig_schema := orig_schema;
      out_rec.orig_ddl := Orig_ddl;
      PIPE ROW(out_rec);

    -- Cleanup and release the handles
    dbms_metadata.close(hOpenOrig);

  END LOOP;   RETURN; END get_object_ddl; / SELECT *   FROM
TABLE(get_object_ddl(CURSOR (SELECT object_name, owner, object_type
                               FROM dba_objects
                              WHERE owner = 'EMP'
                                    AND object_type IN
                                    ('VIEW',
                                         'TABLE',
                                         'TYPE',
                                         'PACKAGE',
                                         'PROCEDURE',
                                         'FUNCTION',
                                         'SEQUENCE'))));