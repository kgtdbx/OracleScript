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

SELECT name, lcount
FROM user$
WHERE lcount <> 0;

--alter system for accept limit
alter system set resource_limit = true;
/
alter profile DEFAULT limit CPU_PER_CALL 300; --after 3 seconds process will kill
/