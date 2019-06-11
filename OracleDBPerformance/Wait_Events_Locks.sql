Wait Events

--https://moreappsdba.blogspot.com/2017/08/wait-events.html


Waits  caused by I/O related performance issues:

db file sequential read
db file scattered read
direct path read
direct path read temp
direct path write temp
free buffer wait
log file sync

Scattered read /Sequential read:
A db file scattered read is the same type of event as "db file sequential read", except that Oracle will read multiple data blocks. Multi-block reads are typically used on full table scans.

db file scattered read => full table scan, index fast full scan
db file sequential read => index scan, table access by index rowid

db file sequential:
This event represents a wait for a physical read of a single Oracle block from the disk.
db file sequential read is a single block IO, most typically these comes from index range scans and table access by index rowid.


db file sequential reads:
Possible Causes:

Unselective index use.
Fragmented Indexes.
High I/O on a particular disk or mount point.
Bad application design.
Index reads performance can be affected by slow I/O subsystem and/or poor database files layout, which result in a higher average wait time

Action:

Check indexes on the table to ensure that the right index is being used
Check the column order of the index with the WHERE clause of the Top SQL statements
Rebuild indexes with a high clustering factor
Use partitioning to reduce the amount of blocks being visited
Make sure optimizer statistics are up to date
Relocate ‘hot’ datafiles
Consider the usage of multiple buffer pools and cache frequently used indexes/tables in the KEEP pool.
Inspect the execution plans of the SQL statements that access data through indexes
Is it appropriate for the SQL statements to access data through index lookups?
Is the application an online transaction processing (OLTP) or decision support system (DSS)?
Would full table scans be more efficient?
Do the statements use the right driving table?
The optimization goal is to minimize both the number of logical and physical I/Os.

db file scattered reads:
Possible Causes:
The Oracle session has requested and is waiting for multiple contiguous database blocks (up to DB_FILE_MULTIBLOCK_READ_COUNT) to be read into the SGA from disk.
Full Table scans
Fast Full Index Scans

Actions:
Optimize multi-block I/O by setting the parameter DB_FILE_MULTIBLOCK_READ_COUNT
Partition pruning to reduce number of blocks visited
Consider the usage of multiple buffer pools and cache frequently used indexes/tables in the KEEP pool
Optimize the SQL statement that initiated most of the waits. The goal is to minimize the number of physical and logical reads.
Should the statement access the data by a full table scan or index FFS?
Would an index range or unique scan be more efficient?
Does the query use the right driving table?
Are the SQL predicates appropriate for hash or merge join?
If full scans are appropriate, can parallel query improve the response time?
The objective is to reduce the demands for both the logical and physical I/Os, and this is best achieved through SQL and application tuning.
Make sure all statistics are representative of the actual data. Check the LAST_ANALYZED date

PL/SQL lock timer:

Wait event is called through the DBMSLOCK.SLEEP or USERLOCK.SLEEP procedure. This event will most likely originate from procedures written by a user.

SELECT vs.osuser,vw.event,vw.p1,vw.p2,vw.p3 ,vt.sql_text , vs.program
FROM gv$session_wait vw, gv$sqltext vt , gv$session vs
WHERE vw.event = 'PL/SQL lock timer'
AND vt.address=vs.sql_address
AND vs.inst_id = vw.inst_id
AND vs.sid = vw.sid;

Busy Buffer waits:
This means that the queries are waiting for the blocks to be read into the db cache.there could be reason when the block may be busy in the cache and session is waiting for it.It could be undo/data block or segment header wait.
Select p1 "File #",p2 "Block #",p3 "Reason Code" from v$session_wait Where event = 'buffer busy waits';

 Select owner, segment_name, segment_type from dba_extents Where file_id = &P1 and &P2 between block_id and block_id + blocks -1;


Possible Causes:
Buffer busy waits are common in an I/O-bound Oracle system.
The two main cases where this can occur are:
Another session is reading the block into the buffer
Another session holds the buffer in an incompatible mode to our request
These waits indicate read/read, read/write,or write/write contention.
The Oracle session is waiting to pin a buffer.
A buffer must be pinned before it can be read or modified. Only one process can pin a buffer at any one time.
This wait can be intensified by a large block size as more rows can be contained within the block
This wait happens when a session wants to access a database block in the buffer cache but it cannot as the buffer is "busy
It is also often due to several processes repeatedly reading the same blocks (eg: if lots of people scan the same index or datablock)

Actions:
The main way to reduce buffer busy waits is to reduce the total I/O on the system
Depending on the block type, the actions will differ

Data Blocks
Eliminate HOT blocks from the application.
Check for repeatedly scanned / unselective indexes.
Try rebuilding the object with a higher PCTFREE so that you reduce the number of rows per block.
Check for 'right- hand-indexes' (indexes that get inserted into at the same point by many processes).
Increase INITRANS and MAXTRANS and reduce PCTUSED This will make the table less dense .
Reduce the number of rows per block

