DECLARE
su NUMBER;
sa NUMBER;
cp NUMBER;
allocated_bytes NUMBER;
used_bytes NUMBER;
total_bytes NUMBER;

BEGIN
      SELECT sum(bytes) INTO allocated_bytes FROM
      (
       SELECT table_name, segment_type, segment_name, bytes FROM
        (
          SELECT l.table_name,
                 s.segment_type,
                 s.segment_name,
                 s.bytes
          FROM user_segments s,
               user_lobs l
          WHERE l.table_name='METER_INSTR_ALT_IDTFCN'
          AND s.segment_name=l.segment_name
          UNION
          SELECT i.table_name,
                 s.segment_type,
                 s.segment_name,
                 s.bytes
          FROM user_segments s,
               user_indexes i
          WHERE i.table_name='METER_INSTR_ALT_IDTFCN'
          AND s.segment_name=i.index_name
          UNION
          SELECT t.table_name,
                 s.segment_type,
                 s.segment_name,
                 s.bytes
          FROM USER_SEGMENTS S,
               USER_TABLES T
          WHERE t.table_name='METER_INSTR_ALT_IDTFCN'
          AND s.segment_name=t.table_name
        )
      );

      dbms_space.object_space_usage('IRDS_PDM_DEV', 'METER_INSTR_ALT_IDTFCN', 'TABLE', NULL, su, sa, cp);

      used_bytes := su;
      total_bytes :=  allocated_bytes + su;

      dbms_output.put_line('Allocated Bytes: '||allocated_bytes/(1024*1024)|| ' MB');
      dbms_output.put_line('Used Bytes: '||used_bytes/(1024*1024)|| ' MB');
      dbms_output.put_line('Total Bytes: '||substr((total_bytes/(1024*1024)),1,6)|| ' MB');

END;
/

declare
        
        VAR1 number;
        VAR2 number;
        VAR3 number;
        VAR4 number;
        VAR5 number;
        VAR6 number;
        VAR7 number;
begin
   
   DBMS_OUTPUT.enable;
   
/*   SYS.dbms_space.unused_space('SGIX_DEV','STG_METER','TABLE',
                          VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7);*/
                          
dbms_space.unused_space
( segment_owner     => 'IRDS_PDM_DEV',
  segment_name      => 'METER_INSTR_ALT_IDTFCN',
  segment_type      =>'TABLE',
  --partition_name    => 'INDICES_ISSUE_ALT_IDTFCN',
  total_blocks      => VAR1,
  total_bytes       => VAR2,
  unused_blocks     => VAR3,
  unused_bytes      => VAR4,
  LAST_USED_EXTENT_FILE_ID => VAR5,
  LAST_USED_EXTENT_BLOCK_ID => VAR6,
  LAST_USED_BLOCK => VAR7 );
                          
   dbms_output.put_line('OBJECT_NAME       = SPACES');
   dbms_output.put_line('---------------------------');
   dbms_output.put_line('TOTAL_BLOCKS      = '||VAR1);
   dbms_output.put_line('TOTAL_BYTES       = '||VAR2);
   dbms_output.put_line('UNUSED_BLOCKS     = '||VAR3);
   dbms_output.put_line('UNUSED_BYTES      = '||VAR4);
   dbms_output.put_line('LAST_USED_EXTENT_FILE_ID  = '||VAR5);
   dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||VAR6);
   dbms_output.put_line('LAST_USED_BLOCK   = '||VAR7);
end;


select segment_name, sum(bytes)/1024/1024 size_mb 
from dba_extents
where owner = user
and segment_name in ('XREF_IDENTIFICATION','METER_INSTR_ALT_IDTFCN','BOND')
group by segment_name
order by sum(bytes)/1024/1024 desc;


select sum(bytes)/1024/1024 size_mb 
 from dba_free_space
 where tablespace_name = 'IRDS_DATA_DEV';
 
