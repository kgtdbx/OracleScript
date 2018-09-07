Generate AWR – Automatic Workload Repository (AWR) in oracle 11g
https://dbatricksworld.com/generate-awr-automatic-workload-repository-awr-in-oracle-11g/

Published 2 years ago by Jignesh Jethwa
Oracle 11g Logo


Many times DBA need to monitor specific loaded/heavy database related activity in order to fix database performance, for that generating AWR report is perfect solution and he will get all necessary information he needed to tune the database. This article is step by step approach to generate AWR report.

Step-I:

Before loaded activity, issue following command to take snapshot of database as start point of AWR report.

SQL> EXEC DBMS_WORKLOAD_REPOSITORY.create_snapshot;
Step-II: Perform your activity.

Perform your activity.

Step-III: Right after the activity, issue

Right after the activity, issue following command to take again snapshot of database as end point of AWR report.

EXEC DBMS_WORKLOAD_REPOSITORY.create_snapshot;
Note: Snapshot information can be queried from the DBA_HIST_SNAPSHOT view.

Step-IV:

Generate AWR report: (Follow the instructions and provide input acrrodingly)

SQL> @$ORACLE_HOME/rdbms/admin/awrrpti.sql

Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
Would you like an HTML report, or a plain text report?
Enter 'html' for an HTML report, or 'text' for plain text
Defaults to 'html'
Enter value for report_type: html
Type Specified: html
Select the appropriate instance:

Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DB Id Inst Num DB Name Instance Host
------------ -------- ------------ ------------ ------------
4119037639 1 PRODDB ifsprod localhost.lo
caldomain
4119037639 1 UATDB ifsuat localhost.lo
caldomain
* 4119037639 1 PRODDB ifsprod PR
Enter value for dbid: 4119037639
Enter value for inst_num: 1
Using 1 for instance number
Specify the number of days of snapshots to choose from:

Specify the number of days of snapshots to choose from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entering the number of days (n) will result in the most recent
(n) days of snapshots being listed. Pressing <return> without
specifying a number lists all completed snapshots.
Enter value for num_days: 1
Listing the last day's Completed Snapshots
Snap
Instance DB Name Snap Id Snap Started Level
------------ ------------ --------- ------------------ -----
ifsprod IFSPROD 66276 26 Nov 2016 00:00 1
66277 26 Nov 2016 00:30 1
66278 26 Nov 2016 01:01 1
66279 26 Nov 2016 01:30 1
66280 26 Nov 2016 02:00 1
66281 26 Nov 2016 02:30 1
66282 26 Nov 2016 03:00 1
66283 26 Nov 2016 03:30 1
66284 26 Nov 2016 04:00 1
66285 26 Nov 2016 04:30 1
66286 26 Nov 2016 05:00 1
66287 26 Nov 2016 05:30 1
66288 26 Nov 2016 06:00 1
66289 26 Nov 2016 06:31 1
66290 26 Nov 2016 07:00 1
66291 26 Nov 2016 07:30 1
66292 26 Nov 2016 08:00 1
66293 26 Nov 2016 08:30 1
66294 26 Nov 2016 09:00 1
66295 26 Nov 2016 09:30 1
66296 26 Nov 2016 10:00 1
66297 26 Nov 2016 10:30 1
66298 26 Nov 2016 11:00 1
66299 26 Nov 2016 11:30 1
66300 26 Nov 2016 12:00 1
66301 26 Nov 2016 12:30 1
66302 26 Nov 2016 13:00 1
66303 26 Nov 2016 13:30 1
66304 26 Nov 2016 14:00 1
66305 26 Nov 2016 14:30 1
66306 26 Nov 2016 14:41 1
66307 26 Nov 2016 14:45 1
Specify the Start point and end point for the snapshot, input from above:

Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter value for begin_snap: 66306
Begin Snapshot Id specified: 66306
Enter value for end_snap: 66307
End Snapshot Id specified: 66307
Name the report:

Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is awrrpt_1_66306_66307.html. To use this name,
press <return> to continue, otherwise enter an alternative.
Enter value for report_name: AWR_between_2_manual_snapshot
.
..
...
Report written to AWR_between_2_manual_snapshot
SQL> exit
search for html format snapshot in current directory.