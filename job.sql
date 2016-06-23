select * from user_jobs;
SELECT * FROM user_scheduler_jobs;
select TO_CHAR(d.LOG_DATE, 'dd.mm.yyyy hh24:mi:ss') LOG_DATE, d.* from user_scheduler_job_run_details d
order by d.LOG_ID desc;
select * from user_scheduler_job_log order by 1 desc;
select * from dba_jobs; 
select * from dba_jobs_running;
select * from dba_scheduler_running_jobs;
select * from DBA_SCHEDULER_JOBS d
where d.owner = 'HIST_OWNER';
select * from DBA_SCHEDULER_JOB_LOG d
where d.owner = 'HIST_OWNER';
select * from ALL_SCHEDULER_JOB_LOG l
order by l.LOG_ID desc;
select * from dict where table_name like '%SCHEDULER_%';
SELECT * FROM user_SCHEDULER_CHAINS;
select * from user_SCHEDULER_RUNNING_JOBS;
SELECT * FROM user_SCHEDULER_RUNNING_CHAINS;
SELECT * FROM SYS.SCHEDULER$_EVENT_QUEUE;
---
SELECT owner, program_name, program_type, program_action
FROM all_scheduler_programs;

SELECT owner, program_name, enabled, comments
FROM all_scheduler_programs;

SELECT program_name, argument_name, argument_position, argument_type,
default_value
FROM all_scheduler_program_args;

select dbms_scheduler.stime+1 from dual;

SELECT attribute_name, value
FROM all_scheduler_global_attribute;

-- requires manage scheduler privilege 
BEGIN
  dbms_scheduler.set_scheduler_attribute('MAX_JOB_SLAVE_PROCESSES', 2);
END;
/
--Forces immediate evaluation of a running chain
BEGIN
dbms_scheduler.evaluate_running_chain('JOB_CLEANUP_RUN');
END;
/
-------------
SELECT dbms_scheduler.generate_job_name
FROM DUAL;

SELECT dbms_scheduler.generate_job_name('UW')
FROM DUAL;

--Список сведений об имеющихся программах для планировщика имеется в таблицах DBA/ALL/USER_SCHEDULER_PROGRAMS.
select * from USER_SCHEDULER_PROGRAMS;

--Список сведений об имеющихся расписаниях для планировщика имеется в таблицах DBA/ALL/USER_SCHEDULER_SCHEDULES
select * from USER_SCHEDULER_SCHEDULES;

--Список сведений об имеющихся заданиях для планировщика имеется в таблицах DBA/ALL/USER_SCHEDULER_SCHEDULES
SELECT * FROM USER_SCHEDULER_JOBS;
----------------
dbms_scheduler.create_calendar_string(
frequency        IN  PLS_INTEGER,
interval         IN  PLS_INTEGER,
bysecond         IN  bylist,
byminute         IN  bylist,
byhour           IN  bylist,
byday_days       IN  bylist,
byday_occurrence IN  bylist,
bymonthday       IN  bylist,
byyearday        IN  bylist,
byweekno         IN  bylist,
bymonth          IN  bylist,
calendar_string  OUT VARCHAR2);
-----------------CREATE_CHAIN-----------

--Creates a chain. Chains are created disabled and must be enabled before use.  

dbms_scheduler.create_chain(
chain_name          IN VARCHAR2,
rule_set_name       IN VARCHAR2 DEFAULT NULL,
evaluation_interval IN INTERVAL DAY TO SECOND DEFAULT NULL,
comments            IN VARCHAR2 DEFAULT NULL);
desc dba_scheduler_chains

SELECT owner, chain_name, rule_set_owner, rule_set_name, number_of_rules
FROM dba_scheduler_chains;

exec dbms_scheduler.create_chain('TEST_CHAIN');

SELECT owner, chain_name, rule_set_owner, rule_set_name, number_of_rules
FROM dba_scheduler_chains;

