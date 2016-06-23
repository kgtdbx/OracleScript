/*
Назначение
Позволяет дополнять и обновлять данные одной таблицы - данными другой таблицы. При слиянии таблиц проверяется условие, и если оно истинно, то выполняется Update, а если нет - Insert. Причем нельзя изменять поля таблицы в секции Update, по которым идет связывание двух таблиц.

Является командой DML!
*/
--Синтаксис

MERGE INTO TABLE_NAME 
USING table_reference ON (condition) WHEN MATCHED 
THEN UPDATE SET column1 = value1 [, column2 = value2 ...] WHEN NOT MATCHED 
THEN INSERT (column1 [, column2 ...]) VALUES (value1 [, value2 ...) ;


--Разберем работу оператора MERGE на примере
create table person(tabn number primary key, name varchar2(10), age number);
insert into person values (10 , 'Таня', 22); -- табельный номер , имя , возраст
insert into person values (11 , 'Саша', 9 );
insert into person values (12 , 'Вася', 30);
insert into person values (13 , 'Дима', 39);
insert into person values (14 , 'Олег', 51);
insert into person values (15 , 'Витя', 55);
insert into person values (16 , 'Лена', 67);
insert into person values (17 , 'Маня', 44);
insert into person values (18 , 'Даша', 12);
insert into person values (19 , 'Маша', 24);
insert into person values (20 , 'Миша', 10);
insert into person values (21 , 'Миша', 42)

--создадим таблицу person1

create table Person1 as select * from Person;

--на основании Person

--обновим часть записей в Person и удалим часть из них для актуальности примера

UPDATE person SET age = 55 where tabn in (10,11,12,13,14,15);


delete person where tabn in (15,18,20);
UPDATE person SET age = 55 where tabn in (10,11,12,13,14,15);


--Выполним команду MERGE 
MERGE INTO person p
   USING (   SELECT tabn, name, age FROM person1) p1
   ON (p.tabn = p1.tabn)
   WHEN MATCHED THEN UPDATE SET p.age = p1.age     
     DELETE WHERE (p1.tabn = 18)
   WHEN NOT MATCHED THEN INSERT (p.tabn, p.name, p.age)
    VALUES (p1.tabn, p1.name, p1.age)

--записи в Person будут обновлены и дополнены записями из Person1