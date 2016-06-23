----------------------------столбцы потенциально пригодные для индексирования------------
SELECT * FROM (
SELECT c.owner,c.table_name, cc.column_name, cc.position column_position
FROM DBA_constraints c, DBA_cons_columns cc
WHERE c.constraint_name = cc.constraint_name
AND C.CONSTRAINT_TYPE = 'R'
and c.owner not in ('SYS','SYSMAN','SYSTEM') and c.owner='SB_DWH_TEST'
MINUS
SELECT i.owner,i.table_name, ic.column_name, ic.column_position
FROM DBA_indexes i, DBA_ind_columns ic
WHERE i.index_name = ic.index_name
)
ORDER BY table_name, column_position
------------------------------------------------------
/*
Use the SQL command CREATE INDEX to create an index.

In this example, an index is created for a single column, to speed up queries that test that column:
CREATE INDEX emp_ename ON emp_tab(ename);
--
In this example, several storage settings are explicitly specified for the index:
CREATE INDEX emp_ename ON emp_tab(ename)
    TABLESPACE users
    STORAGE (INITIAL     20K
             NEXT        20k
             PCTINCREASE 75)
             PCTFREE      0
             COMPUTE STATISTICS;
--
In this example, the index applies to two columns, to speed up queries that test either the first column or both columns:
CREATE INDEX emp_ename ON emp_tab(ename, empno) COMPUTE STATISTICS;
--
In this example, the query is going to sort on the function UPPER(ENAME). An index on the ENAME column itself would not speed up this operation, and it might be slow to call the function for each result row. A function-based index precomputes the result of the function for each column value, speeding up queries that use the function for searching or sorting:
CREATE INDEX emp_upper_ename ON emp_tab(UPPER(ename)) COMPUTE STATISTICS;
*/


CREATE INDEX IT_FT_CH_IDX
  ON SB_DWH_TEST.IT_FT_CHURN (CH_CL_ID)
  --TABLESPACE SB_DWH_TEST
  COMPUTE STATISTICS;
  
analyze index IT_FT_CH_IDX compute statistics;
или
Execute Immediate 'ALTER INDEX ' || Trim(R.INDEX_NAME) || ' REBUILD COMPUTE STATISTICS'; 
--индекс на основе функции---------
create index testdwh_upper_idx on testdwh(upper(last_name));
explain plan for
select * from sb_dwh_test.testdwh 
where upper(last_name) = 'BOVKUSH';
SELECT * FROM TABLE(dbms_xplan.display(NULL,NULL,'ALL')); 

---------------------Create a composite index on multiple columns---------------------------------------
/*
Принципиально,чтоб последовательность столбцов начиналась с первых полей в предикате после where. 
RTFM
Composite indexes can speed retrieval of data for SELECT statements in which the WHERE clause references all or the leading portion of the columns in the composite index. Therefore, the order of the columns used in the definition is important. Generally, the most commonly accessed or most selective columns go first.
Еще у b*tree-индексов есть опция compress, порядок столцов влияет на ее использование.
Если в составной индекс попадают null-значения полей, то порядок столбцов имеет влияние на размер индекса
*/

CREATE INDEX "IDX_DIVIDEND_FORECAST_02" ON "DIVIDEND_FORECAST" ("INDICES_LISTING_ID", "INDICES_ISSUE_ID") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
TABLESPACE "&&INDEX_TABLESPACE" ;

-------------------------------------------
/* INDEX RANGE SCAN - просмотр диапазона по индексу. Как оракл его выполняет? Для индекса на основе B* - дерева листовые блоки образуют двухсвязный список. Такая организация листовых блоков индекса при поиске позволяет не просматривать каждый раз всю индексную структуру сверху вниз, а достаточно спустившись один раз к необходимому начальному листовому блоку дальше двигаться по порядку только по листовым блокам.
Например, запрос select * from t where a between 10 and 100 с использованием метода INDEX RANGE SCAN выполняется легко и просто.
INDEX SKIP SCAN – поиск в индексе с пропусками. Такое сканирование используется в случаях, когда первый столбец составного индекса не входит в условия запроса. Другими словами, первый столбец пропускается (skipped) при выполнении этой операции.
Index Skip Scan использует разделение составного индекса на логические части (subindexes). Oracle определяет количество таких логических частей (subindexes) по числу неповторяющихся значений (distinct values) лидирующего столбца составного индекса. И если таких subindexes будет мало, оптимизатор предпочтет именно Index Skip Scan. Но если лидирующий столбец имеет много различных значений, то оптимизатор предпочтет TABLE FULL SCAN.
Например, запрос
 SELECT * FROM таблица WHERE  столбец2 = 'строка' 
при наличии составного индекса по столбцу1 и стобцу2, где столбец1 принимает значение 0 или 1, будет выполняться как запрос:
 SELECT * FROM таблица WHERE столбец1=0 and  столбец2 = 'строка'
UNION ALL
SELECT * FROM таблица WHERE  столбец1=1 and столбец2 = 'строка'
Иными словами выполняется поиск значений нелидирующих столбцов методом INDEX RANGE SCAN по каждому subindexes.
ORACLE имеет скрытый параметр _optimizer_skip_scan_enabled. Если хотите отключить метод индексного доступа INDEX SKIP SCAN , то установите его в false:
 alter session set "_optimizer_skip_scan_enabled"=false;
Просто на заметку:
index full scan - читается весь индекс в порядке сортировки строк в этом индексе.
index fast full scan - индекс используется как несортированная (heap) таблица.
*/