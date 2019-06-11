--1 in order to send email, install UTL_MAIL package ( DBA task/ Pluggable Database) 
--connect sys as sysdba and you should execute this on the pluggable db
--@E:\app\kh\product\12.2.0\dbhome_1\rdbms\admin\utlmail.sql
--@E:\app\kh\product\12.2.0\dbhome_1\rdbms\admin\prvtmail.plb
--2 GRANT execute ON utl_mail TO public
--3 add record to ACL T
--the DBMS_NETWORK_ACL_ADMIN package provides the interface to administer 
--the network Access Control List (ACL).

--alter system set smtp_out_server = 'mail.xxx.ac.ae:25'

BEGIN
  UTL_MAIL.send(sender => 'khaled.khudari@ankabut.ae',
            recipients => 'khaled_alkhudari@hotmail.com',
               subject => 'Test Mail',
               message => 'Hello World',
             mime_type => 'text; charset=us-ascii');
END;
--------------------------------------------------------------
--create directory KHTEST as '/u01';

declare
     function get_image (P_DIR VARCHAR2,P_FILE_NAME VARCHAR2)
     RETURN RAW
     IS
     IMAGE raw(32767);
     f bfile :=bfilename(P_DIR,P_FILE_NAME);
     --BFILENAME returns a BFILE locator that is associated 
     --with a physical LOB binary file on the server file system
     BEGIN
      --This procedure opens a BFILE for read-only access. 
      dbms_lob.fileopen(f,dbms_lob.file_readonly);
      IMAGE:= dbms_lob.substr(f);
      dbms_lob.close(f);
      return IMAGE;
     END;
BEGIN
    utl_mail.send_attach_raw(sender => 'khaled.khudari@ankabut.ae',
            recipients => 'khaled_alkhudari@hotmail.com',
               subject => 'Test Mail with Attachment',
               message => 'kindly find the attachment',
             mime_type => 'text; charset=us-ascii',
             attachment=> get_image('KHTEST','jordan.jpg'),
             att_inline=>true,
             att_mime_type=>'image/jpg',
             att_filename=>'jordan.jpg'
             );
END;


----------------------------------


declare
     function get_file (P_DIR VARCHAR2,P_FILE_NAME VARCHAR2)
     RETURN varchar2
     IS
     v_cont varchar2(32767);
     f bfile :=bfilename(P_DIR,P_FILE_NAME);
     --BFILENAME returns a BFILE locator that is associated 
     --with a physical LOB binary file on the server file system
     BEGIN
      --This procedure opens a BFILE for read-only access. 
      dbms_lob.fileopen(f,dbms_lob.file_readonly);
      v_cont:= utl_raw.cast_to_varchar2 (dbms_lob.substr(f) );
      dbms_lob.close(f);
      return v_cont;
     END;
BEGIN
    utl_mail.send_attach_varchar2(sender => 'khaled.khudari@ankabut.ae',
            recipients => 'khaled_alkhudari@hotmail.com',
               subject => 'Test Mail with text Attachment',
               message => 'kindly find the attachment',
             mime_type => 'text; charset=us-ascii',
             attachment=> get_file('KHTEST','notes.txt'),
             att_inline=>false,
             att_mime_type=>'text/Plain',
             att_filename=>'notes.txt'
             );
END;

select * from all_directories;

