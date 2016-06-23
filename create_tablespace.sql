--Examples
--These examples assume that your database is using 8K blocks.

--Creating a Bigfile Tablespace: Example 
--The following example creates a bigfile tablespace bigtbs_01 with a datafile bigtbs_f1.dat of 10 MB:

CREATE BIGFILE TABLESPACE bigtbs_01
  DATAFILE 'bigtbs_f1.dat'
  SIZE 20M AUTOEXTEND ON;
  
--Creating an Undo Tablespace: Example 
--The following example creates a 10 MB undo tablespace undots1:

CREATE UNDO TABLESPACE undots1
   DATAFILE 'undotbs_1a.f'
   SIZE 10M AUTOEXTEND ON
   RETENTION GUARANTEE;
   
--Creating a Temporary Tablespace: Example 
--This statement shows how the temporary tablespace that serves as the default temporary tablespace for database users in the sample database was created:

CREATE TEMPORARY TABLESPACE temp_demo
   TEMPFILE 'temp01.dbf' SIZE 5M AUTOEXTEND ON;

--If we assume that the default database block size is 2K, and that each bit in the map represents one extent, then each bit maps 2,500 blocks.
--The following example sets the default location for datafile creation and then creates a tablespace with an Oracle-managed tempfile in the default location. 
--The tempfile is 100 M and is autoextensible with unlimited maximum size. These are the default values for Oracle-managed files:

ALTER SYSTEM SET DB_CREATE_FILE_DEST = '$ORACLE_HOME/rdbms/dbs';

CREATE TEMPORARY TABLESPACE tbs_05;
--Adding a Temporary Tablespace to a Tablespace Group: Example 
--The following statement creates the tbs_temp_02 temporary tablespace as a member of the tbs_grp_01 tablespace group. 
--If the tablespace group does not already exist, then Oracle Database creates it during execution of this statement:

CREATE TEMPORARY TABLESPACE tbs_temp_02
  TEMPFILE 'temp02.dbf' SIZE 5M AUTOEXTEND ON
  TABLESPACE GROUP tbs_grp_01;

--Creating Basic Tablespaces: Examples 
--This statement creates a tablespace named tbs_01 with one datafile:

CREATE TABLESPACE tbs_01 
   DATAFILE 'tbs_f2.dat' SIZE 40M 
   ONLINE; 

--This statement creates tablespace tbs_03 with one datafile and allocates every extent as a multiple of 500K:

CREATE TABLESPACE tbs_03 
   DATAFILE 'tbs_f03.dbf' SIZE 20M
   LOGGING;
--Enabling Autoextend for a Tablespace: Example 
--This statement creates a tablespace named tbs_02 with one datafile. 
--When more space is required, 500 kilobyte extents will be added up to a maximum size of 100 megabytes:

CREATE TABLESPACE tbs_02 
   DATAFILE 'diskb:tbs_f5.dat' SIZE 500K REUSE
   AUTOEXTEND ON NEXT 500K MAXSIZE 100M;
--Creating a Locally Managed Tablespace: Example 
--The following statement assumes that the database block size is 2K.

CREATE TABLESPACE tbs_04 DATAFILE 'file_1.f' SIZE 10M
   EXTENT MANAGEMENT LOCAL UNIFORM SIZE 128K;

--This statement creates a locally managed tablespace in which every extent is 128K and each bit in the bit map describes 64 blocks.

--Specifying Segment Space Management for a Tablespace: Example 
--The following example creates a tablespace with automatic segment-space management:

CREATE TABLESPACE auto_seg_ts DATAFILE 'file_2.f' SIZE 1M
   EXTENT MANAGEMENT LOCAL
   SEGMENT SPACE MANAGEMENT AUTO;
--Creating Oracle-managed Files: Examples 
--The following example sets the default location for datafile creation and creates a tablespace with a datafile in the default location. The datafile is 100M and is autoextensible with an unlimited maximum size:

ALTER SYSTEM SET DB_CREATE_FILE_DEST = '$ORACLE_HOME/rdbms/dbs';

CREATE TABLESPACE omf_ts1;

--The following example creates a tablespace with an Oracle-managed datafile of 100M that is not autoextensible:

CREATE TABLESPACE omf_ts2 DATAFILE AUTOEXTEND OFF;