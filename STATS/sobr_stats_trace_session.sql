----------------------���������----------------------------
PROCEDURE p_analyze_trade_line(ip_num_of_processed in out number, ip_curr_row_num in out number, ip_curr_operation in varchar2) IS
BEGIN
  FOR c IN (SELECT /*' DBMS_STATS.gather_table_stats (user, ' ||*/ t.table_name /*||
                   ')'*/ psql
              FROM user_tables t
             WHERE t.table_name IN ('ETD_FUTURE_CONTRACT','ETD_FUTURE_CONTRACT'))
  LOOP
   -- EXECUTE IMMEDIATE (c.psql);
   DBMS_STATS.gather_table_stats (user, c.psql);
  END LOOP;
END p_analyze_trade_line;
------------------------------

/*
�������������� ����� ������������ ������ � ����. 
"�������������" - �������� �������� � ���� ������������ ������� SQL-���������� 
(� ����� ��������� ������������� �� ���������� - ����� ��������, 
�������� �������, ������� ����������� � ������.
����� ���������� ����������� - ���������� �������� ���� ��������� ����������, 
����� �������������� ����� ����� ���������� � �������� ���������. 
�������� ��� ���:
*/

alter system set timed_statistics=true

--���� ����������� ���������� � ������� ������, ����� ��� ������� �������� ���:
alter session set timed_statistics=true

/*
����� ���������� ���������,��� �������� max_dump_file_size, 
�������������� ������ ��������������� ����� ��������� � ���������� ������� ��������.
VALUE
-----------
UNLIMITED
*/

select value from v$parameter p
where name='max_dump_file_size'

/*
�������� ����� ����������� ������ ���������� ��� �� ������ ������ (alter session), 
��� � �� ������ ���� ������ (alter system). 
*/

/*
����� ���������� ��������� ���������������� ������, ������� ���� ������� ��������������,
� ��� ����� ���� ������ �������� �������� sid � serial# ���� ������:
*/

select sid,serial# from v$session
where --...���_��������_������...
/*
����������� ������ ���������� ����� ��������� ������� 10046 ��� ��������������� ������.
��� ����� ���� ��������� ��������� ��������� � �������� ��, ���������� �������� sid � serial#, 
� �������� ������������� ����������. 
� �������� �������, ��������������� ������������, 12�� �������, �����������. 
*/