Segment Header
Increase of number of FREELISTs and FREELIST GROUPs

Undo Header
Increase the number of Rollback Segments.

log file sync:

A user session issuing a commit command must wait until the LGWR (Log Writer) process writes the log entries associated with the user transaction to the log file on the disk. Oracle must commit the transaction’s entries to disk (because it is a persistent layer) before acknowledging the transaction commit. The log file sync wait event represents the time the session is waiting for the log buffers to be written to disk.

High “log file sync” can be observed in case of slow disk writes (LGWR takes long time to write), or because the application commit rate is very high. To identify a LGWR contention, examine the  “log file parallel write” background wait event

Possible Causes:
Oracle foreground processes are waiting for a COMMIT or ROLLBACK to complete.

Action:

Tune LGWR to get good throughput to disk eg: Do not put redo logs on RAID5
Reduce overall number of commits by batching transactions so that there are fewer distinct COMMIT operations

log file parallel write:

Possible Causes:
LGWR waits while writing contents of the redo log buffer cache to the online log files on disk
I/O wait on sub system holding the online redo log files

Action:

Reduce the amount of redo being generated
Do not leave tablespaces in hot backup mode for longer than necessary
Do not use RAID 5 for redo log files
Use faster disks for redo log files
Ensure that the disks holding the archived redo log files and the online redo log files are separate so as to avoid contention
Consider using NOLOGGING or UNRECOVERABLE options in SQL statements.

free buffer waits:

Free buffer wait occurs when a user session reads a block from the disk and cannot find a free block in the buffer cache to place it in. This event can be caused by inappropriate Oracle setting (such as buffer cache size is too small for the load running on the system) or the DBWR (Database Writer) is unable to keep up with writing dirty blocks to the disks, freeing the buffer cache. In cases where free buffer wait is one of the dominant wait event, it is recommended to examine the disk performance (using iostat, perfmon etc.) and pay special attention to the performance of small random writes.

Possible Causes:
This means we are waiting for a free buffer but there are none available in the cache because there are too many dirty buffers in the cache
Either the buffer cache is too small or the DBWR is slow in writing modified buffers to disk
DBWR is unable to keep up to the write requests
Checkpoints happening too fast – maybe due to high database activity and under-sized online redo log files
Large sorts and full table scans are filling the cache with modified blocks faster than the DBWR is able to write to disk
If the  number of dirty buffers that need to be written to disk is larger than the number that
DBWR can write per batch, then these waitscan be observed

Action:

Reduce checkpoint frequency  - increase the size of the online redo log files
Examine the size of the buffer cache – consider increasing the size of the buffer cache in the SGA
Set disk_asynch_io = true set
If not using asynchronous I/O increase the number of db writer processes or dbwr slaves
Ensure hot spots do not exist by spreading datafiles over disks and disk controllers
Pre-sorting or reorganizing data can help

Direct path read:
Direct path read is an access path in which multiple Oracle blocks are read directly to the Oracle process memory without being read into the buffer cache in the Shared Global Area (SGA). This event is usually caused by scanning an entire table, index, table partition, or index partition during Parallel Query execution (although 11g support “direct path read” on serial scans).

Direct path read temp and direct path write temp:

Similar to Direct path read the Direct path read temp is an access path in which multiple Oracle blocks are read directly to the Oracle process memory without being read into the buffer cache in the Shared Global Area (SGA). The main difference between the two access paths is the source of data: in Direct path read temp the data is read from temporary tablespaces. This event is usually caused by a sort operation that cannot be complete in memory and requires storage access.
Direct path write temp is an access path in which multiple Oracle blocks are written directly to the temporary files by the shadow Oracle process.

Shared pool latch:

Possible Causes:
The shared pool latch is used to protect critical operations when allocating and freeing memory in the shared pool.
Contentions for the shared pool and library cache latches are mainly due to intense hard parsing. A hard parse applies to new cursors and cursors that are aged out and must be re-executed.
The cost of parsing a new SQL statement is expensive both in terms of CPU requirements and the number of times the library cache and shared pool latches may need to be acquired and released.

Action:

Ways to reduce the shared pool latch are, avoid hard parses when possible, parse once, execute many.
Eliminating literal SQL is also useful to avoid the shared pool latch. The size of the shared_pool and use of MTS (shared server option) also greatly influences the shared pool latch.
The workaround is to set the initialization parameter CURSOR_SHARING to FORCE. This allows statements that differ in literal values but are otherwise identical to share a cursor and therefore reduce latch contention, memory usage, andhard parse.

log file switch waits: mean that your sessions are directly waiting for LGWR, let’s see what LGWR itself is doing, by running snapper for 30 seconds on LGWR.




Additional points:

sequential writes are faster than random writes (which is definitely true for mechanical disks). Oracle writes the log file sequentially, while data blocks are written randomly.