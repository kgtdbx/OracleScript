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

EDIT: if you wouldn't have had template, you should have create subpartitions manualy:

ALTER TABLE your_table MODIFY PARTITION partition
      ADD SUBPARTITION subpartition_name ...
