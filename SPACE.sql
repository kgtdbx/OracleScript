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
