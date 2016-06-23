/*
����������
��������� ��������� � ��������� ������ ����� ������� - ������� ������ �������. ��� ������� ������ ����������� �������, � ���� ��� �������, �� ����������� Update, � ���� ��� - Insert. ������ ������ �������� ���� ������� � ������ Update, �� ������� ���� ���������� ���� ������.

�������� �������� DML!
*/
--���������

MERGE INTO TABLE_NAME 
USING table_reference ON (condition) WHEN MATCHED 
THEN UPDATE SET column1 = value1 [, column2 = value2 ...] WHEN NOT MATCHED 
THEN INSERT (column1 [, column2 ...]) VALUES (value1 [, value2 ...) ;


--�������� ������ ��������� MERGE �� �������
create table person(tabn number primary key, name varchar2(10), age number);
insert into person values (10 , '����', 22); -- ��������� ����� , ��� , �������
insert into person values (11 , '����', 9 );
insert into person values (12 , '����', 30);
insert into person values (13 , '����', 39);
insert into person values (14 , '����', 51);
insert into person values (15 , '����', 55);
insert into person values (16 , '����', 67);
insert into person values (17 , '����', 44);
insert into person values (18 , '����', 12);
insert into person values (19 , '����', 24);
insert into person values (20 , '����', 10);
insert into person values (21 , '����', 42)

--�������� ������� person1

create table Person1 as select * from Person;

--�� ��������� Person

--������� ����� ������� � Person � ������ ����� �� ��� ��� ������������ �������

UPDATE person SET age = 55 where tabn in (10,11,12,13,14,15);


delete person where tabn in (15,18,20);
UPDATE person SET age = 55 where tabn in (10,11,12,13,14,15);


--�������� ������� MERGE 
MERGE INTO person p
   USING (   SELECT tabn, name, age FROM person1) p1
   ON (p.tabn = p1.tabn)
   WHEN MATCHED THEN UPDATE SET p.age = p1.age     
     DELETE WHERE (p1.tabn = 18)
   WHEN NOT MATCHED THEN INSERT (p.tabn, p.name, p.age)
    VALUES (p1.tabn, p1.name, p1.age)

--������ � Person ����� ��������� � ��������� �������� �� Person1