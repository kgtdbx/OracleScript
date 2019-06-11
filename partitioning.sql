--���������� �� �������� ��-------
--user_, all_, dba_
--���������� � ��������, � ��� ����� � ����������������
select * from user_tables;
--���������� � ���������������� ��������
select * from user_part_tables;
select * from all_part_tables;
--���������� � ��������� �������
select * from user_tab_partitions;
--subpartitions-----------------
SELECT table_name, partition_name, subpartition_name, subpartition_position
FROM user_tab_subpartitions;
--���������� � ������ ���������������
select * from user_part_key_columns;
--���������� � ��������� ��������, � ��� ����� � �������
select * from user_segments;
--���������� �� �������� ��, � ��� ����� � �������� � �������
select * from user_objects;
-------���������� � ���������������� ��������
select * from all_IND_PARTITIONS;
--------------------------------------
--������ �� ������ ����� ���� ������� ���������������
SELECT * FROM sales PARTITION (sales_99q1);
--����� ������� ������ �� ������� �� ������
UPDATE sales PARTITION (sales_99q1) s 
SET s.promo_id = 494
WHERE s.amount_sold > 1000;
--����� �������� ������ ������������� ������
--���������� ������ �� ���� ������, � ������� �������� ��������� �������� ��������
SELECT * FROM sales PARTITION FOR('02-FEB-1999');
--DELETE ����� �� ������
DELETE sales PARTITION(sales_99q1) WHERE cust_id = 1;
--INSERT (� ���������� ������ ���������������)
INSERT INTO sales PARTITION(sales_99q1) 
(prod_id, time_id) VALUES (1, '01-FEB-1999');
--UPDATE (�� ���������� ���� ���������������)
UPDATE sales PARTITION (sales_99q1)
SET promo_id = 494
WHERE amount_sold > 1000;
-----------��������� ������� �������� � ��������------------
--�������������� ������
ALTER TABLE sales RENAME PARTITION sales_99q2 TO sales_99h1;
--�������� ������
----��������, ������ ����� ��������� ������� ��������� 
----����� ������ �� ������� ���������� ������ ����� �������� � ������� ������ (���� ������ �� ���������)
ALTER TABLE sales DROP PARTITION sales_99q1;

--� �������� ALTER TABLE ������ �� ���������� ������ ������� �������� �� ������ �� ����� �� � �� �������� �����
ALTER TABLE sales DROP PARTITION FOR ('01-FEB-1999');
--� ��� ��������� ������ ����� ����� ������ �� �������������
--� ������ ��� ������ ������� ��� ������ ������������ � ��������
--� "������� ������ � ������� �� ���������� ��������"

--������� ������ (����� HWM)
ALTER TABLE sales TRUNCATE PARTITION sales_99q1;
-----------------------------------------------
--��� ��������������� ����� ��������� �� user_part_tables:
select partitioning_type
from user_part_tables
where table_name = 'ST_FT_ECP_PAF_CARR_SC_CDMA';
--------------------------------------
--������� ��������� ��������� �� ��� ��������, ���� ��� ����� ���������� �������. 
--����� ������ ����� �����, ���� ������ ������ ��� ��������� �������� ������ ����� ���������� �������
select partition_name
from user_segments
where segment_name = 'ST_FT_ECP_PAF_CARR_SC_CDMA';

----------------------------------------
--���� ���������� ��� ���������������� ��������
CALL DBMS_STATS.GATHER_TABLE_STATS(
ownname => 'DEMO', tabname => 'SALES',
partname => 'SALES_99Q1',
granularity => 'PARTITION');
CALL DBMS_STATS.GATHER_INDEX_STATS(
ownname => 'DEMO', indname => 'SALES_IDX',
partname => 'SALES_99Q1_IDX');
ANALYZE TABLE sales PARTITION (SALES_99Q1)
VALIDATE STRUCTURE INTO INVALID_ROWS;
--� ��� ���������������� �������� �������� ��������������
--���������� ��� ����� ��������, �� ������ � ���������
--� ������������ ���������� GRANULARITY
--� ALL, GLOBAL, DEFAULT, PARTITION, SUBPARTITION
--� �� �������� ���� ���������� GRANULARITY=ALL
---------������� �� ����������---------------
SELECT COUNT(*) FROM GMLD_XREF PARTITION(OPTION_CONTRACT_ALT_ID) G;
SELECT COUNT(*) FROM GMLD_XREF PARTITION(OPTION_UNDRLR_ALT_ID) G; 
--��� ��������-----
SELECT UPT.TABLE_NAME, 
       UPT.LAST_ANALYZED,--����� ��������� ��� ���������� ���������� 
       UPT.NUM_ROWS -- ���-�� ����� ������ �������� � count(*) �� ��������
,UPT.* FROM USER_TAB_PARTITIONS UPT
WHERE UPPER(UPT.TABLE_NAME) = 'GMLD_XREF'
AND UPT.PARTITION_NAME IN ('OPTION_CONTRACT_ALT_ID', 'OPTION_UNDRLR_ALT_ID'); 
--��� �������---
SELECT A.TABLE_NAME,
A.LAST_ANALYZED, 
A.* 
FROM ALL_TABLES A
WHERE A.OWNER = 'IRDS_OWNER'
AND A.TABLE_NAME = 'GMLD_XREF';
--��� �������� ��������-------
select ai.index_name, 
       ai.last_analyzed,
       ai.num_rows,
       ai.*  
from all_ind_partitions ai
where ai.index_owner = 'IRDS_OWNER'
and ai.index_name in ('UK_GMLD_XREF_ID_OBJECT', 'UK_GMLD_XREF_ROWID_OBJECT') 
and ai.partition_name in ('OPTION_CONTRACT_ALT_ID', 'OPTION_UNDRLR_ALT_ID');