desc dba_scheduler_chain_steps

SELECT chain_name, step_name, program_name, step_type
FROM dba_scheduler_chain_steps;

BEGIN
  dbms_scheduler.define_chain_step('TEST_CHAIN', 'STEP1', 'PROGRAM1');
  dbms_scheduler.define_chain_step('TEST_CHAIN', 'STEP2', 'PROGRAM2');
END;
/

SELECT chain_name, step_name, program_name, event_schedule_name
FROM dba_scheduler_chain_steps;

BEGIN
  dbms_scheduler.define_chain_event_step('TEST_CHAIN','STEP2','SCHED1');
END;
/

SELECT chain_name, step_name, program_name, event_schedule_name
FROM dba_scheduler_chain_steps;

desc dba_scheduler_chain_rules

SELECT chain_name, rule_name, condition, action
FROM dba_scheduler_chain_rules;

BEGIN
  dbms_scheduler.define_chain_rule('TEST_CHAIN','TRUE', 
'START step1', 'step1_rule', 'begin chain run');

  dbms_scheduler.define_chain_rule('TEST_CHAIN', 'step1 completed',
'START step2', 'step2_rule');
END;
/

SELECT chain_name, rule_name, condition, action
FROM dba_scheduler_chain_rules;

exec dbms_scheduler.enable('TEST_CHAIN');

desc dba_scheduler_jobs

col job_name format a30
col job_type format a16
col job_action format a70
col repeat_interval format a28

SELECT job_name, job_type, job_action
FROM dba_scheduler_jobs;

BEGIN
  dbms_scheduler.create_job('JOB1', job_type => 'CHAIN', 
  job_action => 'TEST_CHAIN', 
  repeat_interval => 'freq=daily;byhour=22;byminute=30;bysecond=0',
  enabled => TRUE);
END;
/

SELECT job_name, job_type, job_action
FROM dba_scheduler_jobs;

BEGIN
  dbms_scheduler.alter_chain ('TEST_CHAIN', 'STEP1',
  attribute => 'SKIP', value => TRUE);
END;
/

BEGIN
  dbms_scheduler.run_chain('TEST_CHAIN', 'JOB1', start_steps =>
  'JOB_STEP1, JOB_STEP2');
END;
/

BEGIN
  dbms_scheduler.alter_running_chain ('TEST_CHAIN', 'JOB1', 'STEP2',
  attribute => 'PAUSE', value => TRUE);
END;
/

exec dbms_scheduler.drop_chain_rule('TEST_CHAIN', 'STEP1_RULE', TRUE);

exec dbms_scheduler.drop_chain_step('TEST_CHAIN', 'STEP2', TRUE);

exec dbms_scheduler.disable('TEST_CHAIN');

exec dbms_scheduler.drop_chain('TEST_CHAIN');


------------------------------------------
 BEGIN
     --DBMS_SCHEDULER.DISABLE('JOB_CLENUP_RUN', TRUE);
     --DBMS_SCHEDULER.DISABLE('PR_CLENUP', TRUE);
     --DBMS_SCHEDULER.DISABLE('PR_HISTORY', TRUE);
     --DBMS_SCHEDULER.DROP_JOB(Job_Name => 'JOB_CLENUP_RUN');
     --DBMS_SCHEDULER.DROP_SCHEDULE('SCH_HISTORY');
     --DBMS_SCHEDULER.DROP_SCHEDULE('SCH_CLENUP');
     --DBMS_SCHEDULER.DROP_PROGRAM('PR_HISTORY', force => TRUE);
     --DBMS_SCHEDULER.DROP_PROGRAM('PR_CLENUP', force => TRUE);
  END;

------------------GRANT-ты------------------------
BEGIN
DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE(DBMS_RULE_ADM.CREATE_RULE_OBJ, 'IRDS_HIST_DEV'),
DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE (
   DBMS_RULE_ADM.CREATE_RULE_SET_OBJ, 'IRDS_HIST_DEV'),