select segment_name,sum(bytes)/1024/1024 size_mb 
from dba_segments 
where owner= user 
and segment_name in ('XREF_IDENTIFICATION','METER_INSTR_ALT_IDTFCN','BOND')
group by segment_name
order by sum(bytes)/1024/1024 desc; 

alter table BOND deallocate unused keep 0;
alter index IDX_XREF_IDENTIFICATION_04 deallocate unused --keep 0;


alter table XREF_IDENTIFICATION coalesce;
alter index IDX_XREF_IDENTIFICATION_04 coalesce;
 
 
alter table XREF_IN_SUB_QUEUE_IDX 
modify partition P1 
coalesce subpartition;

alter table XREF_IDENTIFICATION 
modify partition INDICES_ISSUE_ALT_IDTFCN 
coalesce partition;

--################################################--
https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:5350053031470

--##########################--
set define off

create or replace procedure show_space
( p_segname in varchar2,
  p_owner   in varchar2 default user,
  p_type    in varchar2 default 'TABLE',
  p_partition in varchar2 default NULL )
-- this procedure uses authid current user so it can query DBA_*
-- views using privileges from a ROLE and so it can be installed
-- once per database, instead of once per user that wanted to use it
authid current_user
as
    l_free_blks                 number;
    l_total_blocks              number;
    l_total_bytes               number;
    l_unused_blocks             number;
    l_unused_bytes              number;
    l_LastUsedExtFileId         number;
    l_LastUsedExtBlockId        number;
    l_LAST_USED_BLOCK           number;
    l_segment_space_mgmt        varchar2(255);
    l_unformatted_blocks        number;
    l_unformatted_bytes         number;
    l_fs1_blocks                number; 
    l_fs1_bytes                 number;
    l_fs2_blocks                number; 
    l_fs2_bytes                 number;
    l_fs3_blocks                number; 
    l_fs3_bytes                 number;
    l_fs4_blocks                number; 
    l_fs4_bytes                 number;
    l_full_blocks               number; 
    l_full_bytes                number;

    -- inline procedure to print out numbers nicely formatted
    -- with a simple label
    procedure p( p_label in varchar2, p_num in number )
    is
    begin
        dbms_output.put_line( rpad(p_label,40,'.') ||
                              to_char(p_num,'999,999,999,999') );
    end;
begin
   -- this query is executed dynamically in order to allow this procedure
   -- to be created by a user who has access to DBA_SEGMENTS/TABLESPACES
   -- via a role as is customary.
   -- NOTE: at runtime, the invoker MUST have access to these two
   -- views!
   -- this query determines if the object is a ASSM object or not
   begin
      execute immediate
          'select ts.segment_space_management
             from dba_segments seg, dba_tablespaces ts
            where seg.segment_name = :p_segname
              and (:p_partition is null or
                  seg.partition_name = :p_partition)
              and seg.owner = :p_owner
              and seg.segment_type = :p_type
              and seg.tablespace_name = ts.tablespace_name'
             into l_segment_space_mgmt
            using p_segname, p_partition, p_partition, p_owner, p_type;
   exception
       when too_many_rows then
          dbms_output.put_line
          ( 'This must be a partitioned table, use p_partition => ');
          return;
   end;
   -- if the object is in an ASSM tablespace, we must use this API
   -- call to get space information, else we use the FREE_BLOCKS
   -- API for the user managed segments
   if l_segment_space_mgmt = 'AUTO'
   then
     dbms_space.space_usage
     ( p_owner, p_segname, p_type, l_unformatted_blocks,
       l_unformatted_bytes, l_fs1_blocks, l_fs1_bytes,
       l_fs2_blocks, l_fs2_bytes, l_fs3_blocks, l_fs3_bytes,
       l_fs4_blocks, l_fs4_bytes, l_full_blocks, l_full_bytes, p_partition);

     p( 'Unformatted Blocks ', l_unformatted_blocks );
     p( 'FS1 Blocks (0-25)  ', l_fs1_blocks );
     p( 'FS2 Blocks (25-50) ', l_fs2_blocks );
     p( 'FS3 Blocks (50-75) ', l_fs3_blocks );
     p( 'FS4 Blocks (75-100)', l_fs4_blocks );
     p( 'Full Blocks        ', l_full_blocks );
  else
     dbms_space.free_blocks(
       segment_owner     => p_owner,
       segment_name      => p_segname,
       segment_type      => p_type,
       freelist_group_id => 0,
       free_blks         => l_free_blks,
       partition_name    => p_partition);

     p( 'Free Blocks', l_free_blks );
  end if;

  -- and then the unused space API call to get the rest of the
  -- information
  dbms_space.unused_space
  ( segment_owner     => p_owner,
    segment_name      => p_segname,
    segment_type      => p_type,
    partition_name    => p_partition,
    total_blocks      => l_total_blocks,
    total_bytes       => l_total_bytes,
    unused_blocks     => l_unused_blocks,
    unused_bytes      => l_unused_bytes,
    LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId,
    LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId,
    LAST_USED_BLOCK => l_LAST_USED_BLOCK );

    p( 'Total Blocks', l_total_blocks );
    p( 'Total Bytes', l_total_bytes );
    p( 'Total MBytes', trunc(l_total_bytes/1024/1024) );
    p( 'Unused Blocks', l_unused_blocks );
    p( 'Unused Bytes', l_unused_bytes );
    p( 'Last Used Ext FileId', l_LastUsedExtFileId );
    p( 'Last Used Ext BlockId', l_LastUsedExtBlockId );
    p( 'Last Used Block', l_LAST_USED_BLOCK );
