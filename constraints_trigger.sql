SELECT u.index_name, u.column_name, u.*
FROM user_ind_columns u
WHERE table_name in ('STAFF$BASE', 'OPER');

select table_name, constraint_name, DEFERRABLE, DEFERRED, VALIDATED     
from user_constraints
where table_name in ('STAFF$BASE', 'OPER')
ORDER BY 1 ;



CREATE OR REPLACE FUNCTION ttt
return number
IS
BEGIN
        EXECUTE IMMEDIATE 'SET CONSTRAINTS ALL DEFERRED' ;
        return 0;
END ttt;

---------------
create sequence t1_seq start with 1 increment by 1 nomaxvalue; 

--Then create a trigger that increment upon insert:

create trigger t1_trigger
before insert on t1
for each row
   begin
     select t1_seq.nextval into :new.id from dual;
 end;
 
 -------------------
 --If you have the column and the sequence, you first need to populate a new key for all the existing rows. 
 --Assuming you don't care which key is assigned to which row

UPDATE table_name
   SET new_pk_column = sequence_name.nextval;

--Once that's done, you can create the primary key constraint (this assumes that either there is no existing primary key constraint or that you have already dropped the existing primary key constraint)

ALTER TABLE table_name
  ADD CONSTRAINT pk_table_name PRIMARY KEY( new_pk_column )
--If you want to generate the key automatically, you'd need to add a trigger

CREATE TRIGGER trigger_name
  BEFORE INSERT ON table_name
  FOR EACH ROW
BEGIN
  :new.new_pk_column := sequence_name.nextval;
END;
----------------------
--Use alter table to add column, for example:

alter table tableName add(columnName NUMBER);

--Then create a sequence:

CREATE SEQUENCE SEQ_ID
START WITH 1
INCREMENT BY 1
MAXVALUE 99999999
MINVALUE 1
NOCYCLE;
--and, the use update to insert values in column like this

UPDATE tableName SET columnName = seq_test_id.NEXTVAL

---------------
--There is no such thing as "auto_increment" or "identity" columns in Oracle. However, you can model it easily with a sequence and a trigger:

--Table definition:

CREATE TABLE departments (
  ID           NUMBER(10)    NOT NULL,
  DESCRIPTION  VARCHAR2(50)  NOT NULL);

ALTER TABLE departments ADD (
  CONSTRAINT dept_pk PRIMARY KEY (ID));

CREATE SEQUENCE dept_seq;
--Trigger definition:

CREATE TRIGGER trigger_name
  BEFORE INSERT ON table_name
  FOR EACH ROW
BEGIN
  :new.new_pk_column := sequence_name.nextval;
END;
/
