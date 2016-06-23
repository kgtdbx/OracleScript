/*
Требуется написать запрос, возвращающий для каждого абонента минимальную дату, 
когда количество событий было максимально, и максимальную дату, 
когда количество событий было минимально, а также количество событий.

Результат:
subscriber_name  min_date  max_event_cnt  max_date  min_event_cnt
Subscriber1      20091012  15             20061012  10
Subscriber2      20080301  20             20090513  8
*/

WITH dbo_call1 AS
(
SELECT 'Subscriber1' subscriber_name, '20091012' event_date, 15 event_cnt FROM dual
UNION 
SELECT 'Subscriber2' subscriber_name, '20080301' event_date, 20 event_cnt FROM dual
UNION
SELECT 'Subscriber1' subscriber_name, '20061012' event_date, 10 event_cnt FROM dual
UNION 
SELECT 'Subscriber2' subscriber_name, '20090513' event_date, 8 event_cnt FROM dual

UNION
SELECT 'Subscriber1' subscriber_name, '20101012' event_date, 15 event_cnt FROM dual
UNION 
SELECT 'Subscriber2' subscriber_name, '20080513' event_date, 8 event_cnt FROM dual
UNION
SELECT 'Subscriber1' subscriber_name, '20051012' event_date, 10 event_cnt FROM dual
UNION 
SELECT 'Subscriber2' subscriber_name, '20090513' event_date, 20 event_cnt FROM dual

UNION
SELECT 'Subscriber1' subscriber_name, '20061012' event_date, 13 event_cnt FROM dual
UNION 
SELECT 'Subscriber2' subscriber_name, '20090513' event_date, 14 event_cnt FROM dual
)
,
dbo_call2 AS
(
SELECT 
x.subscriber_name,
x.min_event_date,
x.max_event_cnt,
x.max_event_date,
x.min_event_cnt
FROM (
SELECT subscriber_name           subscriber_name, 
       FIRST_VALUE(event_date) OVER (PARTITION BY subscriber_name ORDER BY event_date) min_event_date,
       FIRST_VALUE(event_cnt) OVER (PARTITION BY subscriber_name ORDER BY event_cnt DESC)   max_event_cnt,
       FIRST_VALUE(event_date) OVER (PARTITION BY subscriber_name ORDER BY event_date DESC)      max_event_date,
       FIRST_VALUE(event_cnt) OVER (PARTITION BY subscriber_name ORDER BY event_cnt)       min_event_cnt
       
FROM dbo_call1 
)x
GROUP BY x.subscriber_name, x.min_event_date, x.max_event_cnt, x.max_event_date, x.min_event_cnt
ORDER BY x.subscriber_name
)
,
dbo_call3 AS
(
SELECT subscriber_name           subscriber_name, 
       (SELECT MIN(event_date) FROM dbo_call1 C1
        WHERE 1=1
        AND C1.event_cnt in (SELECT MAX(event_cnt) FROM dbo_call1 
                             WHERE 1=1 GROUP BY subscriber_name)
        AND C1.subscriber_name = C2.subscriber_name
        GROUP BY subscriber_name)min_event_date,
        (SELECT MAX(event_cnt) FROM dbo_call1 C3
        WHERE 1=1 
        AND C3.subscriber_name = C2.subscriber_name
        GROUP BY subscriber_name)max_event_cnt,
        (SELECT MAX(event_date) FROM dbo_call1 C4
        WHERE 1=1 
        AND C4.event_cnt in (SELECT MIN(event_cnt) FROM dbo_call1 
                             WHERE 1=1 GROUP BY subscriber_name)  
        AND C4.subscriber_name = C2.subscriber_name
        GROUP BY subscriber_name)max_event_date,
        (SELECT MIN(event_cnt) FROM dbo_call1 C5
        WHERE 1=1 
        AND C5.subscriber_name = C2.subscriber_name
        GROUP BY subscriber_name)min_event_cnt
        
FROM dbo_call1 C2 
WHERE  1=1
GROUP BY subscriber_name
)
,
dbo_call4 AS
(
SELECT subscriber_name           subscriber_name, 
       MIN(event_date)           min_event_date,
       event_cnt                 event_cnt
FROM dbo_call1 
WHERE  1=1
GROUP BY subscriber_name, event_cnt
HAVING event_cnt = (SELECT MAX(event_cnt) FROM dbo_call1)
)
,
dbo_call5 AS
(
SELECT MIN(event_cnt) FROM dbo_call1 
WHERE 1=1 GROUP BY subscriber_name
)

SELECT * FROM dbo_call2
