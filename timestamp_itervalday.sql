/*
2 � ��� ������������� ���������� ���������� ������������ SYSTIMESTAMP, � �� SYSDATE.
5 � ����� ������� ����� ������� ������ FF[1-9] ������������ ��� ������� ����� ������. 
���� �� ������� �������� ������ ��� ��� �������� � ��, 
Oracle ���������� ������� ���������� ���������� ������ ���������� ���������� ��� ����� � ��������� ������.
*/

declare
   v_ts TIMESTAMP(6):=systimestamp;
   v_tx VARCHAR2(2000);
begin
   v_tx:=to_char(v_ts,'HH24:MI:SS.FF6');
   DBMS_OUTPUT.put_line(v_tx);
end;

/*
2-3 � ���������� ������� CURRENT_TIMESTAMP ������������ ��� ������ TIMESTAMP � ���������� (����������) time zone, 
�� �� � time zone ���� ������.
6 � ������ TZR ���������� ���������� � time zone �������.
� ������������ �� �������� ��, �� ����� �� ���� ������������ ��� ������� � ����� � 
������� ����� ���������� time zone � UTC (��������� �����, ����� ����� �� ��������) ��� �������� �������.
8 � ���� �� ������ ������� ������ ������� �� ������� � ����� � ������� ����� ��������������� ����������� TZH � TZM.
*/
declare
   v_ts TIMESTAMP(6) WITH TIME ZONE :=CURRENT_TIMESTAMP;
   v_tx VARCHAR2(2000);
begin
   v_tx:=to_char(v_ts,'HH24:MI:SS.FF6 TZR');
   DBMS_OUTPUT.put_line(v_tx);
   v_tx:=to_char(v_ts,'TZH TZM');
   DBMS_OUTPUT.put_line(v_tx);
end;

---------------������ ������ ���������� ���� interval � to_char()----------------------
/*
��� ������ INTERVAL DAY TO SECOND ��������� ������� � �������������� ����������� ���� ����, �����, ����� � ������. 
� ���� ������, �������� ��� ���� ��������� ��� ������ ����� �������� ��� ��������, 
� �������� ��� ������ ���������� ����� �������� ��� �������� ����� ������.
*/

declare 
  l_int1 interval day(0) to second(0);
  l_int2 interval day(0) to second(0);  
begin
  l_int1 := to_dsinterval('0 23:12:00');
  l_int2 := to_dsinterval('0 00:59:00');  
  dbms_output.put_line(to_char(l_int1+l_int2,'hh:mi:ss'));
  dbms_output.put_line(extract(day   from l_int1+l_int2)
                ||':'||extract(hour   from l_int1+l_int2)                      
                ||':'||extract(minute from l_int1+l_int2));
end;
--------------------
create or replace function F_INTERVAL_TO_SECOND
(
int_DURATION interval day to second
)
return number
is
nSECOND number;
begin
nSECOND := to_number(extract(second from int_DURATION)) +
           to_number(extract(minute from int_DURATION)) * 60 +
           to_number(extract(hour from int_DURATION)) * 60 * 60 +
           to_number(extract(day from int_DURATION)) * 60 * 60* 24;
return(nSECOND);
end F_INTERVAL_TO_SECOND;