begin
sys.dbms_system.set_ev(sid, serial#, 10046, 12, '');
end;

--����������� ����������� ���������� - ���������� ������� 10046 � ������� �������:
begin
sys.dbms_system.set_ev(sid, serial#, 10046, 0, '');
end;
/*
��������� ������ �����������:
0 - ����������� ���������.
1 - ����������� �������. ��������� �� ���������� �� ��������� ��������� sql_trace=true
4 - � ������������� ���� ����������� �������� ��������� ����������.
8 - � ������������� ���� ����������� �������� �������� ������� �� ������ ��������.
12 - ����������� ��� �������� ��������� ����������, ��� � ���������� �� ��������� �������.
� �� �� ����� � ������ ����������� ������� ������ (��� �������� sid � serial#):
*/
--��������:
alter session set events '10046 trace name context forever, level 12';
--���������:
alter session set events '10046 trace name context off';

/*
����� ��������������� ������������� ������ ��������� �����������.
�� � ����������� �� �������� ����� ���� ������ ��������������� ������� ��������� ��������� �����������.
�����. �������������� ���� � ����������� "�����" ����������� �������� � ��������� ����������:
*/
select value from v$parameter p
where name='user_dump_dest'

/*
VALUE
-------------------------------
C:\ORACLE\admin\databaseSID\udump
*/

/*
� ��� ����� ����� ����� � ���� ��������� ������������� �������� ������������ �������, 
� ������� ���� ����������� ����������� � ����� ���������� *.trc, 
������������� �������� ����� ������ ���:
*/

select p.spid from v$session s, v$process p
where s.paddr=p.addr
and --...���_��������_������...

/*
������ �������� ������������ �������� ������� �� ������������ �������. 
��, � �������, ���������� ���� ���� ����� ���: 
databaseSID_ora_2890.trc
*/
/*
� Oracle8i ��������� ����������� ���������� ������ ����� ��������������� ����� ��� ������� ������, 
����� �������� tracefile_identifier.
*/
alter session set tracefile_identifier='UniqueString'; 

/*
� �������. ��� ����, ����� ������������� "�����" ���������� � ��������� 
��� ������ ��������� ��� - �������������� ���� ���������� ���������� �������� tkprof.
*/
/*
C:\ORACLE\admin\databaseSID\udump>
C:\ORACLE\admin\databaseSID\udump>tkprof my_trace_file.trc output=my_file.prf
TKPROF: Release 9.2.0.1.0 - Production on Wed Sep 22 18:05:00 2004
Copyright (c) 1982, 2002, Oracle Corporation. All rights reserved.
C:\ORACLE\admin\databaseSID\udump>
*/

/*
� ����� my_file.prf ����� ������ ����������� ���� ������, 
������� ����������� � ������������ ������. 
� ����� ����� ������ ���������� ����������:)
*/

/*
��� ��������� ��������� ����������� ������, 
���������� �� ������� �� ���������/���������� 
(�� ���� ����� ��������� ��������� sql_trace=true/false, 
���������� sys.dbms_system.set_ev
��� ���������� alter session set events...) 
������������� ������������� ������������� V$PARAMETER � ����������� �����������.
*/
--������ ����� ����������� SYS.DBMS_SYSTEM.Read_Ev, ��������:
declare
 ALevel binary_integer;
begin
 SYS.DBMS_SYSTEM.Read_Ev(10046, ALevel);
 if ALevel = 0 then
   DBMS_OUTPUT.Put_Line('sql_trace is off');
 else
   DBMS_OUTPUT.Put_Line('sql_trace is on');
 end if;
end;

-->������������� ������������� ������������� V$PARAMETER � ����������� �����������.

--���� ��������� ������������� ������ x$ ��� ������ 10,11 (��� 8 - �� ��������, ��� 9 - �� ��������).

select a.ksppinm "Parameter",
b.ksppstvl "Session Value",
c.ksppstvl "Instance Value"
from x$ksppi a, x$ksppcv b, x$ksppsv c
where a.indx = b.indx
and a.indx = c.indx
and ksppinm = 'sql_trace'
order by a.ksppinm;


----------

begin
   
      dbms_stats.gather_table_stats (ownname            => NULL,
                                     tabname            => 'METER_INSTR_ALT_IDTFCN'--,
                                     --partname           => 'METER_INSTR_ALT_IDTFCN',
                                     --cascade            => TRUE,
                                     --granularity        => 'PARTITION',
                                     --no_invalidate      => FALSE,
                                     --estimate_percent => 10
                                     );

end;

--�������� ���������� �� �������:
begin
sys.dbms_stats.gather_table_stats('SB_DWH_TEST', 'ST_FT_ECP_PAF_CARR_SC_CDMA');
end;
��� 
exec sys.dbms_stats.gather_table_stats('SB_DWH_TEST', 'CUSTOMER_ITC_JBILL1');
exec dbms_stats.gather_table_stats('','T1');
---
begin
exec dbms_stats.set_index_stats(user, 'LRST_PK', clstfct => 100047);
end;
---
SELECT * FROM TABLE(dbms_xplan.display_cursor('7fbhgmmbjwtv9',0,'ALL IOSTATS LAST')); 
----------------------���������----------------------------
PROCEDURE p_analyze_trade_line(ip_num_of_processed in out number, ip_curr_row_num in out number, ip_curr_operation in varchar2) IS
BEGIN
  FOR c IN (SELECT /*' DBMS_STATS.gather_table_stats (user, ' ||*/ t.table_name /*||
                   ')'*/ psql
              FROM user_tables t
             WHERE t.table_name IN ('ETD_FUTURE_CONTRACT','ETD_FUTURE_CONTRACT'))
  LOOP
   -- EXECUTE IMMEDIATE (c.psql);
   DBMS_STATS.gather_table_stats (user, c.psql);
  END LOOP;
END p_analyze_trade_line;

-----------����������� ������� �� ����������-------
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
A.NUM_ROWS, 
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

