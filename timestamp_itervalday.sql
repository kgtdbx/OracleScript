/*
2 — Для инициализации переменной необходимо использовать SYSTIMESTAMP, а не SYSDATE.
5 — новый элемент маски формата данных FF[1-9] предназначен для задания долей секунд. 
Если вы укажете точность меньше той что хранится в БД, 
Oracle использует технику округления результата выдачи идентичную округлению для чисел с плавающей точкой.
*/

declare
   v_ts TIMESTAMP(6):=systimestamp;
   v_tx VARCHAR2(2000);
begin
   v_tx:=to_char(v_ts,'HH24:MI:SS.FF6');
   DBMS_OUTPUT.put_line(v_tx);
end;

/*
2-3 — Встроенная функция CURRENT_TIMESTAMP поддерживает тип данных TIMESTAMP в сессионной (клиентской) time zone, 
но не в time zone базы данных.
6 — Формат TZR возвращает информацию о time zone региона.
В зависисмости от настроек БД, он может из себя представлять или разницу в часах и 
минутах между сессионной time zone и UTC (всемирное время, ранее время по Гринвичу) или название региона.
8 — Если вы хотите вернуть только разницу во времени в часах и минутах можно воспользоваться параметрами TZH и TZM.
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

---------------формат вывода переменной типа interval в to_char()----------------------
/*
Тип данных INTERVAL DAY TO SECOND позволяет хранить и манипулировать интервалами типа дней, часов, минут и секунд. 
В этом случае, точность для дней позволяет вам ввести число символов для хранения, 
и точность для секунд определяет число символов для хранения долей секунд.
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