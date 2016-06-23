----------------------процедура----------------------------
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
оттрассировать можно произвольную сессию в базе. 
"оттрасировать" - означает записать в файл операционной системы SQL-стейтменты 
(и также некоторую сопутствующую им информацию - планы запросов, 
ожидания событий, которые выполняются в сессии.
перед включением трассировки - необходимо включить сбор временной статистики, 
иначе трассировочные файлы будут появляться с нулевыми временами. 
делается это так:
*/

alter system set timed_statistics=true

--если трассировка включается в текущей сессии, тогда эта команда выглядит так:
alter session set timed_statistics=true

/*
также необходимо убедиться,что параметр max_dump_file_size, 
ограничивающий размер трассировочного файла выставлен в достаточно большое значение.
VALUE
-----------
UNLIMITED
*/

select value from v$parameter p
where name='max_dump_file_size'

/*
параметр можно динамически менять выставлять как на уровне сессии (alter session), 
так и на уровне базы данных (alter system). 
*/

/*
далее необходимо уникально идентифицировать сессию, которую есть желание оттрассировать,
а для этого надо узнать значения столбцов sid и serial# этой сессии:
*/

select sid,serial# from v$session
where --...мои_критерии_отбора...
/*
трассировка сессии включается через установку события 10046 для соответствующей сессии.
для этого надо запустить следующую процедуру и передать ей, полученные значения sid и serial#, 
в качестве целочисленных параметров. 
в качестве примера, устанавливается максимальный, 12ый уровень, трассировки. 
*/

begin
sys.dbms_system.set_ev(sid, serial#, 10046, 12, '');
end;

--выключается трассировка аналогично - установкой события 10046 в нулевой уровень:
begin
sys.dbms_system.set_ev(sid, serial#, 10046, 0, '');
end;
/*
возможные уровни трассировки:
0 - трассировка выключена.
1 - минимальный уровень. результат не отличается от установки параметра sql_trace=true
4 - в трасировочный файл добавляются значения связанных переменных.
8 - в трасировочный файл добавляются значения ожидании событий на уровне запросов.
12 - добавляется как значения связанных переменных, так и информация об ожиданиях событий.
и то же самое в случае трассировки текущей сессии (без указания sid и serial#):
*/
--включить:
alter session set events '10046 trace name context forever, level 12';
--выключить:
alter session set events '10046 trace name context off';

/*
здесь рассматривается универсальный способ включения трассировки.
но в зависимости от ситуации может быть удобно воспользоваться другими способами включения трассировки.
далее. трассировочный файл с накопленной "сырой" информацией появится в следующей директории:
*/
select value from v$parameter p
where name='user_dump_dest'

/*
VALUE
-------------------------------
C:\ORACLE\admin\databaseSID\udump
*/

/*
а имя этого файла будет в себе содержать идентификатор процесса операционной системы, 
в котором была установлена трассировка и иметь расширение *.trc, 
идентификатор процесса можно узнать так:
*/

select p.spid from v$session s, v$process p
where s.paddr=p.addr
and --...мои_критерии_отбора...

/*
точный алгоритм формирования названия зависит от операционной системы. 
но, к примеру, называться этот файл может так: 
databaseSID_ora_2890.trc
*/
/*
в Oracle8i появилась возможность установить формат имени трассировочного файла для текущей сессии, 
через параметр tracefile_identifier.
*/
alter session set tracefile_identifier='UniqueString'; 

/*
и наконец. для того, чтобы преобразовать "сырую" информацию в пригодный 
для чтения человеком вид - трассировочный файл необходимо обработать утилитой tkprof.
*/
/*
C:\ORACLE\admin\databaseSID\udump>
C:\ORACLE\admin\databaseSID\udump>tkprof my_trace_file.trc output=my_file.prf
TKPROF: Release 9.2.0.1.0 - Production on Wed Sep 22 18:05:00 2004
Copyright (c) 1982, 2002, Oracle Corporation. All rights reserved.
C:\ORACLE\admin\databaseSID\udump>
*/

/*
в файле my_file.prf будут тексты практически всех команд, 
которые выполнялись в трассируемой сессии. 
а также много другой интересной информации:)
*/

/*
Для получения состояния трассировки сессии, 
независимо от способа ее включения/выключения 
(то есть путем установки параметра sql_trace=true/false, 
процедурой sys.dbms_system.set_ev
или оператором alter session set events...) 
использование динамического представления V$PARAMETER и аналогичных неприменимо.
*/
--Вместо этого используйте SYS.DBMS_SYSTEM.Read_Ev, например:
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

-->использование динамического представления V$PARAMETER и аналогичных неприменимо.

--Зато применимо использование таблиц x$ для версий 10,11 (для 8 - не работает, для 9 - не проверял).

select a.ksppinm "Parameter",
b.ksppstvl "Session Value",
c.ksppstvl "Instance Value"
from x$ksppi a, x$ksppcv b, x$ksppsv c
where a.indx = b.indx
and a.indx = c.indx
and ksppinm = 'sql_trace'
order by a.ksppinm;
