4.6 Changing a Nonpartitioned Table into a Partitioned Table
You can change a nonpartitioned table into a partitioned table.

The following topics are discussed:

Using Online Redefinition to Partition Collection Tables

Converting a Non-Partitioned Table to a Partitioned Table

See Also:
Oracle Database Administrator’s Guide for information about redefining partitions of a table
4.6.1 Using Online Redefinition to Partition Collection Tables
Oracle Database provides a mechanism to move one or more partitions or to make other changes to the partitions' physical structures without significantly affecting the availability of the partitions for DML. This mechanism is called online table redefinition.

You can use online redefinition to copy nonpartitioned Collection Tables to partitioned Collection Tables and Oracle Database inserts rows into the appropriate partitions in the Collection Table. Example 4-35 illustrates how this is done for nested tables inside an Objects column; a similar example works for Ordered Collection Type Tables inside an XMLType table or column. During the copy_table_dependents operation, you specify 0 or false for copying the indexes and constraints, because you want to keep the indexes and constraints of the newly defined collection table. However, the Collection Tables and its partitions have the same names as that of the interim table (print_media2 in Example 4-35). You must take explicit steps to preserve the Collection Table names.

Example 4-35 Redefining partitions with collection tables

CONNECT / AS SYSDBA
DROP USER eqnt CASCADE;
CREATE USER eqnt IDENTIFIED BY eqnt;
GRANT CONNECT, RESOURCE TO eqnt;
 
-- Grant privleges required for online redefinition.
GRANT EXECUTE ON DBMS_REDEFINITION TO eqnt;
GRANT ALTER ANY TABLE TO eqnt;
GRANT DROP ANY TABLE TO eqnt;
GRANT LOCK ANY TABLE TO eqnt;
GRANT CREATE ANY TABLE TO eqnt;
GRANT SELECT ANY TABLE TO eqnt;
 
-- Privileges required to perform cloning of dependent objects.
GRANT CREATE ANY TRIGGER TO eqnt;
GRANT CREATE ANY INDEX TO eqnt;
 
CONNECT eqnt/eqnt
 
CREATE TYPE textdoc_typ AS OBJECT ( document_typ VARCHAR2(32));
/
CREATE TYPE textdoc_tab AS TABLE OF textdoc_typ;
/

-- (old) non partitioned nested table
CREATE TABLE print_media
    ( product_id        NUMBER(6) primary key
    , ad_textdocs_ntab  textdoc_tab
    )
NESTED TABLE ad_textdocs_ntab STORE AS equi_nestedtab
(   (document_typ NOT NULL)
    STORAGE (INITIAL 8M)
)
;
 
-- Insert into base table
INSERT INTO print_media VALUES (1,
   textdoc_tab(textdoc_typ('xx'), textdoc_typ('yy')));
INSERT INTO print_media VALUES (11,
   textdoc_tab(textdoc_typ('aa'), textdoc_typ('bb')));
COMMIT;
 
-- Insert into nested table
INSERT INTO TABLE
  (SELECT p.ad_textdocs_ntab FROM print_media p WHERE p.product_id = 11)
   VALUES ('cc');
 
SELECT * FROM print_media;

PRODUCT_ID   AD_TEXTDOCS_NTAB(DOCUMENT_TYP)
----------   ------------------------------
         1   TEXTDOC_TAB(TEXTDOC_TYP('xx'), TEXTDOC_TYP('yy'))
        11   TEXTDOC_TAB(TEXTDOC_TYP('aa'), TEXTDOC_TYP('bb'), TEXTDOC_TYP('cc'))
 
-- Creating partitioned Interim Table
CREATE TABLE print_media2
    ( product_id        NUMBER(6)
    , ad_textdocs_ntab  textdoc_tab
    )
NESTED TABLE ad_textdocs_ntab STORE AS equi_nestedtab2
(   (document_typ NOT NULL)
    STORAGE (INITIAL 8M)
)
PARTITION BY RANGE (product_id)
(
    PARTITION P1 VALUES LESS THAN (10),
    PARTITION P2 VALUES LESS THAN (20)
);
 
EXEC dbms_redefinition.start_redef_table('eqnt', 'print_media', 'print_media2');
 
DECLARE
 error_count pls_integer := 0;
BEGIN
  dbms_redefinition.copy_table_dependents('eqnt', 'print_media', 'print_media2',
                                          0, true, false, true, false,
                                          error_count);
 
  dbms_output.put_line('errors := ' || to_char(error_count));
END;
/
 
EXEC  dbms_redefinition.finish_redef_table('eqnt', 'print_media', 'print_media2');
 
-- Drop the interim table
DROP TABLE print_media2;
 
-- print_media has partitioned nested table here

SELECT * FROM print_media PARTITION (p1);

PRODUCT_ID   AD_TEXTDOCS_NTAB(DOCUMENT_TYP)
----------   ------------------------------
         1   TEXTDOC_TAB(TEXTDOC_TYP('xx'), TEXTDOC_TYP('yy'))

SELECT * FROM print_media PARTITION (p2);

PRODUCT_ID   AD_TEXTDOCS_NTAB(DOCUMENT_TYP)
----------   ------------------------------
        11   TEXTDOC_TAB(TEXTDOC_TYP('aa'), TEXTDOC_TYP('bb'), TEXTDOC_TYP('cc'))
4.6.2 Converting a Non-Partitioned Table to a Partitioned Table
A non-partitioned table can be converted to a partitioned table with a MODIFY clause added to the ALTER TABLE SQL statement.

In addition, the keyword ONLINE can be specified, enabling concurrent DML operations while the conversion is ongoing.

The following is an example of the ALTER TABLE statement using the ONLINE keyword for an online conversion to a partitioned table.

Example 4-36 Using the MODIFY clause of ALTER TABLE to convert online to a partitioned table

ALTER TABLE employees_convert MODIFY
  PARTITION BY RANGE (employee_id) INTERVAL (100)
  ( PARTITION P1 VALUES LESS THAN (100),
    PARTITION P2 VALUES LESS THAN (500)
   ) ONLINE
  UPDATE INDEXES
 ( IDX1_SALARY LOCAL,
   IDX2_EMP_ID GLOBAL PARTITION BY RANGE (employee_id)
  ( PARTITION IP1 VALUES LESS THAN (MAXVALUE))
 );
Considerations When Using the UPDATE INDEXES Clause

When using the UPDATE INDEXES clause, note the following.

This clause can be used to change the partitioning state of indexes and storage properties of the indexes being converted.

The specification of the UPDATE INDEXES clause is optional.

Indexes are maintained both for the online and offline conversion to a partitioned table.

This clause cannot change the columns on which the original list of indexes are defined.

This clause cannot change the uniqueness property of the index or any other index property.

If you do not specify the tablespace for any of the indexes, then the following tablespace defaults apply.

Local indexes after the conversion collocate with the table partition.

Global indexes after the conversion reside in the same tablespace of the original global index on the non-partitioned table.

If you do not specify the INDEXES clause or the INDEXES clause does not specify all the indexes on the original non-partitioned table, then the following default behavior applies for all unspecified indexes.

Global partitioned indexes remain the same and retain the original partitioning shape.

Non-prefixed indexes become global nonpartitioned indexes.

Prefixed indexes are converted to local partitioned indexes.

Prefixed means that the partition key columns are included in the index definition, but the index definition is not limited to including the partitioning keys only.

Bitmap indexes become local partitioned indexes, regardless whether they are prefixed or not.

Bitmap indexes must always be local partitioned indexes.

The conversion operation cannot be performed if there are domain indexes.