DBMS_RULE_ADM.GRANT_SYSTEM_PRIVILEGE (
   DBMS_RULE_ADM.CREATE_EVALUATION_CONTEXT_OBJ, 'IRDS_HIST_DEV')
END;
/

--------1. CREATE PROGRAM
--Returns the current time zone setting
--SELECT dbms_scheduler.get_sys_time_zone_name FROM DUAL;
BEGIN
DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('default_timezone','Europe/London');
END;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET time_zone = 'Europe/London';

BEGIN
      
      DBMS_SCHEDULER.CREATE_PROGRAM(program_name        => 'PR_CLEANUP',
                                    program_type        => 'STORED_PROCEDURE',
                                    program_action      => 'pkg_edge_hist.p_Parallel_Load',
                                    number_of_arguments => 4,
                                    enabled             => FALSE,
                                    comments            => 'Program to Cleanup History ' || '. Run Each Day.');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_CLEANUP',
                                             argument_name     => 'p_domain',
                                             argument_position => 1,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'IRDS');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_CLEANUP',
                                             argument_name     => 'p_replication_group',
                                             argument_position => 2,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'INDEX');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_CLEANUP',
                                             argument_name     => 'p_object_name',
                                             argument_position => 3,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => NULL);

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_CLEANUP',
                                             argument_name     => 'p_refresh_method',
                                             argument_position => 4,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'CLEANUP');

      DBMS_SCHEDULER.ENABLE(NAME => 'PR_CLEANUP');
END;      

--1.2.----------
BEGIN
      
      DBMS_SCHEDULER.CREATE_PROGRAM(program_name        => 'PR_HISTORY',
                                    program_type        => 'STORED_PROCEDURE',
                                    program_action      => 'pkg_edge_hist.p_Parallel_Load',
                                    number_of_arguments => 4,
                                    enabled             => FALSE,
                                    comments            => 'Program to Cleanup History ' || '. Run Each Day.');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_HISTORY',
                                             argument_name     => 'p_domain',
                                             argument_position => 1,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'IRDS');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_HISTORY',
                                             argument_name     => 'p_replication_group',
                                             argument_position => 2,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'INDEX');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_HISTORY',
                                             argument_name     => 'p_object_name',
                                             argument_position => 3,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => NULL);

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => 'PR_HISTORY',
                                             argument_name     => 'p_refresh_method',
                                             argument_position => 4,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'HISTORY');

      DBMS_SCHEDULER.ENABLE(NAME => 'PR_HISTORY');
END;

-------------------------2-----------
BEGIN
DBMS_SCHEDULER.CREATE_CHAIN (chain_name            =>  'my_chain1',
                             rule_set_name         =>  NULL,
                             evaluation_interval   =>  NULL, --INTERVAL '30' MINUTE,
                             comments              =>  NULL); --'Chain with 30 minute evaluation interval'
END;
--- define three steps for this chain. Referenced programs must be enabled.
BEGIN
DBMS_SCHEDULER.DEFINE_CHAIN_STEP(chain_name       => 'my_chain1',
                                 step_name        => 'stepA',
                                 program_name     => 'PR_HISTORY');

DBMS_SCHEDULER.DEFINE_CHAIN_STEP(chain_name       => 'my_chain1',
                                 step_name        => 'stepB',
                                 program_name     => 'PR_CLEANUP');
END;
--- define corresponding rules for the chain.
BEGIN
DBMS_SCHEDULER.DEFINE_CHAIN_RULE ( chain_name     => 'my_chain1',
                                   condition      => 'TRUE',
                                   action         => 'START stepA',
                                   rule_name      => 'stepA_rule',
                                   comments       => 'stepA_rule'
                                   );
