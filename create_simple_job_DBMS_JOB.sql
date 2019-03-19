--create simple job--

CREATE OR REPLACE PROCEDURE "GATHER_PNYDV_STATS" AS
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE=2147483647';
  EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE=2147483647';
  DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'PNYDV',method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO', CASCADE => TRUE);
END;
/

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    ( job       => X
     ,what      => 'GATHER_PNYDV_STATS;'
     ,next_date => to_date('24/11/2011 07:22:18','dd/mm/yyyy hh24:mi:ss')
     ,interval  => 'TRUNC(SYSDATE+7)+8/24'
     ,no_parse  => TRUE
    );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
END;
/ 
commit;


--########################--

--------------------------------------DBMS_JOB------------------------------

SELECT * FROM user_scheduler_jobs dj where dj.job_name = 'NOTIFICATION_JOB';
select TO_CHAR(d.LOG_DATE, 'dd.mm.yyyy hh24:mi:ss') LOG_DATE, d.* from user_scheduler_job_run_details d
order by d.LOG_ID desc;
select * from user_scheduler_job_log order by 1 desc;
select * from dba_jobs; 
select * from dba_jobs_running;
select * from dba_scheduler_running_jobs;
select * from DBA_SCHEDULER_JOBS d
where d.owner = 'BARS';
select * from DBA_SCHEDULER_JOB_LOG d
where d.owner = 'BARS';
select * from ALL_SCHEDULER_JOB_LOG l
order by l.LOG_ID desc;

select * from dba_jobs_running;

select * from user_jobs uj where uj.JOB IN('128932', '53848');

begin sys.dbms_job.broken(job => '128932',broken => true); commit; end;

--#############   One Time Immediate Job in Oracle  ###########--

One Time Immediate Job can be created by using "dbms_job" and "dbms_scheduler" both.

1) One Time Immediate Job using dbms_job
  declare
    l_jobid number := null;
  begin
    dbms_job.submit 
    (
      job       =>  l_jobid,
      what      =>  'sp_proc;',
      next_date =>  sysdate,
      interval  =>  null
    );
    commit;
  end;
  /

Always remember to issue a COMMIT statement immediately after dbms_job.submit. 


2) One Time Immediate Job using dbms_scheduler
  begin
    dbms_scheduler.create_job 
    (  
      job_name      =>  'One_Time_Job',  
      job_type      =>  'PLSQL_BLOCK',  
      job_action    =>  'begin sp_proc; end;',  
      start_date    =>  sysdate,  
      enabled       =>  TRUE,  
      auto_drop     =>  TRUE,  
      comments      =>  'one-time job');
  end;
  /
    commit;
    