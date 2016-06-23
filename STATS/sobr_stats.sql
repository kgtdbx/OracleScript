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