DBMS_SCHEDULER.DEFINE_CHAIN_RULE ( chain_name     => 'my_chain1',
                                   condition      => 'stepA COMPLETED',
                                   action         => 'Start stepB',
                                   rule_name      => 'stepB_rule',
                                   comments       => 'stepB_rule'
                                   );
DBMS_SCHEDULER.DEFINE_CHAIN_RULE ( chain_name     => 'my_chain1',
                                   condition      => 'stepB COMPLETED',
                                   action         => 'END',
                                   rule_name      => 'stepC_rule',
                                   comments       => 'stepC_rule'
                                   );
END;
--- enable the chain
BEGIN
  DBMS_SCHEDULER.ENABLE('my_chain1');
END;
/
----3-------------------------------
BEGIN
DBMS_SCHEDULER.CREATE_SCHEDULE(schedule_name   => 'SCH_CLEANUP_RUN',
                               start_date      => systimestamp At TIME ZONE 'Europe/London' + INTERVAL '20' SECOND,
                               repeat_interval => 'FREQ=MINUTELY;INTERVAL=5',
                               end_date        => NULL,
                               comments        => 'Repeats MINUTELY.');
END;                                 
----4-------------------------------                                     
BEGIN
      DBMS_SCHEDULER.CREATE_JOB(job_name        => 'JOB_CLEANUP_RUN',
                                schedule_name   => 'SCH_CLEANUP_RUN',
                                job_type        => 'CHAIN',
                                job_action      => 'my_chain1',
                                --start_date      => systimestamp  At TIME ZONE 'Europe/London' + INTERVAL '20' SECOND,
                                --repeat_interval => 'freq=daily;byhour=15;byminute=20;bysecond=0',
                                --program_name    => 'PR_CLEANUP',
                                enabled         => TRUE,
                                comments        => 'Job for Cleanup History');
END;                                

--------------------END-----------------------
--SUPPORT

--DISABLE job
BEGIN
  DBMS_SCHEDULER.DISABLE('JOB_CLEANUP_RUN');
END;

--ENABLE job
BEGIN
  DBMS_SCHEDULER.ENABLE('JOB_CLEANUP_RUN');
END;
/

--stop job
BEGIN
  DBMS_SCHEDULER.STOP_JOB(job_name => 'JOB_CLEANUP_RUN',
                          force => true);
END;
/

--run job
BEGIN
  DBMS_SCHEDULER.RUN_JOB('JOB_CLEANUP_RUN');
END;
/
  

--удалить job-------
BEGIN
    DBMS_SCHEDULER.DROP_JOB('JOB_CLEANUP_RUN', TRUE); 
END;

--drop SCHEDULE job-------
BEGIN
    DBMS_SCHEDULER.DROP_SCHEDULE('SCH_CLEANUP_RUN'); 
END;

BEGIN 
  dbms_scheduler.disable('my_chain1');
END;

BEGIN 
   dbms_scheduler.drop_chain('my_chain1');
END;

BEGIN
  DBMS_SCHEDULER.DISABLE('PR_CLEANUP');
END;

BEGIN
     DBMS_SCHEDULER.DROP_PROGRAM('PR_HISTORY');
END;

BEGIN
     DBMS_SCHEDULER.DROP_PROGRAM('PR_CLEANUP');
END;

------------------END------------------------

BEGIN
dbms_scheduler.run_chain( chain_name            => 'my_chain1',
                          job_name              => 'JOB_CLEANUP_RUN',
                          start_steps           => 'stepA, stepB');
END;

BEGIN
dbms_scheduler.alter_chain (chain_name          => 'my_chain1', 
                            step_name           =>  'stepA',
                            attribute           => 'SKIP', 
                            value                => TRUE);
END;
/

BEGIN
  dbms_scheduler.alter_running_chain (job_name   => 'JOB_CLEANUP_RUN', 
                                      step_name  => 'stepA',
                                      attribute  => 'PAUSE', 
                                      value      => TRUE);
END;
/

