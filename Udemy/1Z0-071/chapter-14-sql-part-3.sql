-- rename a column
CREATE TABLE XX_DEPT_TABLE
( DEPTNO NUMBER,
  DANAME VARCHAR2(100)
);

SELECT * FROM XX_DEPT_TABLE;

ALTER TABLE XX_DEPT_TABLE
RENAME column DANAME TO DEPT_NAME;

SELECT * FROM XX_DEPT_TABLE;

--rename the object ( table)

RENAME XX_DEPT_TABLE TO XX_DEPT_T;

SELECT * FROM XX_DEPT_T;

select * from XX_DEPT_TABLE;