--��� ��������-------
select i.index_name, 
       i.last_analyzed,
       i.num_rows,
       i.*  
from all_indexes i
where i.owner = 'IRDS_OWNER'
and i.index_name in ('UK_GMLD_XREF_ID_OBJECT', 'UK_GMLD_XREF_ROWID_OBJECT');

---------------------������� ���������������-----------------
CREATE TABLE ST_FT_ECP_PAF_CARR_SC_CDMA_P 
PARTITION BY RANGE (EPCS_ADATE)
INTERVAL (NUMTOYMINTERVAL(1,'month'))
(
  PARTITION P0001 VALUES LESS THAN (TO_DATE('2013-11-01','YYYY-MM-DD'))
)AS SELECT * FROM ST_FT_ECP_PAF_CARR_SC_CDMA;
--
drop table ST_FT_ECP_PAF_CARR_SC_CDMA;
--
rename ST_FT_ECP_PAF_CARR_SC_CDMA_P to ST_FT_ECP_PAF_CARR_SC_CDMA;
-----------------------------add partition and subpartition------------------------------
Because you have a template, adding partitions is transparent to subpartitions:

alter table your_table add partition mon_mar_2012 values less than (3000);
(This will automaticaly creates subpartitions for the new partition).

--EDIT: if you wouldn't have had template, you should have create subpartitions manualy:

ALTER TABLE your_table MODIFY PARTITION partition
      ADD SUBPARTITION subpartition_name ...
--------------SQL script to display partitions and their size for a given table-----------

--Using an inline view with a correlated subquery:
SELECT P.PARTITION_NAME, (  SELECT SUM(BYTES)/1024/1024/1024
                            FROM DBA_SEGMENTS S
                            WHERE S.PARTITION_NAME = P.PARTITION_NAME
                            AND SEGMENT_NAME='&&TABLE_NAME') "size GB"
FROM DBA_TAB_PARTITIONS P
WHERE P.TABLE_NAME = '&&TABLE_NAME'
ORDER BY P.PARTITION_POSITION ASC;


Example output:
sqlplus / as sysdba @get_size.sql
Enter value for table_name: ARCHIVED_DOCUMENTS


PARTITION_NAME                      size GB
------------------------------   ----------
DOKARCHIVE1                           2.875
DOKARCHIVE2                               3
DOKARCHIVE3                               3
DOKARCHIVE4                               3
DOKARCHIVE5                               3
DOKARCHIVE6                          2.8125
DOKARCHIVE7                            2.75      

------------------------------------------------------
Viewing Information About Partitioned Tables and Indexes
The following views display information specific to partitioned tables and indexes:

View	Description
DBA_PART_TABLES
ALL_PART_TABLES

USER_PART_TABLES

DBA view displays partitioning information for all partitioned tables in the database. ALL view displays partitioning information for all partitioned tables accessible to the user. USER view is restricted to partitioning information for partitioned tables owned by the user.
DBA_TAB_PARTITIONS
ALL_TAB_PARTITIONS

USER_TAB_PARTITIONS

Display partition-level partitioning information, partition storage parameters, and partition statistics generated by the DBMS_STATS package or the ANALYZE statement.
DBA_TAB_SUBPARTITIONS
ALL_TAB_SUBPARTITIONS

USER_TAB_SUBPARTITIONS

Display subpartition-level partitioning information, subpartition storage parameters, and subpartition statistics generated by the DBMS_STATS package or the ANALYZE statement.
DBA_PART_KEY_COLUMNS
ALL_PART_KEY_COLUMNS

USER_PART_KEY_COLUMNS

Display the partitioning key columns for partitioned tables.
DBA_SUBPART_KEY_COLUMNS
ALL_SUBPART_KEY_COLUMNS

USER_SUBPART_KEY_COLUMNS

Display the subpartitioning key columns for composite-partitioned tables (and local indexes on composite-partitioned tables).
DBA_PART_COL_STATISTICS
ALL_PART_COL_STATISTICS

USER_PART_COL_STATISTICS

Display column statistics and histogram information for the partitions of tables.
DBA_SUBPART_COL_STATISTICS
ALL_SUBPART_COL_STATISTICS

USER_SUBPART_COL_STATISTICS

Display column statistics and histogram information for subpartitions of tables.
DBA_PART_HISTOGRAMS
ALL_PART_HISTOGRAMS

USER_PART_HISTOGRAMS

Display the histogram data (end-points for each histogram) for histograms on table partitions.
DBA_SUBPART_HISTOGRAMS
ALL_SUBPART_HISTOGRAMS

USER_SUBPART_HISTOGRAMS

Display the histogram data (end-points for each histogram) for histograms on table subpartitions.
DBA_PART_INDEXES
ALL_PART_INDEXES

USER_PART_INDEXES

Display partitioning information for partitioned indexes.
DBA_IND_PARTITIONS
ALL_IND_PARTITIONS

USER_IND_PARTITIONS

Display the following for index partitions: partition-level partitioning information, storage parameters for the partition, statistics collected by the DBMS_STATS package or the ANALYZE statement.
DBA_IND_SUBPARTITIONS
ALL_IND_SUBPARTITIONS

USER_IND_SUBPARTITIONS

Display the following information for index subpartitions: partition-level partitioning information, storage parameters for the partition, statistics collected by the DBMS_STATS package or the ANALYZE statement.
DBA_SUBPARTITION_TEMPLATES
ALL_SUBPARTITION_TEMPLATES

USER_SUBPARTITION_TEMPLATES

Display information about existing subpartition templates.