exec dbms_scheduler.drop_chain_rule('my_chain1', 'stepA_rule', TRUE);

exec dbms_scheduler.drop_chain_step('my_chain1', 'stepA', TRUE);

exec dbms_scheduler.disable('my_chain1');

exec dbms_scheduler.drop_chain('my_chain1');

BEGIN
  DBMS_SCHEDULER.STOP_JOB('IRDS_HIST_DEV.JOB_HISTORY_RUN.stepA');
END;
/
----------------------------------
-- clean up
BEGIN
  -- stop the job
  BEGIN 
    dbms_scheduler.stop_job('UW_File_Load', TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  -- drop program argument
  dbms_scheduler.drop_program_argument('Run_LOAD_DATA', 1);
  dbms_scheduler.drop_program_argument('Run_LOAD_DATA', 2); 
  -- disable the program
  dbms_scheduler.disable('Run_LOAD_DATA', TRUE);
  -- drop the program
  dbms_scheduler.drop_program('Run_LOAD_DATA', TRUE);
  -- drop the job
  dbms_scheduler.drop_job('UW_File_Load', TRUE);
END;

---------------------------------

--DISABLE job
BEGIN
  DBMS_SCHEDULER.DISABLE('History_job');
END;
/

--ENABLE job
BEGIN
  DBMS_SCHEDULER.ENABLE('History_job');
END;
/

--stop job
BEGIN
  DBMS_SCHEDULER.STOP_JOB(job_name => 'JOB_CLEANUP_RUN',
                          force => true);
END;
/

--run job
BEGIN
  DBMS_SCHEDULER.RUN_JOB('History_job');
END;
/
  
-------------------------
/* This procedure e nds a detached job run. 
A detached job points to a detached program, which is a program with the detached attribute set to TRUE. 
A detached job run does not end until this procedure or the STOP_JOB Procedure is called. */
BEGIN
DBMS_SCHEDULER.END_DETACHED_JOB_RUN('JOB_CLEANUP_RUN');
END;

--- create a chain job to start the chain daily at 1:00 p.m.
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name        => 'chain_job_1',
   job_type        => 'CHAIN',
   job_action      => 'my_chain1',
   repeat_interval => 'freq=daily;byhour=13;byminute=0;bysecond=0',
   enabled         => TRUE);
END;
/


----------------------------------------
--Пример внутреннего задания в виде неименованного блока PL/SQL:
BEGIN
DBMS_SCHEDULER.CREATE_JOB 
( job_name   => 'simple_job'
, jobtype   => 'PLSQL_BLOCK'
, job_action => 'UPDATE emp SET sal = sal +1;'
, enabled   => TRUE
);
END;
/
-------------------------------------------
--Для хранимой процедуры задание формируется аналогично:

CREATE PROCEDURE updatesal AS BEGIN UPDATE emp SET sal = sal - 1; END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB
( job_name   => 'simple_job'
, jobtype   => 'STORED_PROCEDURE'
, job_action => 'updatesal'
, enabled   => TRUE
) ;
END;
/
------------------------------------------

--удалить job-------
EXECUTE   DBMS_SCHEDULER.DROP_JOB    (    'simple_job',    TRUE   ) 

---проверка когда будет запущен-----------
DECLARE   next_run_date   TIMESTAMP;
BEGIN
DBMS_SCHEDULER.EVALUATE_CALENDAR_STRING (
  'FREQ=DAILY;BYHOUR=2;BYMINUTE=45;BYSECOND=0'
, SYSTIMESTAMP
, NULL
, next_run_date
) ;
DBMS_OUTPUT.PUT_LINE ( 'next_run_date: ' || next_run_date );
END;

