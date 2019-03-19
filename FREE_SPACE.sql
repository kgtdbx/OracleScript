--SET SERVEROUTPUT ON

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
   
   SYS.dbms_space.unused_space('SYSTEM','EMP','TABLE',
                          VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7);
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
--OR
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


/*Здесь верхняя отметка таблицы (в байтах) представляет собой разницу между значениями TOTAL_BYTES и UNUSED_BYTES.
 Значение UNUSED_BLOCKS соответствует числу блоков выше высшей точки. 
 TOTAL_BLOCKS это общее количество блоков связанное с данной таблицей! Улавливаете! 
 Если нужно сжать таблицу и значение UNUSED_BLOCKS не равно нулю, 
 с помощью команды ALTER TABLE можно забрать пространство выше верхней отметки. 
 Чтобы освободить занимаемое таблицей пространство можно дать команду:
*/
--ALTER TABLE SYSTEM.EMP DEALLOCATE UNUSED KEEP 49152
--ALTER TABLE XREF_IDENTIFICATION DEALLOCATE UNUSED KEEP 0

/*
alter table XREF_IDENTIFICATION deallocate unused space;
alter index IDX_XREF_IDENTIFICATION_04 deallocate unused space;

alter table XREF_IDENTIFICATION coalesce;
alter index IDX_XREF_IDENTIFICATION_04 coalesce;
 
alter table XREF_IN_SUB_QUEUE_IDX 
modify partition P1 
coalesce subpartition;

alter table XREF_IDENTIFICATION 
modify partition INDICES_ISSUE_ALT_IDTFCN 
coalesce partition;
*/


---##########################################--
create or replace procedure show_space
( p_segname in varchar2,
p_owner in varchar2 default user,
p_type in varchar2 default 'TABLE',
p_partition in varchar2 default NULL )
-- this procedure uses authid current user so it can query DBA_*
-- views using privileges from a ROLE and so it can be installed
-- once per database, instead of once per user that wanted to use it
authid current_user
as
l_free_blks number;
l_total_blocks number;
l_total_bytes number;
l_unused_blocks number;
l_unused_bytes number;
l_LastUsedExtFileId number;
l_LastUsedExtBlockId number;
l_LAST_USED_BLOCK number;
l_segment_space_mgmt varchar2(255);
l_unformatted_blocks number;
l_unformatted_bytes number;
l_fs1_blocks number; l_fs1_bytes number;
l_fs2_blocks number; l_fs2_bytes number;
l_fs3_blocks number; l_fs3_bytes number;
l_fs4_blocks number; l_fs4_bytes number;
l_full_blocks number; l_full_bytes number;

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
and seg.tablespace_name = ts.tablespace_name'
into l_segment_space_mgmt
using p_segname, p_partition, p_partition, p_owner;
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
p( 'FS1 Blocks (0-25) ', l_fs1_blocks );
p( 'FS2 Blocks (25-50) ', l_fs2_blocks );
p( 'FS3 Blocks (50-75) ', l_fs3_blocks );
p( 'FS4 Blocks (75-100)', l_fs4_blocks );
p( 'Full Blocks ', l_full_blocks );
else
dbms_space.free_blocks(
segment_owner => p_owner,
segment_name => p_segname,
segment_type => p_type,
freelist_group_id => 0,
free_blks => l_free_blks);

p( 'Free Blocks', l_free_blks );
end if;
-- and then the unused space API call to get the rest of the
-- information
dbms_space.unused_space
( segment_owner => p_owner,
segment_name => p_segname,
segment_type => p_type,
partition_name => p_partition,
total_blocks => l_total_blocks,
total_bytes => l_total_bytes,
unused_blocks => l_unused_blocks,
unused_bytes => l_unused_bytes,
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

