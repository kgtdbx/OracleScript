--case one without using PRAGMA AUTONOMOUS_TRANSACTION
drop table t;

CREATE TABLE t (test_value VARCHAR2(25));

CREATE OR REPLACE PROCEDURE child_block IS
BEGIN
   INSERT INTO t(test_value)
   VALUES ('Child block insert');
  COMMIT; 
END child_block;

CREATE OR REPLACE PROCEDURE parent_block IS
BEGIN
   INSERT INTO t(test_value)
   VALUES('Parent block insert');

child_block;
ROLLBACK; 
END parent_block;
 /

 -- run the parent procedure
execute parent_block;

 -- check the results
SELECT * FROM t;
------------------------------------------------------------

--case 2  using PRAGMA AUTONOMOUS_TRANSACTION
--this mean the  PROCEDURE child_block is independent
CREATE OR REPLACE PROCEDURE child_block IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   INSERT INTO t(test_value)
   VALUES('Child block insert');
   COMMIT;
END child_block;


CREATE OR REPLACE PROCEDURE parent_block IS
BEGIN
   INSERT INTO t(test_value)
   VALUES('Parent block insert');

child_block;
ROLLBACK; 
END parent_block;
 
 -- empty the test table
TRUNCATE TABLE t;

 -- run the parent procedure
 exec parent_block;

 -- check the results
SELECT * FROM t; 