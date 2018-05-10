How to redefine a table that is created with an identity column
You have the following non-partitioned table defined:

CREATE TABLE MYTABLE
(
  ENTRY_SEQ_NUM        NUMBER Generated as Identity ( START WITH 1180965539 MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20 NOORDER NOKEEP) NOT NULL,
  ENTRY_ID             VARCHAR2(50 BYTE)            NULL,
  DOC_NAME             VARCHAR2(100 BYTE)           NULL,
  CREATED              TIMESTAMP(6)                 NULL,
  REVISION#            INTEGER                      NULL,
  APPLICABLE_YEAR      INTEGER                      NULL,
  PERIOD               VARCHAR2(10 BYTE)            NULL,
  DOCUMENT_STATUS      VARCHAR2(50 BYTE)            NULL,
  PHONE#               VARCHAR2(11 BYTE)            NULL
);

The table is growing, and your customer want it partitioned.

Solution:

Create an interim table. Make sure to use a datatype of NUMBER for the column ENTRY_SEQ_NUM, instead of the Identity column:
CREATE TABLE MYTABLE_INTERIM
(
  ENTRY_SEQ_NUM        NUMBER,
  ENTRY_ID             VARCHAR2(50 BYTE),
  DOC_NAME             VARCHAR2(100 BYTE)           NULL,
  CREATED              TIMESTAMP(6)                 NULL,
  REVISION#            INTEGER                      NULL,
  APPLICABLE_YEAR      INTEGER                      NULL,
  PERIOD               VARCHAR2(10 BYTE)            NULL,
  DOCUMENT_STATUS      VARCHAR2(50 BYTE)            NULL,
  PHONE#               VARCHAR2(11 BYTE)            NULL
)
PARTITION BY RANGE (PERIOD)
INTERVAL( NUMTOYMINTERVAL(1,'MONTH'))
(
  PARTITION P_INIT VALUES LESS THAN (TO_DATE('2013-01', 'YYYY-MM'))
)
TABLESPACE USERS
;

Start redefinition. Note that you need to use the TO_DATE function on the partition key column, together with proper masking of the date format string:

begin
DBMS_REDEFINITION.start_redef_table(uname=>'SCOTT',
orig_table=>'MYTABLE',
int_table=>'MYTABLE_INTERIM',
col_mapping =>'ENTRY_SEQ_NUM ENTRY_SEQ_NUM,ENTRY_ID ENTRY_ID,DOC_NAME DOC_NAME,CREATED CREATED,REVSION# REVSION#,APPLICABLE_YEAR APPLICABLE_YEAR,TO_DATE(PERIOD,''YYYY-MM'') PERIOD,DOCUMENT_STATUS DOCUMENT_STATUS,PHONE# PHONE#',
options_flag=>dbms_redefinition.cons_use_pk);
end;
/
Finish the redefinition:
begin
 DBMS_REDEFINITION.FINISH_REDEF_TABLE(uname=>'SCOTT',orig_table=>'MYTABLE',int_table=>'MYTABLE_INTERIM);
end;
/

Add a new column, of type "Identity":
alter session force parallel ddl;
alter session force parallel dml;
alter table mytable
add ENTRY_SEQ_NUM_X NUMBER Generated as Identity ( START WITH 1
                                                   MAXVALUE 9999999999999999999999999999 MINVALUE 1 NOCYCLE CACHE 20
                                                   NOORDER NOKEEP);

Drop the old column:
alter table mytable drop column ENTRY_SEQ_NUM;

Rename the Identity column back to the name of the column you just dropped:
alter table mytable rename column ENTRY_SEQ_NUM_X to ENTRY_SEQ_NUM;