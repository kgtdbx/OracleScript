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
