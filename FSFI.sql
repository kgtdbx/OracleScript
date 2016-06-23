/*��� ������ ������������ ���������� ������������ �������� ����������� �������� ������ ������ �������� ���������� ��������, 
���������� � ��������� �� ������ ���������� ����� (�.�. �� ������� �� ������ � ������). 
����� ���������� ��� ������� ���������� ������������ ���������� "�������� ������������ ���������� �����" 
(free space fragmentation index - FSFI).
*/

SELECT TABLESPACE_NAME,
  SQRT(MAX(BLOCKS)/SUM(BLOCKS))+
  (100/SQRT(SQRT(COUNT(BLOCKS)))) FSFI
FROM DBA_FREE_SPACE
GROUP BY TABLESPACE_NAME
ORDER BY 1;
-------------------------------------------
/*
� ��� ��� ����, ����� ���������� ������������� ��������� ��������� � �� �������, � ��� ��, 
����� ���������� ����� ������� �������� ��������� ����� ���������� ����������, ��������� ��������� ��������:
*/
select
      'free space' Owner,
      '   '  Object,
      File_ID,
      Block_ID,
      Blocks
 from DBA_FREE_SPACE
where Tablespace_Name = 'USERS'
--and Owner = 'SBOVKUSH'
union
select
      SUBSTR(Owner,1,20),
      SUBSTR(Segment_Name,1,32),
      File_ID,
      Block_ID,
      Blocks
 from DBA_EXTENTS
where Tablespace_Name = 'USERS'
and Owner = 'SBOVKUSH'
order by 3,4