end;
/
set define on

June 16, 2010 - 9:11 pm UTC

Reviewer: A reader

Missed out another join condition segment_type = :p_type
Space
August 10, 2010 - 4:24 pm UTC

Reviewer: Andrew from NY/NY

Tom, this is not showing the space used by table _and_ by it's indexes, correct?
Do you think you can quickly add this functionality %) ?

Thank you.
Andrew
Tom Kyte
Followup  

August 18, 2010 - 11:33 pm UTC 

it shows the space used by a SEGMENT.

If you want it to do more - then just call it for each SEGMENT in question - write a small loop that iterates over the segments you find relevant and calls it. Not very hard.


Index Segment Space Usage
October 30, 2012 - 5:11 pm UTC

Reviewer: A reader

In the example below, after every record in the table is deleted, why are there 26 FS2 blocks? Shouldn't there be 26 FS4 blocks instead since all index entries were removed? 

SQL> 
SQL> create or replace procedure show_space
  2  ( p_segname in varchar2,
  3    p_owner   in varchar2 default user,
  4    p_type    in varchar2 default 'TABLE',
  5    p_partition in varchar2 default NULL )
  6  authid current_user
  7  as
  8     l_segment_space_mgmt        VARCHAR2(255);
  9     l_free_blks                 number;
 10     l_total_blocks              number;
 11     l_total_bytes               number;
 12     l_unused_blocks             number;
 13     l_unused_bytes              number;
 14     l_LastUsedExtFileId         number;
 15     l_LastUsedExtBlockId        number;
 16     l_LAST_USED_BLOCK           number;
 17     l_unformatted_blocks        number;
 18     l_unformatted_bytes         number;
 19     l_fs1_blocks                number;
 20     l_fs1_bytes                 number;
 21     l_fs2_blocks                number;
 22     l_fs2_bytes                 number;
 23     l_fs3_blocks                number;
 24     l_fs3_bytes                 number;
 25     l_fs4_blocks                number;
 26     l_fs4_bytes                 number;
 27     l_full_blocks               number;
 28     l_full_bytes                number;
 29  
 30      procedure p( p_label in varchar2, p_num in number )
 31      is
 32      begin
 33          dbms_output.put_line( rpad(p_label,40,'.') ||
 34                                p_num );
 35      end;
 36  
 37  begin
 38     begin
 39        execute immediate
 40            'select ts.segment_space_management
 41               from dba_segments seg, dba_tablespaces ts
 42              where seg.segment_name      = :p_segName
 43                and (:p_partition is null or
 44                    seg.partition_name = :p_partition)
 45                and seg.owner = :p_owner
 46                and seg.tablespace_name = ts.tablespace_name'
 47               into l_segment_space_mgmt
 48              using p_segName, p_partition, p_partition, p_owner;
 49     exception
 50         when too_many_rows then
 51            dbms_output.put_line
 52            ( 'This must be a partitioned table, use p_partition => ');
 53            return;
 54     end;
 55  
 56  
 57     if l_segment_space_mgmt = 'AUTO'
 58     then
 59       dbms_space.space_usage
 60       ( p_owner, p_segName, p_type, l_unformatted_blocks,
 61         l_unformatted_bytes, l_fs1_blocks, l_fs1_bytes,
 62         l_fs2_blocks, l_fs2_bytes, l_fs3_blocks, l_fs3_bytes,
 63         l_fs4_blocks, l_fs4_bytes, l_full_blocks, l_full_bytes, p_partition);
 64  
 65    else
 66       dbms_space.free_blocks(
 67         segment_owner     => p_owner,
 68         segment_name      => p_segName,
 69         segment_type      => p_type,
 70         freelist_group_id => 0,
 71         free_blks         => l_free_blks);
 72  
 73    end if;
 74  
 75    dbms_space.unused_space
 76    ( segment_owner     => p_owner,
 77      segment_name      => p_segName,
 78      segment_type      => p_type,
 79      partition_name    => p_partition,
 80      total_blocks      => l_total_blocks,
 81      total_bytes       => l_total_bytes,
 82      unused_blocks     => l_unused_blocks,
 83      unused_bytes      => l_unused_bytes,
 84      LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId,
 85      LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId,
 86      LAST_USED_BLOCK => l_LAST_USED_BLOCK );
 87  
 88     p('Total Blocks', l_total_blocks);
 89     p('Total Bytes', l_total_bytes);
 90     p('FS1 Blocks', l_fs1_blocks);
 91     p('FS2 Blocks', l_fs2_blocks);
 92     p('FS3 Blocks', l_fs3_blocks);
 93     p('FS4 Blocks', l_fs4_blocks);
 94  end;
 95  /