----------------------------
BEGIN
  -- Job defined entirely by the CREATE JOB procedure.
  DBMS_SCHEDULER.create_job (
    job_name        => 'test_full_job_definition',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN my_job_proc(''CREATE_PROGRAM (BLOCK)''); END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=hourly; byminute=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Job defined entirely by the CREATE JOB procedure.');
END;
/
BEGIN
  -- Job defined by an existing program and schedule.
  DBMS_SCHEDULER.create_job (
    job_name      => 'test_prog_sched_job_definition',
    program_name  => 'test_plsql_block_prog',
    schedule_name => 'test_hourly_schedule',
    enabled       => TRUE,
    comments      => 'Job defined by an existing program and schedule.');
END;
/
BEGIN
  -- Job defined by an existing program and inline schedule.
  DBMS_SCHEDULER.create_job (
    job_name        => 'test_prog_job_definition',
    program_name    => 'test_plsql_block_prog',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=hourly; byminute=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Job defined by existing program and inline schedule.');
END;
/
BEGIN
  -- Job defined by existing schedule and inline program.
  DBMS_SCHEDULER.create_job (
     job_name      => 'test_sched_job_definition',
     schedule_name => 'test_hourly_schedule',
     job_type      => 'PLSQL_BLOCK',
     job_action    => 'BEGIN my_job_proc(''CREATE_PROGRAM (BLOCK)''); END;',
     enabled       => TRUE,
     comments      => 'Job defined by existing schedule and inline program.');
END;
/
-----------------------------
PROCEDURE p_create_cleanup_job IS

  BEGIN

      DBMS_SCHEDULER.CREATE_PROGRAM(program_name        => c_program_prefix_name || 'cleanup',
                                    program_type        => 'STORED_PROCEDURE',
                                    program_action      => 'pkg_edge_hist.p_Parallel_Load',
                                    number_of_arguments => 4,
                                    enabled             => FALSE,
                                    comments            => 'Program to Cleanup History ' || '. Run Each Day.');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => c_program_prefix_name || 'cleanup',
                                             argument_name     => 'p_domain',
                                             argument_position => 1,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'IRDS');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => c_program_prefix_name || 'cleanup',
                                             argument_name     => 'p_replication_group',
                                             argument_position => 2,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'INDEX');

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => c_program_prefix_name || 'cleanup',
                                             argument_name     => 'p_object_name',
                                             argument_position => 3,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => NULL);

      DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(program_name      => c_program_prefix_name || 'cleanup',
                                             argument_name     => 'p_refresh_method',
                                             argument_position => 4,
                                             argument_type     => 'VARCHAR2',
                                             default_value     => 'CLEANUP');

      DBMS_SCHEDULER.ENABLE(NAME => c_program_prefix_name ||'cleanup');

      DBMS_SCHEDULER.CREATE_SCHEDULE(schedule_name   => c_schedule_prefix_name || 'cleanup',
                                     start_date      => systimestamp At TIME ZONE c_source_tz,
                                     repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
                                     end_date        => NULL,
                                     comments        => 'Repeats daily.');

      DBMS_SCHEDULER.CREATE_JOB(job_name      => c_job_prefix_name || 'cleanup',
                                program_name  => c_program_prefix_name || 'cleanup',
                                schedule_name => c_schedule_prefix_name || 'cleanup',
                                enabled       => TRUE,
                                comments      => 'Job for Cleanup History');
  END p_create_cleanup_job;

  PROCEDURE p_disable_cleanup_job IS
  BEGIN
      DBMS_SCHEDULER.DISABLE(c_job_prefix_name || 'cleanup', TRUE);
  END p_disable_cleanup_job;

  PROCEDURE p_enable_cleanup_job IS
  BEGIN
      DBMS_SCHEDULER.ENABLE(c_job_prefix_name || 'cleanup');
  END p_enable_cleanup_job;

  PROCEDURE p_drop_cleanup_job IS
  BEGIN
     DBMS_SCHEDULER.DROP_JOB(Job_Name => c_job_prefix_name || 'cleanup');
     DBMS_SCHEDULER.DROP_SCHEDULE(c_schedule_prefix_name || 'cleanup');
     DBMS_SCHEDULER.DROP_PROGRAM(c_program_prefix_name || 'cleanup');
  END p_drop_cleanup_job;

