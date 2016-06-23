--show profile
select du.username, du.profile 
from dba_users du
where du.account_status = 'OPEN';

--For showing the specific profiles property
select * from dba_profiles
where profile='DEFAULT';

--profile attribute
select * from profile$;
--profile names
select * from profname$;

--alter system for accept limit
alter system set resource_limit = true;
/
alter profile DEFAULT limit CPU_PER_CALL 300; --after 3 seconds process will kill
/
--##################################################

CREATE PROFILE REPORT_USER LIMIT 
SESSIONS_PER_USER               UNLIMITED --The user can have any number of concurrent sessions.
CPU_PER_SESSION                   UNLIMITED --In a single session, the user can consume an unlimited amount of CPU time.
CPU_PER_CALL                         3000          --A single call made by the user cannot consume more than 30 seconds of CPU time.
CONNECT_TIME                        UNLIMITED -- (45) A single session cannot last for more than 45 minutes.
LOGICAL_READS_PER_SESSION UNLIMITED -- (DEFAULT) In a single session, the number of data blocks read from memory and disk is subject to the limit specified in the DEFAULT profile.
LOGICAL_READS_PER_CALL       UNLIMITED -- (1000) A single call made by the user cannot read more than 1000 data blocks from memory and disk. 
PRIVATE_SGA                           UNLIMITED -- (15K) A single session cannot allocate more than 15 kilobytes of memory in the SGA.
COMPOSITE_LIMIT                    UNLIMITED;-- (5000000) In a single session, the total resource cost cannot exceed 5 million service units. 

CREATE USER PROFILE_TEST
IDENTIFIED BY "PROFILE_TEST";
PROFILE REPORT_USER;
ACCOUNT UNLOCK;

GRANT CONNECT, RESOURCE TO PROFILE_TEST;
GRANT CREATE SESSION TO PROFILE_TEST;
--GRANT UNLIMITED TABLESPACE TO PROFILE_TEST;
GRANT SELECT ANY TABLE TO PROFILE_TEST;

ALTER PROFILE REPORT_USER LIMIT CPU_PER_CALL 150; 
ALTER USER PROFILE_TEST PROFILE  REPORT_USER;

DROP USER PROFILE_TEST;
DROP PROFILE REPORT_USER;