Procedure created.

SQL> 
SQL> show error
No errors.
SQL> 
SQL> set serveroutput on
SQL> 
SQL> DROP TABLE x;

Table dropped.

SQL> 
SQL> CREATE TABLE x AS
  2  SELECT * FROM all_objects;

Table created.

SQL> 
SQL> CREATE INDEX x_idx ON x(object_name);

Index created.

SQL> 
SQL> BEGIN
  2     show_space (
  3        p_segname => 'X_IDX',
  4        p_type    => 'INDEX'
  5     );
  6  END;
  7  /
Total Blocks............................32
Total Bytes.............................262144
FS1 Blocks..............................0
FS2 Blocks..............................1
FS3 Blocks..............................0
FS4 Blocks..............................0

PL/SQL procedure successfully completed.

SQL> 
SQL> DELETE FROM x;

5904 rows deleted.

SQL> COMMIT;

Commit complete.

SQL> 
SQL> BEGIN
  2     show_space (
  3        p_segname => 'X_IDX',
  4        p_type    => 'INDEX'
  5     );
  6  END;
  7  /
Total Blocks............................32
Total Bytes.............................262144
FS1 Blocks..............................0
FS2 Blocks..............................26
FS3 Blocks..............................0
FS4 Blocks..............................0

PL/SQL procedure successfully completed.

SQL> 
SQL> spool off
Tom Kyte
Followup  

October 31, 2012 - 5:30 pm UTC 

you might have removed index leaf entries (or not, we don't necessarily clean them up in real time) but you would still have the root and branch blocks to think about.

free space in an index block isn't really relevant, we ALWAYS fill them up - data has to go into a very specific location in an index - pctfree doesn't count after the index is created or rebuilt - we always fill the blocks up 100% 