BEGIN
  -- Initialization
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE= ''AMERICAN'' NLS_TERRITORY= ''AMERICA''';
  
----------------------------Create a job class---------------------------------

SELECT job_class_name, resource_consumer_group, logging_level
FROm all_scheduler_job_classes;

BEGIN
  dbms_resource_manager.create_pending_area;
  dbms_resource_manager.create_consumer_group('Workers', 'Those that do actual work');
  dbms_resource_manager.submit_pending_area;

  dbms_scheduler.create_job_class('Cleanup_jobs', 'Workers');
END;
/


BEGIN
dbms_scheduler.drop_job_class(job_class_name => 'Cleanup_jobs',
                                    force => TRUE);
END;
/

BEGIN
  dbms_resource_manager.create_pending_area;
  dbms_resource_manager.delete_consumer_group('Workers');
  dbms_resource_manager.submit_pending_area;
END;
/

----------------------------Jobs That Raise Events------------------------------------------
BEGIN
   DBMS_SCHEDULER.add_event_queue_subscriber;
END;

BEGIN
    DBMS_SCHEDULER.create_job (
      job_name        => 'Cleanup_job',
      job_type        => 'PLSQL_BLOCK',
      job_action      => 'BEGIN pkg_edge_hist.p_parallel_load(''IRDS'', ''INDEX'', NULL, ''CLEANUP''); END;',
      start_date      => systimestamp At TIME ZONE 'Europe/London',
      --end_date        => SYSTIMESTAMP + (1/24), -- 1 hour
      repeat_interval => 'freq=minutely; bysecond=0',
      enabled         => TRUE);

  DBMS_SCHEDULER.set_attribute(
    name      => 'Cleanup_job',
    attribute => 'raise_events',
    value     => DBMS_SCHEDULER.job_succeeded);
END;
/


  DBMS_SCHEDULER.set_attribute(
    name      => 'Cleanup_job',
    attribute => 'raise_events',
    value     => DBMS_SCHEDULER.job_succeeded);
END;
/
----------------------------------------------------------

begin
DBMS_AQADM.CREATE_AQ_AGENT(agent_name=>'PWCDW2');
end;
/
GRANT EXECUTE ON SYS.DBMS_STREAMS_MESSAGING TO ''PWCDW2'';
GRANT EXECUTE ON SYS.DBMS_AQ TO ''PWCDW2'' ;
GRANT MANAGE ANY QUEUE TO ''PWCDW2'' ;
DECLARE
subscriber sys.aq$_agent;
BEGIN
DBMS_AQADM.CREATE_AQ_AGENT(agent_name => '''PWCDW2''');
subscriber := sys.aq$_agent('''PWCDW2''', '''SYS''.''SCHEDULER$_EVENT_QUEUE''', 0);
dbms_aqadm.add_subscriber(queue_name => '''SYS''.''SCHEDULER$_EVENT_QUEUE''', subscriber=> subscriber, rule=>  , transformation=> );
DBMS_AQADM.ENABLE_DB_ACCESS(agent_name => '''PWCDW2''', db_username => '''PWCDW2''');
END;

/*
This call both creates a subscription to the Scheduler event queue and 
grants the user permission to dequeue using the designated agent. 
The subscription is rule-based. 
The rule permits the user to see only events raised by jobs that the user owns, 
and filters out all other messages:
*/

BEGIN
   DBMS_SCHEDULER.add_event_queue_subscriber('my_agent');
END;


/*
Now, Cleanup_job_event is waiting for a message to arrive in sys.scheduler$_event_queue. 
It will dequeue it only if the condition in event_condition is true.
Create a one time job, History_job, and set its raise_events attribute to job_succeeded then enable it:
*/

BEGIN
   sys.DBMS_SCHEDULER.create_job (job_name     => 'IRDS_HIST_DEV.History_job',
                                  job_type     => 'PLSQL_BLOCK',
                                  job_action   => 'BEGIN pkg_edge_hist.p_parallel_load(''IRDS'', ''INDEX'', NULL, ''HISTORY''); END;',
                                  start_date   => SYSTIMESTAMP AT TIME ZONE 'Europe/London'+ INTERVAL '50' SECOND,
                                  auto_drop    => FALSE,
                                  enabled      => FALSE);
                                  

   DBMS_SCHEDULER.set_attribute ('IRDS_HIST_DEV.History_job', 'raise_events', dbms_scheduler.job_started + dbms_scheduler.job_succeeded + dbms_scheduler.job_failed + dbms_scheduler.job_broken + dbms_scheduler.job_completed + dbms_scheduler.job_stopped + dbms_scheduler.job_disabled);

   sys.DBMS_SCHEDULER.enable ('IRDS_HIST_DEV.History_job');
END;
/

--Create an event-based job, name it Cleanup_job_event for example, 
--that will run after the successful completion of another job named History_job:
BEGIN
   sys.DBMS_SCHEDULER.create_job (
      job_name          => 'IRDS_HIST_DEV.Cleanup_job_event',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN pkg_edge_hist.p_parallel_load(''IRDS'', ''INDEX'', NULL, ''CLEANUP''); END;',
      event_condition   => 'tab.user_data.object_owner = ''IRDS_HIST_DEV'' and tab.user_data.object_name = ''History_job'' and tab.user_data.event_type = ''JOB_SUCCEEDED''',
      queue_spec        => 'sys.scheduler$_event_queue, my_agent',
      enabled           => FALSE);
      
   DBMS_SCHEDULER.set_attribute ('IRDS_HIST_DEV.Cleanup_job_event', 'raise_events', dbms_scheduler.job_started + dbms_scheduler.job_succeeded + dbms_scheduler.job_failed + dbms_scheduler.job_broken + dbms_scheduler.job_completed + dbms_scheduler.job_stopped + dbms_scheduler.job_disabled);

   sys.DBMS_SCHEDULER.enable ('IRDS_HIST_DEV.Cleanup_job_event');
      
