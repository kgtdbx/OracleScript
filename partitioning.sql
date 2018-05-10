--информация по объектам БД-------
--user_, all_, dba_
--Информация о таблицах, в том числе и секционированных
select * from user_tables;
--Информация о секционированных таблицах
select * from user_part_tables;
select * from all_part_tables;
--Информация о табличных секциях
select * from user_tab_partitions;
--subpartitions-----------------
SELECT table_name, partition_name, subpartition_name, subpartition_position
FROM user_tab_subpartitions;
--Информация о ключах секционирования
select * from user_part_key_columns;
--Информация о сегментах хранения, в том числе о секциях
select * from user_segments;
--Информация об объектах БД, в том числе о таблицах и секциях
select * from user_objects;
-------Информация о секционированных индексах
select * from all_IND_PARTITIONS;
--------------------------------------
--Данные из секции могут быть выбраны непосредственно
SELECT * FROM sales PARTITION (sales_99q1);
--Более сложный пример со ссылкой на секцию
UPDATE sales PARTITION (sales_99q1) s 
SET s.promo_id = 494
WHERE s.amount_sold > 1000;
--Менее известен формат ассоциативной ссылки
--Выбираются строки из ВСЕЙ секции, в которую попадает указанное ключевое значение
SELECT * FROM sales PARTITION FOR('02-FEB-1999');
--DELETE строк из секции
DELETE sales PARTITION(sales_99q1) WHERE cust_id = 1;
--INSERT (с корректным ключем секционирования)
INSERT INTO sales PARTITION(sales_99q1) 
(prod_id, time_id) VALUES (1, '01-FEB-1999');
--UPDATE (не изменяющий ключ секционирования)
UPDATE sales PARTITION (sales_99q1)
SET promo_id = 494
WHERE amount_sold > 1000;
-----------Некоторые простые операции с секциями------------
--Переименование секции
ALTER TABLE sales RENAME PARTITION sales_99q2 TO sales_99h1;
--Удаление секции
----Возможно, данные перед удалением следует сохранить 
----Новые данные со старыми значениями ключей будут попадать в старшую секцию (если секция не последняя)
ALTER TABLE sales DROP PARTITION sales_99q1;

--В командах ALTER TABLE ссылка на конкретную секцию таблицы возможна не только по имени но и по значению ключа
ALTER TABLE sales DROP PARTITION FOR ('01-FEB-1999');
--• Для индексных секций такая форма ссылки не предусмотрена
--• Иногда это бывает удобным при ручных манипуляциях с секциями
--• "Удалить секцию с данными по четвертому кварталу"

--Очистка секции (сброс HWM)
ALTER TABLE sales TRUNCATE PARTITION sales_99q1;
-----------------------------------------------
--Тип секционирования можно проверить по user_part_tables:
select partitioning_type
from user_part_tables
where table_name = 'ST_FT_ECP_PAF_CARR_SC_CDMA';
--------------------------------------
--таблица физически разделена на два сегмента, хотя это целая логическая таблица. 
--Когда описан такой метод, база данных создаёт два табличных сегмента вместо одной монолитной таблицы
select partition_name
from user_segments
where segment_name = 'ST_FT_ECP_PAF_CARR_SC_CDMA';

----------------------------------------
--Сбор статистики для секционированных объектов
CALL DBMS_STATS.GATHER_TABLE_STATS(
ownname => 'DEMO', tabname => 'SALES',
partname => 'SALES_99Q1',
granularity => 'PARTITION');
CALL DBMS_STATS.GATHER_INDEX_STATS(
ownname => 'DEMO', indname => 'SALES_IDX',
partname => 'SALES_99Q1_IDX');
ANALYZE TABLE sales PARTITION (SALES_99Q1)
VALIDATE STRUCTURE INTO INVALID_ROWS;
--• Для секционированных объектов отдельно поддерживается
--статистика для самих объектов, их секций и подсекций
--• Регулируется параметром GRANULARITY
--• ALL, GLOBAL, DEFAULT, PARTITION, SUBPARTITION
--• На практике чаще используют GRANULARITY=ALL
---------собрана ли статистика---------------
SELECT COUNT(*) FROM GMLD_XREF PARTITION(OPTION_CONTRACT_ALT_ID) G;
SELECT COUNT(*) FROM GMLD_XREF PARTITION(OPTION_UNDRLR_ALT_ID) G; 
--для партиций-----
SELECT UPT.TABLE_NAME, 
       UPT.LAST_ANALYZED,--когда последний раз собиралась статистика 
       UPT.NUM_ROWS -- кол-во строк должно совпасть с count(*) по партиции
,UPT.* FROM USER_TAB_PARTITIONS UPT
WHERE UPPER(UPT.TABLE_NAME) = 'GMLD_XREF'
AND UPT.PARTITION_NAME IN ('OPTION_CONTRACT_ALT_ID', 'OPTION_UNDRLR_ALT_ID'); 
--для таблицы---
SELECT A.TABLE_NAME,
A.LAST_ANALYZED, 
A.* 
FROM ALL_TABLES A
WHERE A.OWNER = 'IRDS_OWNER'
AND A.TABLE_NAME = 'GMLD_XREF';
--для партиций индексов-------
select ai.index_name, 
       ai.last_analyzed,
       ai.num_rows,
       ai.*  
from all_ind_partitions ai
where ai.index_owner = 'IRDS_OWNER'
and ai.index_name in ('UK_GMLD_XREF_ID_OBJECT', 'UK_GMLD_XREF_ROWID_OBJECT') 
and ai.partition_name in ('OPTION_CONTRACT_ALT_ID', 'OPTION_UNDRLR_ALT_ID');

--для индексов-------
select i.index_name, 
       i.last_analyzed,
       i.num_rows,
       i.*  
from all_indexes i
where i.owner = 'IRDS_OWNER'
and i.index_name in ('UK_GMLD_XREF_ID_OBJECT', 'UK_GMLD_XREF_ROWID_OBJECT');

---------------------Процесс секционирования-----------------
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
