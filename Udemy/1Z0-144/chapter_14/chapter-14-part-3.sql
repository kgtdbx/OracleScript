select * from all_directories;

create or replace procedure read_any_file
(P_dir in varchar2, p_file_name in varchar2)
is
l_file UTL_FILE.file_type;
l_text         VARCHAR2(32767);
begin
  l_file := UTL_FILE.fopen(P_dir, p_file_name, 'r');
  begin
           loop
          UTL_FILE.get_line(l_file, l_text);
          DBMS_OUTPUT.put_line( l_text);
           end loop;
   exception 
          when no_data_found then
          DBMS_OUTPUT.put_line('end file');
          UTL_FILE.fclose(l_file);
   end;

exception 
          when UTL_FILE.invalid_operation then
         DBMS_OUTPUT.put_line('can not open the file,invalid file name');
           when UTL_FILE.read_error then
         DBMS_OUTPUT.put_line('can not be read');
end read_any_file;

execute read_any_file('MYDIR','sample2.txt');

execute read_any_file('MYDIR','sampdddle.txt');

---to see all directories
select * from all_directories;



