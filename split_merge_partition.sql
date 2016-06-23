select * /*+ first_rows*/ 
from accounts_update au 


SELECT TABLE_NAME, ROUND((BLOCKS * 8)/1024, 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ACCOUNTS_UPDATE';
--Реальные данные:
SELECT TABLE_NAME, ROUND((NUM_ROWS * AVG_ROW_LEN / 1024 / 1024), 0) "SIZE, Mb"  
  FROM USER_TABLES  
 WHERE TABLE_NAME = 'ACCOUNTS_UPDATE';

DECLARE
ip_table_name  varchar2(50)  DEFAULT  'ACCOUNTS_UPDATE';

begin
 execute immediate 'alter table '|| ip_table_name ||' enable row movement';
 execute immediate 'alter table '|| ip_table_name ||' shrink space cascade';
end;


alter table ARC_RRP MODIFY PARTITION ARCRRP_Y2014_Q2 enable row movement;
alter table ARC_RRP MODIFY PARTITION ARCRRP_Y2014_Q2 shrink space;

--################################################


-- перенести существующие партиции - получить набор запросов

select *-- 'alter table '||table_name||' move partition '||partition_name||' tablespace IMP_DATA;'

from all_tab_partitions  p where table_name = upper('SALDOA') 
and table_owner = 'BARS'
and partition_name <> 'SALDOA_Y2011_Q1'
and substr(partition_name, 6) >= 157 --or partition_name = 
--and p.high_value = 'TO_DATE('' 2009-01-07 00:00:00'', ''SYYYY-MM-DD HH24:MI:SS'', ''NLS_CALENDAR=GREGORIAN'')'
and tablespace_name = upper('BRSSALD') 
--and p.partition_name in ()

order by p.partition_position;

COLUMN high_value FORMAT A1000
select p.table_name,  p.partition_name, p.high_value
from all_tab_partitions  p where table_name = 'SALDOA'
and table_owner = 'BARS'
and tablespace_name = upper('BRSSALD') 
and p.partition_name <> 'P20090101'
order by p.partition_position
/

--информация по объектам БД-------
--user_, all_, dba_
--Информация о таблицах, в том числе и секционированных
select * from user_tables where table_name = upper('SALDOA') ;
--Информация о секционированных таблицах
select * from user_part_tables where table_name = upper('SALDOA') ;
select * from all_part_tables;
--Информация о табличных секциях
select * from user_tab_partitions;
--Информация о ключах секционирования
select * from user_part_key_columns;
--Информация о сегментах хранения, в том числе о секциях
select * from user_segments;
--Информация об объектах БД, в том числе о таблицах и секциях
select * from user_objects;
-------Информация о секционированных индексах
select * from user_IND_PARTITIONS p
where p.index_name = 'PK_SALDOA' ;

select * from User_Indexes ui
where ui.index_name = 'PK_SALDOA' ;

 /*
 alter table saldoa enable row movement;
 --------------------------------------------------
 alter table part
split partition p_1_qtr
at ( to_date( '01-02-2011', 'dd-mm-yyyy' ) )
into ( partition sys_p625, partition sys_p714 );
*/

 /*
 ALTER TABLE saldoa DROP PARTITIONS SYS_P53108;
 ALTER TABLE saldoa DROP PARTITIONS SYS_P53168;
 */
 
/*
ALTER TABLE ARC_RRP TRUNCATE PARTITION ARCRRP_Y2014_Q1;
*/

/*
ALTER TABLE saldoa ADD PARTITION saldoa_y2011_q1
VALUES LESS THAN (TO_DATE(' 2014-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND;
*/
/*
ALTER TABLE saldoa ADD PARTITION saldoa_max
VALUES LESS THAN (MAXVALUE) TABLESPACE BRSDYND;
*/
/*
 ALTER TABLE saldoa MERGE PARTITIONS SYS_P625, SYS_P714
 INTO PARTITION saldoa_y2015_m1 TABLESPACE BRSDYND;-- COMPRESS UPDATE GLOBAL INDEXES PARALLEL 4;
*/

----SYS_P625, SYS_P714, SYS_P8686, SYS_P626, SYS_P613, SYS_P612, SYS_P620, SYS_P621, SYS_P633, SYS_P627, SYS_P622, SYS_P698, SYS_P690, SYS_P695, SYS_P701, SYS_P702, SYS_P661, SYS_P699, SYS_P700

ALTER TABLE saldoa MERGE PARTITIONS  	SYS_P625, SYS_P714 				INTO PARTITION saldoa_y2011_q1;
ALTER TABLE saldoa MERGE PARTITIONS  	saldoa_y2011_q1,  SYS_P8686 	INTO PARTITION saldoa_y2011_qq1;
ALTER TABLE saldoa MERGE PARTITIONS 	saldoa_y2011_qq1, SYS_P626  	INTO PARTITION saldoa_y2011_qq2;
ALTER TABLE saldoa MERGE PARTITIONS 	saldoa_y2011_qq2, SYS_P613 		INTO PARTITION saldoa_y2011_qq3;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq3, SYS_P612		INTO PARTITION saldoa_y2011_qq4;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq4, SYS_P620		INTO PARTITION saldoa_y2011_qq1;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq1, SYS_P621 		INTO PARTITION saldoa_y2011_qq2;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq2, SYS_P633		INTO PARTITION saldoa_y2011_qq3;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq3, SYS_P627		INTO PARTITION saldoa_y2011_qq4;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq4, SYS_P622		INTO PARTITION saldoa_y2011_qq1;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq1, SYS_P698		INTO PARTITION saldoa_y2011_qq2;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq2, SYS_P690 		INTO PARTITION saldoa_y2011_qq3;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq3, SYS_P695 		INTO PARTITION saldoa_y2011_qq4;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq4, SYS_P701		INTO PARTITION saldoa_y2011_qq1;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq1, SYS_P702 		INTO PARTITION saldoa_y2011_qq2;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq2, SYS_P661		INTO PARTITION saldoa_y2011_qq3;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq3, SYS_P699		INTO PARTITION saldoa_y2011_qq4;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2011_qq4, SYS_P700 		INTO PARTITION saldoa_y2011_qq1;
  
 ALTER TABLE saldoa RENAME PARTITION saldoa_y2011_qq1 TO saldoa_y2011_m1;
 
 ALTER TABLE saldoa MODIFY PARTITION saldoa_y2011_m1 REBUILD UNUSABLE LOCAL INDEXES;
 
  select count(*) from saldoa partition (saldoa_y2011_m1)
 
 --------------------------------------------------
 ALTER TABLE saldoa MERGE PARTITIONS
 SYS_P705,SYS_P680,SYS_P696,SYS_P704,SYS_P678,SYS_P665,SYS_P667,SYS_P666,SYS_P668,SYS_P686,SYS_P687,SYS_P674,SYS_P673,SYS_P675,SYS_P676,SYS_P682,SYS_P683,SYS_P684,SYS_P691,SYS_P692,SYS_P685,SYS_P709,SYS_P713,SYS_P681,SYS_P697,SYS_P677,SYS_P669,SYS_P688,SYS_P689,SYS_P693,SYS_P703,SYS_P706,SYS_P707,SYS_P708,SYS_P710,SYS_P711,SYS_P712,SYS_P694,SYS_P663,SYS_P662,SYS_P664,SYS_P670,SYS_P671,SYS_P672,SYS_P679,SYS_P741,SYS_P730,SYS_P724,SYS_P725,SYS_P726,SYS_P727,SYS_P719,SYS_P738,SYS_P744,SYS_P720,SYS_P745,SYS_P731,SYS_P734,SYS_P739,SYS_P740,SYS_P735,SYS_P732,SYS_P733,SYS_P721,SYS_P737,SYS_P742,SYS_P743,SYS_P748,SYS_P749,SYS_P746,SYS_P752,SYS_P728,SYS_P715,SYS_P454,SYS_P391,SYS_P393,SYS_P394,SYS_P747,SYS_P722,SYS_P723,SYS_P716,SYS_P729,SYS_P750,SYS_P751,SYS_P718,SYS_P717,SYS_P736,SYS_P758,SYS_P761,SYS_P759,SYS_P760,SYS_P756,SYS_P757,SYS_P753,SYS_P754,SYS_P755,SYS_P792,SYS_P793,SYS_P794,SYS_P795,SYS_P796,SYS_P778,SYS_P797,SYS_P780,SYS_P770,SYS_P771,SYS_P772,SYS_P785,SYS_P786,SYS_P783,SYS_P784,SYS_P790,SYS_P791,SYS_P798,SYS_P802,SYS_P803,SYS_P804,SYS_P805,SYS_P808,SYS_P806,SYS_P809,SYS_P781,SYS_P779,SYS_P788,SYS_P773,SYS_P774,SYS_P775,SYS_P776,SYS_P782,SYS_P787,SYS_P789,SYS_P799,SYS_P800,SYS_P801,SYS_P807,SYS_P764,SYS_P765,SYS_P766,SYS_P767,SYS_P768,SYS_P769,SYS_P777,SYS_P813,SYS_P811,SYS_P812,SYS_P839,SYS_P815,SYS_P840,SYS_P841,SYS_P842,SYS_P843,SYS_P844,SYS_P845,SYS_P816,SYS_P817,SYS_P824,SYS_P833,SYS_P830,SYS_P834,SYS_P836,SYS_P846,SYS_P847,SYS_P848,SYS_P821,SYS_P849,SYS_P853,SYS_P831,SYS_P818,SYS_P837,SYS_P851,SYS_P823,SYS_P822,SYS_P835,SYS_P850,SYS_P819,SYS_P820,SYS_P854,SYS_P855,SYS_P856,SYS_P832,SYS_P825,SYS_P838,SYS_P810,SYS_P852,SYS_P827,SYS_P826,SYS_P828,SYS_P829,SYS_P814,SYS_P861,SYS_P860,SYS_P859,SYS_P857,SYS_P858,SYS_P915,SYS_P901,SYS_P904,SYS_P905,SYS_P891,SYS_P862,SYS_P895,SYS_P906,SYS_P907,SYS_P908,SYS_P870,SYS_P871,SYS_P902,SYS_P872,SYS_P865,SYS_P884,SYS_P866,SYS_P877,SYS_P885,SYS_P896,SYS_P897,SYS_P892,SYS_P881,SYS_P893,SYS_P894,SYS_P903,SYS_P913,SYS_P898,SYS_P867,SYS_P920,SYS_P912,SYS_P887,SYS_P868,SYS_P869,SYS_P873,SYS_P875,SYS_P874,SYS_P886
 INTO PARTITION saldoa_y2011_m2 TABLESPACE BRSDYND COMPRESS UPDATE GLOBAL INDEXES PARALLEL 4;
 
 --10507368
-- 32954
 select count(*) from saldoa partition (SYS_P53548)
 
 --------------------------------------------------
ALTER TABLE saldoa MERGE PARTITIONS  	SYS_P53108, SYS_P53168 			INTO PARTITION saldoa_y2015_m1;
ALTER TABLE saldoa MERGE PARTITIONS  	saldoa_y2015_m1,  SYS_P53228 	INTO PARTITION saldoa_y2015_m11;
ALTER TABLE saldoa MERGE PARTITIONS 	saldoa_y2015_m11, SYS_P53288  	INTO PARTITION saldoa_y2015_m12;
ALTER TABLE saldoa MERGE PARTITIONS 	saldoa_y2015_m12, SYS_P53448	INTO PARTITION saldoa_y2015_m13;

ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m13, SYS_P2925	INTO PARTITION saldoa_y2015_m14;
ALTER TABLE saldoa MERGE PARTITIONS		SYS_P2925, SYS_P53648	INTO PARTITION saldoa_y2015_m11;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m11, SYS_P53708	INTO PARTITION saldoa_y2015_m12;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m12, SYS_P53808	INTO PARTITION saldoa_y2015_m13;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m13, SYS_P53868	INTO PARTITION saldoa_y2015_m14;

--ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m14, SYS_P53948	INTO PARTITION saldoa_y2015_m11;

ALTER TABLE saldoa MERGE PARTITIONS		SYS_P53948, SYS_P53967	INTO PARTITION saldoa_y2015_m12;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m12, SYS_P54027	INTO PARTITION saldoa_y2015_m13;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m13, SYS_P54128	INTO PARTITION saldoa_y2015_m14;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m14, SYS_P54188	INTO PARTITION saldoa_y2015_m11;

--ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m11, SYS_P54288	INTO PARTITION saldoa_y2015_m12;
ALTER TABLE saldoa MERGE PARTITIONS		SYS_P54288, SYS_P54368	INTO PARTITION saldoa_y2015_m13;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m13, SYS_P54468	INTO PARTITION saldoa_y2015_m14;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m14, SYS_P54548    INTO PARTITION saldoa_y2015_m11;
ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m11, SYS_P54608    INTO PARTITION saldoa_y2015_m12;
--ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m12, SYS_P54670    INTO PARTITION saldoa_y2015_m13;

ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m1, saldoa_y2015_m2    INTO PARTITION saldoa_y2015_m12;

ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m12, saldoa_y2015_m3    INTO PARTITION saldoa_y2015_m13;

ALTER TABLE saldoa MERGE PARTITIONS		saldoa_y2015_m13, saldoa_y2015_m4    INTO PARTITION saldoa_y2015_m1;
 
 select count(*) from saldoa partition (saldoa_y2015_m13)
 
 ALTER TABLE saldoa MODIFY PARTITION saldoa_y2015_m13 REBUILD UNUSABLE LOCAL INDEXES;
 
  ALTER TABLE saldoa RENAME PARTITION SALDOA_Y2015_M1 TO SALDOA_Y2015_M11;
 


---------------------
 ALTER TABLE saldoa REBUILD UNUSABLE LOCAL INDEXES;
 
--перестроить индексы :
SELECT STATUS, INDEX_NAME FROM USER_INDEXES  
 WHERE TABLE_NAME = 'SALDOA';  
-- 
ALTER INDEX PK_SALDOA REBUILD COMPUTE STATISTICS;  
--ALTER INDEX PK_SALDOA REBUILD(_optimizer_compute_index_stats=true);  

 
 select * from user_indexes ui where ui.table_name = 'SALDOA'
 
 SELECT * FROM user_ind_partitions up where --
 up.partition_name = 'SYS_P53548' --up.index_name = 'PK_SALDOA'
 
 select *--partition_name
from user_segments
where segment_name = 'SALDOA';
 
 
 begin
  execute immediate 'begin bpa.alter_policy_info(''SALDOA_P53548'', ''WHOLE'',  null, ''E'', ''E'', ''E''); end;';
exception when others then
  if sqlcode = -06550 then null; else raise; end if;
end;
/
 
create table SALDOA_P53548
 as
 select * from saldoa partition (SYS_P53548)
 
  ALTER TABLE saldoa DROP PARTITION SYS_P53548;
  
  insert into saldoa (acc,fdat,pdat,ostf,dos ,kos ,trcn,ostq,dosq,kosq,kf)
    select acc,fdat,pdat,ostf,dos ,kos ,trcn,ostq,dosq,kosq,kf from SALDOA_P53548;
  
--select 68154937-8066 from dual

--8066
 select count(*) from saldoa partition (SYS_P53548)

--6452
  select count(*) from saldoa partition(SYS_P53648)
 
--32954
  select count(*) from saldoa partition(SALDOA_Y2015_M13)
  
  --8066
  select *--count(*) 
  from saldoa partition(SYS_P2925)
 ---------------***********************************************
 declare 
p_table varchar2(200):='SALDOA';
p_start_partition  varchar2(200):='saldoa_y2011_m1';

begin
  FOR CUR IN (select p.table_name,  partition_name
                      from all_tab_partitions  p where table_name = p_table
                      and table_owner = 'BARS'
                      and tablespace_name = upper('BRSSALD') 
                      and p.partition_name <> 'P20090101'
                      order by p.partition_position)
LOOP
  dbms_output.put_line( 'ALTER TABLE ' || cur.table_name||' MERGE PARTITIONS '|| cur.partition_name||' INTO PARTITION ');
END LOOP;
end; 
 
 ---------------***********************************************

--информация по объектам БД-------
--user_, all_, dba_
--Информация о таблицах, в том числе и секционированных
select * from user_tables where table_name = upper('OPER') ;
--Информация о секционированных таблицах
select * from user_part_tables where table_name = upper('OPER') ;
select * from all_part_tables;
--Информация о табличных секциях
select * from user_tab_partitions where table_name = upper('OPER') ;
--Информация о ключах секционирования
select * from user_part_key_columns;
--Информация о сегментах хранения, в том числе о секциях
select * from user_segments where segment_name = upper('OPER') ;
--Информация об объектах БД, в том числе о таблицах и секциях
select * from user_objects where object_name = upper('OPER') ;
-------Информация о секционированных индексах
select * from user_IND_PARTITIONS p
where p.partition_name in (select partition_name from user_tab_partitions where table_name = upper('OPER'))

select * from User_Indexes ui
where --ui.index_name = 'PK_OPLDOK' ;
ui.table_name = 'ARC_RRP' ;

CALL DBMS_STATS.GATHER_INDEX_STATS(
ownname => USER, indname => 'XIE_REFL_OPER');

ALTER TABLE OPLDOK MODIFY PARTITION OPLDOK_Y2014_Q1 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPLDOK MODIFY PARTITION OPLDOK_Y2014_Q2 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPLDOK MODIFY PARTITION OPLDOK_Y2014_Q3 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPLDOK MODIFY PARTITION OPLDOK_Y2014_Q4 REBUILD UNUSABLE LOCAL INDEXES;

 --OPER

ALTER TABLE OPER ADD PARTITION OPER_Y2016_Q1
VALUES LESS THAN (TO_DATE(' 2016-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPER ADD PARTITION OPER_Y2016_Q2
VALUES LESS THAN (TO_DATE(' 2016-07-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPER ADD PARTITION OPER_Y2016_Q3
VALUES LESS THAN (TO_DATE(' 2016-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPER ADD PARTITION OPER_Y2016_Q4
VALUES LESS THAN (TO_DATE(' 2017-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

XIE_PDAT_OPER

ALTER TABLE OPER MODIFY PARTITION OPER_Y2014_Q1 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPER MODIFY PARTITION OPER_Y2014_Q2 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPER MODIFY PARTITION OPER_Y2014_Q3 REBUILD UNUSABLE LOCAL INDEXES;
ALTER TABLE OPER MODIFY PARTITION OPER_Y2014_Q4 REBUILD UNUSABLE LOCAL INDEXES;

--OPLDOK

ALTER TABLE OPLDOK ADD PARTITION OPLDOK_Y2016_Q1
VALUES LESS THAN (TO_DATE(' 2016-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPLDOK ADD PARTITION OPLDOK_Y2016_Q2
VALUES LESS THAN (TO_DATE(' 2016-07-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPLDOK ADD PARTITION OPLDOK_Y2016_Q3
VALUES LESS THAN (TO_DATE(' 2016-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE OPLDOK ADD PARTITION OPLDOK_Y2016_Q4
VALUES LESS THAN (TO_DATE(' 2017-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

--ARC_RRP
ALTER TABLE ARC_RRP ADD PARTITION ARC_RRP_Y2016_Q1
VALUES LESS THAN (TO_DATE(' 2016-04-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE ARC_RRP ADD PARTITION ARC_RRP_Y2016_Q2
VALUES LESS THAN (TO_DATE(' 2016-07-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE ARC_RRP ADD PARTITION ARC_RRP_Y2016_Q3
VALUES LESS THAN (TO_DATE(' 2016-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;

ALTER TABLE ARC_RRP ADD PARTITION ARC_RRP_Y2016_Q4
VALUES LESS THAN (TO_DATE(' 2017-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
TABLESPACE BRSDYND UPDATE INDEXES;


 ALTER TABLE ARC_RRP RENAME PARTITION ARC_RRP_Y2016_Q4 TO ARCRRP_Y2016_Q4;
  
 ALTER INDEX PK_ARCRRP REBUILD COMPUTE STATISTICS;  
 
 --OPER_VISA
 
 
 ALTER TABLE ARC_RRP TRUNCATE PARTITION ARCRRP_Y2014_Q1;
 
 