END;
/


/*
When MY_JOB executes, it will enqueue a message in sys.scheduler$_event_queue. 
This will trigger Cleanup_job_event to start executing.
*/

--support--
BEGIN
   DBMS_SCHEDULER.remove_event_queue_subscriber('my_agent');
END;


SELECT * FROM user_scheduler_jobs;

select job_name, program_name, state from user_scheduler_jobs order by job_name;

select JOB_NAME, program_name, event_queue_owner, event_queue_name, event_queue_agent 
from user_scheduler_jobs 
order by job_name;
----------------------------------------------------------
select TO_CHAR(d.LOG_DATE, 'dd.mm.yyyy hh24:mi:ss') LOG_DATE, d.* from user_scheduler_job_run_details d
order by d.LOG_ID desc;

BEGIN
  -- stop the job
  BEGIN 
    dbms_scheduler.stop_job('Cleanup_job', TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      raise;
  END;
END; 
--DISABLE job
BEGIN
  DBMS_SCHEDULER.DISABLE('Cleanup_job');
END;
/

--ENABLE job
BEGIN
  DBMS_SCHEDULER.ENABLE('Cleanup_job');
END;
/

--stop job
BEGIN
  DBMS_SCHEDULER.STOP_JOB(job_name => 'Cleanup_job',
                          force => true);
END;
/

--run job
BEGIN
  DBMS_SCHEDULER.RUN_JOB('Cleanup_job');
END;
--------------------
--удалить job-------
BEGIN
    DBMS_SCHEDULER.DROP_JOB('HISTORY_JOB', TRUE); 
END;
/
