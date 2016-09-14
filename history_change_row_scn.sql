select versions_starttime, versions_endtime, salary
from emps
versions between scn minvalue and maxvalue
where emloyee_id = 141;