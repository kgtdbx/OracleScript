 -------------------������� ���������� �� �������---------------
 begin    
  dbms_stats.gather_table_stats(user, 'ST_FT_ECP_PAF_CARR_SC_CDMA');
 end;
------------------
 analyze table t1 compute statistics for table for all indexes for all indexed columns;
 
 begin
 dbms_stats.gather_table_stats(ownname =>'BARS', tabname => 'OPER_ALL', method_opt=> 'FOR ALL INDEXED COLUMNS', degree=>4, cascade=>dbms_stats.auto_cascade, estimate_percent=>10);
end;

------------------ 
/*
���� ���������� ������������ ��� ������� "OFSAA1"."STG_LEDGER_STAT" � �� ��������
��������.
*/

-- ������������� ������� ���������� ������������ ��� ���� �������.
execute dbms_stats.gather_table_stats(ownname => 'OFSAA1', tabname =>
'STG_LEDGER_STAT', estimate_percent =>
DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE
AUTO');
----------------------------
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
-----
--�������� ������ ����� ���� ������ � �������������� ������ �������. 
Select bytes / blocks from dba_segments;

analyze table X compute statistics;
select  avg_space * blocks / 1024 /1024 as MB from dba_tables where table_name = 'X';
-----
SELECT a.owner "�����",
       a.TABLE_NAME "�������",
       b.bytes "������ (��)",
       TRUNC((a.blocks * 100) / b.blocks) "������(%)",
       b.extents "���������"
FROM sys.all_tables a,
     (
        SELECT owner, segment_name, SUM(bytes)/1024/1024 bytes,
               SUM(blocks) blocks, COUNT(*) extents
          FROM sys.dba_extents
         WHERE segment_type = 'TABLE'
      GROUP BY owner, segment_name
     ) b
WHERE a.owner = 'SB_DWH_TEST' AND a.TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA' AND
      a.owner = b.owner AND a.TABLE_NAME = b.segment_name;

--������ ������� (� �������������):
SELECT TABLE_NAME, ROUND((BLOCKS * 8)/1024, 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA';
--�������� ������:
SELECT TABLE_NAME, ROUND((NUM_ROWS * AVG_ROW_LEN / 1024 / 1024), 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ST_FT_ECP_PAF_CARR_SC_CDMA';

