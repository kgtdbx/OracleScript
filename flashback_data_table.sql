alter table TMP_REZ_OBESP23 enable row movement;

FLASHBACK TABLE TMP_REZ_OBESP23
  TO TIMESTAMP (SYSTIMESTAMP - INTERVAL '20' minute);
  
  --###########################################################
/*
  Flashback Table and Materialized View – not working together
I must say that I like Flashback features very much. This is very useful option and should be used more often. But sometimes you might hit some obstacles. One of them is Materialized view. When You want to issue FLASHBACK TABLE statement on table that has materialized view it does not work. 
Lets try:
*/
SQL> create table a_fb 
  2  (id number primary key, text char(200)) enable row movement;
Table created.

SQL> create materialized view log on a_fb with rowid;

--Materialized view log created.
--Now insert some data:
SQL> insert into a_fb select object_id, object_name
  2  from all_objects where rownum <= 100;
100 rows created.
SQL> commit;
Commit complete.
SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb;
GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  568668        258       1069        100                       
--ok. Lets insert more data and then try to flashback to above SCN.
SQL> insert into a_fb select object_id, object_name
  2  from all_objects where rownum <= 100
  3  and object_id not in(select id from a_fb);
100 rows created.
SQL> commit;
Commit complete.
SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb;
GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  568704        258       1257        200                       
And now flashback:
SQL> flashback table a_fb to scn 568668;
Flashback complete.

--It seems that Materialized view log is not a problem. Moreover when FLASHBACK TABLE is executed new rows are inserted to Materialized view log. You can check it issuing this select:
select count(*) from MLOG$_A_FB;

--Now lets try to create materialized view
SQL> create materialized view a_fb_mv
  2  REFRESH FAST ON COMMIT with rowid
  3  as
  4  select id, text, rowid a_rowid from a_fb;
Materialized view created.
SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb;
GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  568852        258       1069        100                       
--Lets add some data and roll back to that SCN
SQL> insert into a_fb select object_id, object_name
  2  from all_objects where rownum <= 100
  3  and object_id not in(select id from a_fb);
100 rows created.
SQL> commit;
Commit complete.

SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb;

  GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  568893        258       1257        200                       
Lets see what we have in Materialized view:
SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb_mv;
GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  568895        258       1257        200                       
Problem
Try to flashback:
SQL> flashback table a_fb to scn  568852;
flashback table a_fb to scn  568852
                *
ERROR at line 1:
ORA-08194: Flashback Table operation is not allowed on materialized views 
You cannot flashback table if there is materialized view defined on it. But materialized view log is not a problem. I must say that I do not see any reason for that. If materialized view log is generated during flashback operation why materialized view is not updated according to that log?
Workaround
This is quite simple. You just have to drop materialized view and issue flashback table statement:
SQL> drop materialized view a_fb_mv;
Materialized view dropped.
SQL> flashback table a_fb to scn  568852;
Flashback complete.
SQL> select sys.dbms_flashback.get_system_change_number,
  2  min(id), max(id), count(*)
  3  from a_fb;
GET_SYSTEM_CHANGE_NUMBER    MIN(ID)    MAX(ID)   COUNT(*)                       
------------------------ ---------- ---------- ----------                       
                  569009        258       1069        100                       
Now you need only to recreate dropped materialized view.  