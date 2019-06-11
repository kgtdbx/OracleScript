/*
to read/write file , we need to create directory
create directory only for sys and system user
1- open sqlplus
2-con as sysdba
3- alter session set container=orclpdb ( the plug db name )
4- create directory mydir as 'F:\TEST';
5- grant READ, WRITE on DIRECTORY MYDIR to public;
6- CREATE THE DIRECTORY ON your computer ( the server )
7-put empty file sample.txt
*/

--take the output for this select and put it in sample.txt
select * from employees;

declare
l_file UTL_FILE.file_type;
l_location     VARCHAR2(100) := 'MYDIR'; --CAPITAL
l_filename     VARCHAR2(100) := 'sample.txt';
l_text         VARCHAR2(32767);
begin
 -- Open file.
  l_file := UTL_FILE.fopen(l_location, l_filename, 'r');
 
 --Read and output first line.
  UTL_FILE.get_line(l_file, l_text);
  DBMS_OUTPUT.put_line('First Line:'  || l_text);
  UTL_FILE.get_line(l_file, l_text);
  DBMS_OUTPUT.put_line('second Line:' || l_text );
  --close the file
  UTL_FILE.fclose(l_file);

end;
-------------------


declare
l_file UTL_FILE.file_type;
l_location     VARCHAR2(100) := 'MYDIR'; --CAPITAL
l_filename     VARCHAR2(100) := 'sample.txt';
l_text         VARCHAR2(32767);
begin
 -- Open file.
  l_file := UTL_FILE.fopen(l_location, l_filename, 'r');
 
         begin
           loop
          UTL_FILE.get_line(l_file, l_text);
          DBMS_OUTPUT.put_line( l_text);
           
          end loop;
          exception when no_data_found then
           DBMS_OUTPUT.put_line('end file');
        end;
        
  --close the file
  UTL_FILE.fclose(l_file);

end;
----------------------------------------
--UTL_FILE.put_line
declare
l_file UTL_FILE.file_type;
l_location     VARCHAR2(100) := 'MYDIR'; --CAPITAL
l_filename     VARCHAR2(100) := 'sample2.txt';
begin
 -- Open file.
  l_file := UTL_FILE.fopen(l_location, l_filename, 'w');
 
       
           for i in (select * from DEPARTMENTS)
           loop
          UTL_FILE.put_line(l_file, i.DEPARTMENT_name);      
          end loop;
   
        
  --close the file
  UTL_FILE.fclose(l_file);
  
 l_file := UTL_FILE.fopen(l_location, l_filename, 'A');
 UTL_FILE.put_line(l_file, 'ADDITIONAL LINES');
 UTL_FILE.fclose(l_file);
end;

