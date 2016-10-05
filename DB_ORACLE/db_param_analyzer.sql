REM HEADER
REM   $Header: db_param_analyzer.sql v200.2 Takayuki Anzai $
REM
REM MODIFICATION LOG:
REM
REM   <<COMMENT>>
REM
REM   How to run it? Follow the directions found in the Master Note 1953468.1
REM
REM   sqlplus apps/<password> @db_param_analyzer.sql
REM
REM   Output file format found in the same directory if run manually
REM
REM   db_param_analyzer_<HOST_NAME>_<SID>_<DATE>.html
REM
REM   Created: December 3, 2014
REM   Last Updated: May 29, 2015
REM
REM
REM  CHANGE HISTORY:
REM   200.2 29-MAY-2015 Takayuki Anzai deleted alter session set NLS_DATE_FORMAT command.
REM   200.1 14-APRIL-2015 Takayuki Anzai changed version number from 1.01 to 200.1.
REM   1.01  06-MARCH-2015 Takayuki Anzai _sqlexec_progression_cost should be removed if user uses database R11gR1 or later.
REM   1.00  03-DECEMBER-2014 Takayuki Anzai Creation from design
--
set arraysize 1
set heading off
set feedback off
set echo off
set verify off
SET CONCAT ON
SET CONCAT .
SET ESCAPE OFF
SET ESCAPE '\'
--
set lines 120
set pages 9999
set serveroutput on size 100000
--
VARIABLE st_time        VARCHAR2(100);
VARIABLE et_time        VARCHAR2(100);
VARIABLE sid            VARCHAR2(20);
VARIABLE host           VARCHAR2(30);
VARIABLE instance_name  VARCHAR2(16);
VARIABLE APPS_REL       VARCHAR2(10);
VARIABLE n              NUMBER;
VARIABLE cluster_db     VARCHAR2(10);
VARIABLE cluster_db_ins NUMBER;
VARIABLE db_ver         VARCHAR2(10);
VARIABLE p_active_users NUMBER;
VARIABLE processes      NUMBER;
VARIABLE active_users   number;
VARIABLE cpu_count      number;
VARIABLE sga_target     number;
VARIABLE os_name        varchar2(30);
VARIABLE n_warning      number;
VARIABLE n_check        number;
--
begin
  select to_char(sysdate,'hh24:mi:ss') into :st_time from dual;
  select upper(instance_name) into :sid from v$instance;
  select substr(host_name,1,30) into :host from v$instance;
  select substr('1.0.0',1,10) into :apps_rel from v$instance;
  select to_number(value) into :cpu_count from v$parameter where name = 'cpu_count';
  select to_number(value) into :processes from v$parameter where name = 'processes';
  select to_number(value) into :sga_target from v$parameter where name = 'sga_target';
  select platform_name into :os_name from v$database;
  select count(*) into :active_users from fnd_user where sysdate between start_date and nvl(end_date,sysdate) and last_logon_date >= sysdate - 30;

  :n_warning := 0;
  :n_check := 0;

end;
/

prompt Please enter the number of possible active users.
prompt If you skip to enter the value, this script will get the number of active users from fnd_user table who have logged on ebs in last 30 days.

ACCEPT p_active_users NUMBER DEFAULT -1 PROMPT 'Enter the number of active users: '
--
declare
  l_active_users number :=&p_active_users;
begin
  IF l_active_users=-1 THEN
    :active_users := :active_users; -- from fnd_user.
  ELSE
    :active_users :=l_active_users; -- from argument.
  END IF;
end;
/

COLUMN host_name NOPRINT NEW_VALUE hostname
SELECT host_name from v$instance;
COLUMN instance_name NOPRINT NEW_VALUE instancename
SELECT instance_name from v$instance;
COLUMN sysdate NOPRINT NEW_VALUE when
select to_char(sysdate, 'YYYY-Mon-DD') "sysdate" from dual;
SPOOL db_param_analyzer_&&hostname._&&instancename._&&when..html

-- Deleted by TANZAI
-- alter session set NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

prompt <HTML>
prompt <HEAD>
prompt <TITLE>R12: Database Parameter Settings Analyzer</TITLE>
prompt <STYLE TYPE="text/css">
prompt <!-- TD {font-size: 10pt; font-family: calibri; font-style: normal} -->
prompt </STYLE>
prompt </HEAD>
prompt <BODY>
prompt <TABLE border="1" cellspacing="0" cellpadding="10">
prompt <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF"><TD bordercolor="#DEE6EF"><font face="Calibri">
prompt <B><font size="+2">R12: Database Parameter Settings Analyzer for
select UPPER(instance_name) from v$instance;
prompt <B><font size="+2"> on
select UPPER(host_name) from v$instance;
prompt </font></B></TD></TR>
prompt </TABLE><BR>
prompt <a href="https://support.oracle.com/rs?type=doc\&id=432.1" target="_blank">
prompt <img src="https://blogs.oracle.com/ebs/resource/Proactive/banner4.jpg" title="Click here to see other helpful Oracle Proactive Tools" width="758" height="81" border="0" alt="Proactive Services Banner" /></a></a>
prompt <br>
prompt <font size="-1"><i><b>Database Parameters Settings Analyzer v1.01 compiled on :
select to_char(sysdate, 'Dy Month DD, YYYY') from dual;
prompt at
select to_char(sysdate, ' hh24:mi:ss') from dual;
prompt </b></i></font><BR><BR>
prompt <table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">
prompt <tbody> <tr><td><font size="+1">
prompt This Database Parameter Settings Analyzer script reviews the current database initialization parameter settings
prompt and providing helpful feedback and recommendations on Best Practices for any areas for concern on your system.</font><BR>
REM prompt <p><font size="+2">The analyzer results are influenced by statistics. Please ensure that your statistics are recent before depending on the output.</font></p><BR>
prompt </td></tr></tbody>
prompt </table><br>
prompt <table width="95%" border="0">
prompt   <tr>
prompt     <td colspan="2" height="46">
prompt       <p><a name="top"><b><font size="+2">Table of Contents</font></b></a> </p>
prompt     </td>
prompt   </tr>
prompt   <tr>
prompt     <td width="50%">
prompt       <a href="#section1"><b><font size="+1">System Overview</font></b></a>
prompt     </td>
prompt     <td width="50%">
prompt       <a href="#section2"><b><font size="+1">Database Parameter Settings Recommendations Report</font></b></a>
prompt     </td>
prompt   </tr>
prompt   <tr>
prompt     <td width="50%">
prompt       <a href="#section3"><b><font size="+1">Missing Mandatory Parameters Report</font></b></a>
prompt     </td>
prompt     <td width="50%">
prompt       <a href="#section4"><b><font size="+1">References</font></b></a>
prompt     </td>
prompt   </tr>
prompt   <tr>
prompt     <td width="50%">
prompt       <a href="#section4"><b><font size="+1">Feedback</font></b></a>
prompt     </td>
prompt   </tr>
prompt </table><BR><BR>
prompt <a name="section1"></a><B><font size="+2">Database Parameter Settings Analyzer Overview</font></B><BR><BR>
--
--
REM
REM ******* E-Business Suite Version *******
REM
--
prompt <script type="text/javascript">    function displayRows1sql1(){var row = document.getElementById("s1sql1");if (row.style.display == '')  row.style.display = 'none';     else row.style.display = '';    }</script>
prompt <TABLE border="1" cellspacing="0" cellpadding="2">
prompt <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF">
REM prompt   <TD COLSPAN=4 bordercolor="#DEE6EF">
prompt   <TD COLSPAN=5 bordercolor="#DEE6EF">
prompt     <font face="Calibri"><a name="adv111"></a>
prompt      <B>E-Business Suite Version</B>
prompt     </font>
prompt   </TD>
prompt     <TD bordercolor="#DEE6EF">
prompt       <div align="right"><button onclick="displayRows1sql1()" >SQL Script</button></div>
prompt     </TD>
prompt </TR>
prompt <TR id="s1sql1" style="display:none">
REM prompt    <TD BGCOLOR=#DEE6EF colspan="5" height="60">
prompt    <TD BGCOLOR=#DEE6EF colspan="6" height="60">
prompt       <blockquote><p align="left">
prompt          select vi.instance_name, fpg.release_name, vi.host_name, vi.startup_time, vi.version <br>
prompt          from fnd_product_groups fpg, v$instance vi<br>
prompt          where upper(substr(fpg.APPLICATIONS_SYSTEM_NAME,1,4)) = upper(substr(vi.INSTANCE_NAME,1,4));</p>
prompt       </blockquote>
prompt     </TD>
prompt </TR>
prompt <TR>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>SID</B></TD>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>RELEASE</B></TD>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>HOSTNAME</B></TD>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>STARTED</B></TD>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>DATABASE</B></TD>
prompt <TD BGCOLOR=#DEE6EF><font face="Calibri"><B>ACTIVE USERS</B></TD>
prompt </TR>

exec :n := dbms_utility.get_time;

select
'<TR><TD>'||vi.instance_name||'</TD>'||chr(10)||
'<TD>'||fpg.release_name||'</TD>'||chr(10)||
'<TD>'||vi.host_name||'</TD>'||chr(10)||
'<TD>'||vi.startup_time||'</TD>'||chr(10)||
'<TD>'||vi.version||'</TD>'
from fnd_product_groups fpg, v$instance vi
where upper(substr(fpg.APPLICATIONS_SYSTEM_NAME,1,4)) = upper(substr(vi.INSTANCE_NAME,1,4));

exec dbms_output.put_line('<TD>'||:active_users||'</TD></TR>');
prompt </TABLE>

exec :n := (dbms_utility.get_time - :n)/100;
exec dbms_output.put_line('<font size="-1"><i> Elapsed time '||:n|| ' seconds</i></font><P><P>');

begin
  select version into :db_ver from v$instance;
  select value into :cluster_db from v$parameter where upper(name) = 'CLUSTER_DATABASE';
  select value into :cluster_db_ins from v$parameter where upper(name) = 'CLUSTER_DATABASE_INSTANCES';

  if (:db_ver like '8.%') or (:db_ver like '9.%') then
    :db_ver := '0'||:db_ver;
  end if;

  dbms_output.put_line('<table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">');
  dbms_output.put_line('<tbody><tr><td> ');
  dbms_output.put_line('      <p><B>Your EBS Database Version is ('||:db_ver||') </B><BR>');
  dbms_output.put_line('RDBMS Settings for Oracle Apps:<BR>');
  dbms_output.put_line('<B>See <a href="https://support.oracle.com/CSP/main/article?cmd=show\&type=NOT\&id=396009.1" target="_blank">Doc ID: 396009.1</a> Database Initialization Parameters for Oracle Applications Release 12.</B><BR>');
  dbms_output.put_line('</td></tr></tbody></table><BR>');

  if :cluster_db ='FALSE' then
    dbms_output.put_line('<table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">');
    dbms_output.put_line('<tbody><tr><td> ');
    dbms_output.put_line('      <p><B>Your RDBMS is not RAC install as your cluster_database is set to '||:cluster_db||' </B><BR>');
    dbms_output.put_line('</td></tr></tbody></table><BR>');
  else
    dbms_output.put_line('<table border="1" name="Warning" cellpadding="10" bgcolor="#DEE6EF" cellspacing="0">');
    dbms_output.put_line('<tbody><tr><td> ');
    :n_warning := :n_warning + 1;
    dbms_output.put_line('<p><B>Warning</B><BR>');
    dbms_output.put_line('Your RDBMS is RAC install as your cluster_database is set to '||:cluster_db||' and you have '||:cluster_db_ins||' nodes on your RDBMS.<BR><BR>' );
    dbms_output.put_line('RAC install can cause ATP failures (ATP Processing Error) and require setup by DBA.<BR><BR>');
    dbms_output.put_line('Refer <a href="https://support.oracle.com/CSP/main/article?cmd=show\&type=NOT\&id=266125.1" target="_blank">Note 266125.1</a> and see Section 24.3 for setup information.<BR><BR>');
    dbms_output.put_line('RAC install can cause failures in Planning and Data Collections, refer <a href="https://support.oracle.com/CSP/main/article?cmd=show\&type=NOT\&id=279156.1" target="_blank">Note 279156.1</a> <BR><BR>');
    dbms_output.put_line('</p></td></tr></tbody></table><br>');
  end if;
end;
/

prompt <A href="#top"><font size="-1">Back to Top</font></A><BR><BR>

REM
REM ******* Database Parameter Settings Recommendations *******
REM
prompt <a name="section2"></a><B><font size="+2">Database Parameter Settings Recommendations Report</font></B><BR><BR>

exec :n := dbms_utility.get_time;

declare

  Cursor cdp1 is select name, nvl(value,'<i><null></i>') value from v$parameter;
  v_cfc                number;
begin
  dbms_output.put_line('<TABLE border="1" cellspacing="0" cellpadding="2">');
  dbms_output.put_line('<TR bgcolor="#DEE6EF" bordercolor="#DEE6EF"><TD COLSPAN=4 bordercolor="#DEE6EF"><font face="Calibri">');
  dbms_output.put_line('<B>Recommendations for Database Parameters</B></font></TD></TR>');
  dbms_output.put_line('<TR>');
  dbms_output.put_line('<TD BGCOLOR=#DEE6EF><font face="Calibri"><B>NAME</B></font></TD>');
  dbms_output.put_line('<TD BGCOLOR=#DEE6EF><font face="Calibri"><B>VALUE</B></font></TD>');
  dbms_output.put_line('<TD BGCOLOR=#DEE6EF><font face="Calibri"><B>STATUS</B></font></TD>');
  dbms_output.put_line('<TD BGCOLOR=#DEE6EF><font face="Calibri"><B>RECOMMENDATIONS</B></font></TD></TR>');
For dp in cdp1
  LOOP
    dbms_output.put_line('<TR><TD>'||dp.name||'</TD>');
    dbms_output.put_line('<TD>'||dp.value||'</TD>');
    IF :apps_rel like '12.%' THEN

-- ******* Common Database Initialization Parameters For All Releases *******

      IF lower(dp.name)='control_files' THEN
        v_cfc:=0;
        select length(value)-length(replace(value,',',''))+1 fileCount into v_cfc
        from v$parameter
        where name ='control_files';

        IF v_cfc >2 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('at least 3 control files.'||'</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>There should be at least two control files, preferably three,located on different volumes in case one of the volumes fails.');
          dbms_output.put_line('Control files can expand, hence you should allow at least 20M per file for growth.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_block_size' THEN
        IF dp.value= '8192' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>The required block size for Oracle E-Business Suite is 8K. No other value may be used.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_system_trig_enabled' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to TRUE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='o7_dictionary_accessibility' THEN
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to FALSE for Oracle E-Business Suite Release 12.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_language' THEN
        IF lower(dp.value)='american'  THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to american.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_territory' THEN
        IF lower(dp.value)='america'  THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to america.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_date_format' THEN
        IF upper(dp.value)='DD-MON-RR'  THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to DD-MON-RR.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_numeric_characters' THEN
        IF lower(dp.value)='.,'  THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to ".,".'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_sort' THEN
        IF lower(dp.value)='binary'  THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to binary.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_comp' THEN
        IF lower(dp.value)='binary' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to binary.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_length_semantics' THEN
        IF upper(dp.value)='BYTE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to BYTE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='audit_trail' THEN
        :n_check := :n_check + 1;
        dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');

        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD>There is a performance overhead for enabling the audit_trail.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD>This parameter must be set to TRUE, if you want audit_trail.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='max_dump_file_size' THEN
        IF (lower(dp.value)='20480') or (lower(dp.value)='unlimited') THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is unlimited.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='timed_statistics' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value. ');
          dbms_output.put_line('On most platforms, enabling timed statistics has minimal effect on performance.'||'</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to TRUE, if you want use of SQL Trace and Statspack.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_trace_files_public' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>TRUE is recommended in order to facilitate trace file analysis.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='sessions' THEN
        IF to_number(dp.value)=(:processes * 2) THEN
          :n_check := :n_check + 1;
          dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');
  --        dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('(2 x processes). But this is set to twice the value of the processes parameter. So it depends on the value of processes parameter.');
          dbms_output.put_line('If the value of processes parameter is wrong, the value of sessions should be changed based on the value of processes.'||'</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>The sessions parameter should be set to twice the value of the processes parameter.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_files' THEN
        IF to_number(dp.value)=512 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 512.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='dml_locks' THEN
        IF to_number(dp.value)=10000 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 10000.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='cursor_sharing' THEN
        IF upper(dp.value)='EXACT' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter must be set to EXACT.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='open_cursors' THEN
        IF to_number(dp.value)=600 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 600.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='session_cached_cursors' THEN
        IF to_number(dp.value)=500 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 500.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_block_checking' THEN
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_block_checksum' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is TRUE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='log_checkpoint_timeout' THEN
        IF to_number(dp.value)>=1200 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('at least 20 mins.'||'</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 1200.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='log_checkpoint_interval' THEN
        IF to_number(dp.value)=100000 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 100000.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='log_buffer' THEN
        IF to_number(dp.value)=10485760 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 10485760.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='log_checkpoints_to_alert' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is TRUE.'||'</TD></TR>');
          END IF;
      ELSIF lower(dp.name)='_shared_pool_reserved_min_alloc' THEN
        IF to_number(dp.value)='4100' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 4100.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='cursor_space_for_time' THEN
        :n_check := :n_check + 1;
        dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD>You have the default value of FALSE. If you want to know more about this parameter, see <a href="https://support.oracle.com/CSP/main/article?cmd=show\&type=NOT\&id=396009.1" target="_blank">Doc ID: 396009.1</a> in details.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD>Cursor space for time requires at least a 50% increase in the size of the shared pool.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='aq_tm_processes' THEN
        IF to_number(dp.value)>=1 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('at least mininum value(1)</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be set to 1 or higher.</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='job_queue_processes' THEN
        IF to_number(dp.value)=2 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 2 for optimal performance.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='parallel_min_servers' THEN
        IF to_number(dp.value)=0 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be set to 0.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_sort_elimination_cost_ratio' THEN
        IF to_number(dp.value)=5 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 5.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_like_with_bind_as_equality' THEN
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is TRUE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_fast_full_scan_enabled' THEN
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_b_tree_bitmap_plans' THEN
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_secure_view_merging' THEN
        IF upper(dp.value)='FALSE' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_sqlexec_progression_cost' THEN
-- Modified by TANZAI. This parameter is needed only for database 10gR2.
        IF (:db_ver like '10.2.%') THEN
          IF to_number(dp.value)=2147483647 THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is 2147483647.'||'</TD></TR>');
          END IF;
        ELSE -- ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
-- End of modification
      ELSIF lower(dp.name)='cluster_database' THEN
        :n_check := :n_check + 1;
        dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');
        IF upper(dp.value)='TRUE' THEN
          dbms_output.put_line('<TD>'||'If you do not have the Oracle RAC environment, this parameter should be set to FALSE.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD>'||'If you have the Oracle RAC environment, this parameter should be set to TRUE.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='workarea_size_policy' THEN
        IF upper(dp.value)='AUTO' THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('AUTO. The automatic memory manager is used to manage the PGA memory.'||'</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is AUTO. The automatic memory manager is used to manage the PGA memory.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='olap_page_pool_size' THEN
        IF to_number(dp.value)>=4194304 THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>Recommended value for this is 4194304.'||'</TD></TR>');
        END IF;
-- ******* Sizing *******
-- Based on the # of active_users.
      ELSIF dp.name in ('sga_target','shared_pool_size','shared_pool_reserved_size','processes') THEN
        IF :active_users<=100 THEN
          IF dp.name in ('sga_target') THEN
            IF to_number(dp.value)>=1073741824 THEN -- 1G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('1G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 1073741824(1G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_size') THEN
            IF to_number(dp.value)>=629145600 THEN -- 600M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('600M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 629145600(600M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_reserved_size') THEN
            IF to_number(dp.value)>=62914560 THEN -- 60M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('60M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 62914560(60M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('pga_aggregate_target') THEN
            IF to_number(dp.value)>=2147483648 THEN -- 2G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('2G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 2147483648(2G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('processes') THEN
            IF to_number(dp.value)>=200 THEN
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 200 for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          END IF;
        ELSIF (:active_users>100) and (:active_users<=500) THEN
          IF dp.name in ('sga_target') THEN
            IF to_number(dp.value)>=2147483648 THEN -- 2G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('2G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 2147483648(2G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_size') THEN
            IF to_number(dp.value)>=838860800 THEN -- 800
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('800M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 838860800(800M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_reserved_size') THEN
            IF to_number(dp.value)>=83886080 THEN -- 80M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value ');
              dbms_output.put_line('60M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 83886080(80M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('pga_aggregate_target') THEN
            IF to_number(dp.value)>=4294967296 THEN -- 4G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('4G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 4294967296(4G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('processes') THEN
            IF to_number(dp.value)>=800 THEN
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 800 for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          END IF;
        ELSIF (:active_users>500) and (:active_users<=1000) THEN
          IF dp.name in ('sga_target') THEN
            IF to_number(dp.value)>=3221225472 THEN -- 3G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('3G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 3221225472(3G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_size') THEN
            IF to_number(dp.value)>=1048576000 THEN -- 1000M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('1000M.'||'</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 1048576000(1000M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_reserved_size') THEN
            IF to_number(dp.value)>=104857600 THEN -- 100M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('100M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 104857600(100M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('pga_aggregate_target') THEN
            IF to_number(dp.value)>=10737418240 THEN -- 10G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('10G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 10737418240(10G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('processes') THEN
            IF to_number(dp.value)>=1200 THEN
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 1200 for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          END IF;
        ELSE -- the number of active users is 1001 or higher.
          IF dp.name in ('sga_target') THEN
            IF to_number(dp.value)>=15032385536 THEN -- 14G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('14G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 15032385536(14G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_size') THEN
            IF to_number(dp.value)>=2097152000 THEN -- 2000M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('2000M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 2097152000(2000M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('shared_pool_reserved_size') THEN
            IF to_number(dp.value)>=209715200 THEN -- 200M
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('200M for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 209715200(200M) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('pga_aggregate_target') THEN
            IF to_number(dp.value)>=21474836480 THEN -- 20G
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value of ');
              dbms_output.put_line('20G for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 21474836480(20G) for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          ELSIF dp.name in ('processes') THEN
            IF to_number(dp.value)>=2500 THEN
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
            ELSE
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Recommended value for this is 2500 for the # of current active users('||to_char(:active_users)||')</TD></TR>');
            END IF;
          END IF;
        END IF;

-- Based on the # of CPU.
      ELSIF lower(dp.name)='parallel_max_servers' THEN
        IF to_number(dp.value)=(2*:cpu_count) THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value of ');
          dbms_output.put_line('2 x the # of cpu(cpu_count:'|| to_char(:cpu_count) || ').</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be 2 x no. of CPUs(cpu_count:'|| to_char(:cpu_count) || ').</TD></TR>');
        END IF;

-- Based on sga_target.
      ELSIF lower(dp.name)='sga_max_size' THEN
        IF to_number(dp.value)>=:sga_target THEN
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD>You have the recommended value. ');
          dbms_output.put_line('This parameter should be the same with sga_target or more.</TD></TR>');
        ELSE
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be the same with sga_target or more.'||'</TD></TR>');
        END IF;

-- ******* Release-Specific Database Initialization Parameters For Oracle 10g Release 2 *******
-- ******* Release-Specific Database Initialization Parameters for Oracle 11g Release 1 *******
-- ******* Release-Specific Database Initialization Parameters for Oracle 11g Release 2 *******
-- ******* Release-Specific Database Initialization Parameters for Oracle 12c Release 1 *******

      ELSIF dp.name = 'compatible' THEN
        IF (:db_ver like '10.2.%') or (:db_ver like '11.%') or (:db_ver like '12.1%') THEN
          IF dp.value<>:db_ver THEN
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Set this value to '||:db_ver||', which is your database version.</TD></TR>');
          ELSE
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          END IF;
        END IF;

      ELSIF lower(dp.name)='undo_management' THEN
        IF (:db_ver like '10.2.%') or (:db_ver like '11.%') or (:db_ver like '12.1%') THEN
          IF dp.value='AUTO' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is AUTO.'||'</TD></TR>');
          END IF;
        END IF;

      ELSIF lower(dp.name)='plsql_optimize_level' THEN
        IF :db_ver like '10.2.%' THEN
          IF dp.value='2' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is 2.'||'</TD></TR>');
          END IF;
        ELSIF (:db_ver like '11.%') or (:db_ver like '12.1%') THEN
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;

      ELSIF lower(dp.name)='plsql_code_type' THEN
        IF (:db_ver like '10.2.%') or (:db_ver like '11.%') or (:db_ver like '12.1%') THEN
          IF lower(dp.value)='native' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is native.'||'</TD></TR>');
          END IF;
        END IF;

      ELSIF lower(dp.name)='plsql_native_library_subdir_count' THEN
        IF :db_ver like '10.2.%' THEN
          IF dp.value='149' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is 149.'||'</TD></TR>');
          END IF;
        ELSIF :db_ver like '11.%' THEN
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_optimizer_autostats_job' THEN
        IF (:db_ver like '11.%') or (:db_ver like '12.1%') THEN
          IF upper(dp.value)='FALSE' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
          END IF;
        END IF;
      ELSIF lower(dp.name)='parallel_force_local' THEN
        IF (:db_ver like '11.2%') or (:db_ver like '12.1%')  THEN
          IF upper(dp.value)='TRUE' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is TRUE.'||'</TD></TR>');
          END IF;
        END IF;
      ELSIF lower(dp.name)='sec_case_sensitive_logon' THEN
        IF (:db_ver like '11.%') or (:db_ver like '12.1%')  THEN
          IF :apps_rel<'12.1.1' THEN
            IF upper(dp.value)='TRUE' THEN
              :n_warning := :n_warning + 1;
              dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
              dbms_output.put_line('<TD>Oracle E-Business Suite now supports Oracle Database 11g case-sensitive database passwords.');
              dbms_output.put_line('This feature is available on E-Business Suite Rel 12.1.1 or higher.');
              dbms_output.put_line('This parameter should be set to FALSE.'||'</TD></TR>');
            ELSE -- FALSE
              dbms_output.put_line('<TD><B>Pass</B></font></TD>');
              dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
            END IF;
          ELSE -- 12.1.1 or higher
            IF upper(dp.value)='TRUE' THEN
              :n_check := :n_check + 1;
              dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');
              dbms_output.put_line('<TD>Oracle E-Business Suite now supports Oracle Database 11g case-sensitive database passwords.');
              dbms_output.put_line('This feature is available on E-Business Suite Rel 12.1.1 or higher.');
              dbms_output.put_line('To enable this feature apply patch 12964564.'||'</TD></TR>');
            ELSE -- FALSE
              :n_check := :n_check + 1;
              dbms_output.put_line('<TD bgcolor="#FFFF00"><B>Check</B></font></TD>');
              dbms_output.put_line('<TD>Oracle E-Business Suite now supports Oracle Database 11g case-sensitive database passwords.');
              dbms_output.put_line('This feature is available on E-Business Suite Rel 12.1.1 or higher.');
              dbms_output.put_line('To enable this feature apply patch 12964564 and set this parameter to TRUE.'||'</TD></TR>');
            END IF;
          END IF;
        END IF;
      ELSIF lower(dp.name)='pga_aggregate_limit' THEN
        IF :db_ver like '12.1%'  THEN
          IF dp.value='0' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is 0.'||'</TD></TR>');
          END IF;
        END IF;
      ELSIF lower(dp.name)='temp_undo_enabled' THEN
        IF :db_ver like '12.1%'  THEN
          IF upper(dp.value)='TRUE' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is TRUE.'||'</TD></TR>');
          END IF;
        END IF;
-- ******* Check Parameter Removal List *******
      -- This parameter is used by only 10gR2 on HP-UX Only
      ELSIF lower(dp.name)='_kks_use_mutex_pin' THEN
        IF (:db_ver like '10.2.%') and (:os_name like 'HP-UX%') THEN
          IF upper(dp.value)='FALSE' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE -- TRUE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>Recommended value for this is FALSE.'||'</TD></TR>');
          END IF;
        ELSE -- 11.1 or higher or without HP-UX
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      -- ****** For All Releases *****
      ELSIF lower(dp.name)='_always_anti_join' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_always_semi_join' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_complex_view_merging' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_index_join_enabled' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_new_initial_join_orders' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_optimizer_cost_based_transformation' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_optimizer_cost_model' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_optimizer_mode_force' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_optimizer_undo_changes' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_or_expand_nvl_predicate' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_ordered_nested_loop' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_push_join_predicate' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_push_join_union_view' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_shared_pool_reserved_min_alloc' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_sortmerge_inequality_join_off' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_table_scan_cost_plus_one' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_unnest_subquery' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='_use_column_stats_for_function' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='always_anti_join' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='always_semi_join' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_block_buffers' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_cache_size' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='db_file_multiblock_read_count' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='enqueue_resources' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='hash_area_size' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='java_pool_size' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='job_queue_interval' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='large_pool_size' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='max_enabled_roles' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_dynamic_sampling' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_features_enable' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_index_caching' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_index_cost_adj' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_max_permutations' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_mode' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='optimizer_percent_parallel' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='plsql_compiler_flags' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='query_rewrite_enabled' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='row_locking' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='sort_area_size' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='undo_retention' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='undo_suppress_errors' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        END IF;
      ELSIF lower(dp.name)='event' THEN
        IF ((:db_ver like '10.2%') or (:db_ver like '11.%') or (:db_ver like '12.%')) THEN
          IF (dp.value like '10932%trace%name%context%level% 32768') or
             (dp.value like '10933%trace%name%context%level% 512') or
             (dp.value like '10943%trace%name%context%forever%level% 2') or
             (dp.value like '10943%trace%name%context%level% 16384') or
             (dp.value like '38004%trace%name%context%forever%level% 1') THEN
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
          ELSE
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
          END IF;
        END IF;
      -- ****** For 11gR1 or later releases *****
-- Deleted by TANZAI
--      ELSIF lower(dp.name)='_sqlexec_progression_cost' THEN
--        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
--          :n_warning := :n_warning + 1;
--          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
--          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
--        ELSE
--          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
--          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
--        END IF;
-- End deletion.
      ELSIF lower(dp.name)='background_dump_dest' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='core_dump_dest' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='nls_language' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='plsql_native_library_dir' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='plsql_native_library_subdir_count' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='plsql_optimize_level' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='rollback_segments' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='sql_trace' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='timed_statistics' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='user_dump_dest' THEN
        IF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      -- ****** For 11gR2 or later releases *****
      ELSIF lower(dp.name)='sql_version' THEN
        IF ((:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='drs_start' THEN
        IF ((:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='parallel_instance_group' THEN
        IF ((:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSIF lower(dp.name)='instance_groups' THEN
        IF ((:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
          :n_warning := :n_warning + 1;
          dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
          dbms_output.put_line('<TD>This parameter should be removed from your database.'||'</TD></TR>');
        ELSE
          dbms_output.put_line('<TD><B>Pass</B></font></TD>');
          dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
-- ******* Additional Database Initialization Parameters For Oracle E-Business Suite Release 12.2 *******
      ELSIF lower(dp.name)='recyclebin' THEN
        IF :apps_rel like '12.2%' THEN
          IF lower(dp.value)='off' THEN
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD>You have the recommended value.</TD></TR>');
          ELSE
            :n_warning := :n_warning + 1;
            dbms_output.put_line('<TD bgcolor="#FF0000"><B>Warning</B></font></TD>');
            dbms_output.put_line('<TD>This parameter should be set to off.'||'</TD></TR>');
          END IF;
        ELSE
            dbms_output.put_line('<TD><B>Pass</B></font></TD>');
            dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
        END IF;
      ELSE -- Other parameters which has no recommended value definitions.
        dbms_output.put_line('<TD><B>Pass</B></font></TD>');
        dbms_output.put_line('<TD><font color="#D3D3D3">Recommended value is not defined.</font></TD></TR>');
      END IF; -- identify all database parameters
    -- ELSIF  -- without 12.%
    END IF; -- 12.%
  END LOOP; -- parse all db initialization parameters
  dbms_output.put_line('</TABLE>');
exception
  When others then
    dbms_output.put_line('Error: '||sqlerrm);
end;
/

exec :n := (dbms_utility.get_time - :n)/100;
exec dbms_output.put_line('<font size="-1"><i> Elapsed time '||:n|| ' seconds</i></font><P><P>');

-- Note of Missing Mandatory Parameters Report section.
prompt <table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">
prompt <tbody><font size="-1" face="Calibri"><tr><td><p>
exec dbms_output.put_line('You have total of '||:n_warning|| ' "Warning" records and '||:n_check||' "Check" records. Review these parameter values.');
prompt </p></font></td></tr></tbody>
prompt </table><br>

prompt <A href="#top"><font size="-1">Back to Top</font></A><BR><BR>


--
REM
REM ******* Missing Mandatory parameters *******
REM
prompt <a name="section3"></a><B><font size="+2">Missing Mandatory Parameters Report</font></B><BR><BR>
--
exec :n := dbms_utility.get_time;
--
declare
--  Cursor cdp1 is select name, nvl(value,chr(38)||'nbsp') value from v$parameter;
--  Cursor cdp1 is select name, nvl(value,'<i><null></i>') value from v$parameter;
--  v_cfc                number;
  j     number;
  na    varchar2(240);
  c_mis number;
begin
  dbms_output.put_line('<TABLE border="1" cellspacing="0" cellpadding="2">');
  dbms_output.put_line('<TR bgcolor="#DEE6EF" bordercolor="#DEE6EF"><TD COLSPAN=4 bordercolor="#DEE6EF"><font face="Calibri">');
  dbms_output.put_line('<a name="wfadmins"></a><B>Missing Mandatory Parameters Report</B></font></TD></TR>');
  dbms_output.put_line('<TR>');
  dbms_output.put_line('<TD BGCOLOR=#DEE6EF><font face="Calibri"><B>MISSING MANDATORY PARAMETERS</B></font></TD></TR>');

  c_mis:=0;

  IF ((:db_ver like '10.2%') or (:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
    begin
      na:='compatible';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='db_block_size';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_system_trig_enabled';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='o7_dictionary_accessibility';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='nls_date_format';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='nls_sort';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='nls_comp';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='nls_length_semantics';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='cursor_sharing';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='sga_target';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_sort_elimination_cost_ratio';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_like_with_bind_as_equality';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_fast_full_scan_enabled';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_b_tree_bitmap_plans';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='optimizer_secure_view_merging';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='_sqlexec_progression_cost';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
-- Modified by TANZAI. This parameter is needed only for database version R10gR2.
        IF (:db_ver like '10.2.%') THEN
          c_mis:=c_mis+1;
          dbms_output.put_line('<TD>'||na||'</TD></TR>');
        END IF;
-- End modification.
    end;
--
    begin
      na:='cluster_database';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='workarea_size_policy';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
--
    begin
      na:='undo_management';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
  ELSIF ((:db_ver like '11.1%') or (:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
--
    begin
      na:='_optimizer_autostats_job';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
  ELSIF ((:db_ver like '11.2%') or (:db_ver like '12.1%')) THEN
--
    begin
      na:='parallel_force_local';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
  ELSIF (:db_ver like '12.1%') THEN
--
    begin
      na:='pga_aggregate_limit';
      select 1 into j from v$parameter where lower(name) = na;
    exception
      when no_data_found then
        c_mis:=c_mis+1;
        dbms_output.put_line('<TD>'||na||'</TD></TR>');
    end;
  END IF;

  dbms_output.put_line('</TABLE>');
  :n := (dbms_utility.get_time - :n)/100;
  dbms_output.put_line('<font size="-1"><i> Elapsed time '||:n|| ' seconds</i></font><P><P>');

-- Note of Missing Mandatory Parameters Report section.
  dbms_output.put_line('<table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">');
  dbms_output.put_line('<tbody><font size="-1" face="Calibri"><tr><td><p>');
  IF c_mis=0 THEN
    dbms_output.put_line('You do not have mandatory parameters which does not exists on your database.');
  ELSE
    dbms_output.put_line('You have total of '||to_char(c_mis)||' mandatory parameters which does not exists on your database. See <a href="https://support.oracle.com/rs?type=doc\&id=396009.1" target="_blank">Doc ID 396009.1</a> and populate the mandatory parameters.');
  END IF;
  dbms_output.put_line('</p></font></td></tr></tbody>');
  dbms_output.put_line('</table><br>');
  dbms_output.put_line('<a href="#top"><font size="-1">Back to Top</font></A><BR><BR>');
exception
  When others then
    dbms_output.put_line('Error: '||sqlerrm);
end;
/


REM ****************************************************************************************
REM *******                         References                                       *******
REM ****************************************************************************************
REM
prompt <a name="section4"></a><B><font size="+2">References</font></B><BR><BR>
REM
REM prompt <table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">
REM prompt <tbody><font size="-1" face="Calibri"><tr><td><p>
REM
REM prompt <a href="https://communities.oracle.com/portal/server.pt/community/value_chain_planning/321" target="_blank">
REM prompt My Oracle Support - Value Chain Planning Community</a><br>
REM prompt <a href="https://support.oracle.com/rs?type=doc\&id=1389560.2" target="_blank">
REM prompt Information Center: Advanced Supply Chain Planning (Doc ID 1389560.2)</a><br>
REM prompt </p></font></td></tr></tbody>
REM prompt </table><BR><BR>
REM
prompt <table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">
prompt   <tbody>
prompt   <tr>
prompt     <td>
prompt       <p>Please refer to the following documents on Database Initialization Parameters for Oracle E-Business Suite.<br>
prompt <a href="https://support.oracle.com/rs?type=doc\&id=396009.1" target="_blank">
prompt Database Initialization Parameters for Oracle E-Business Suite Release 12(Doc ID 396009.1)</a><br>
prompt </p>
prompt       </td>
prompt    </tr>
prompt    </tbody>
prompt </table><BR>
prompt <a href="#top"><font size="-1">Back to Top</font></A><BR><BR>

REM ****************************************************************************************
REM *******                         Feedback                                         *******
REM ****************************************************************************************

prompt <a name="section5"></a><B><font size="+2">Feedback</font></B><BR><BR>

prompt <table border="1" name="NoteBox" cellpadding="10" bordercolor="#C1A90D" bgcolor="#FEFCEE" cellspacing="0">
prompt   <tbody>
prompt   <tr>
prompt     <td>
prompt       <p><B>Still have questions?</B><BR>
prompt Click <a href="https://community.oracle.com/message/12785050" target="_blank">here</a> to provide FEEDBACK for the <font color="#FF0000"><b><font size="+1">Database Parameter Settings Analyzer Script</font></b></font>,
prompt and offer suggestions, improvements, or ideas to make this proactive script more useful.<br>
prompt <font color="#FF0000"><b><font size="+1">- OR -</font></b></font><br>
prompt Click <a href="https://community.oracle.com/community/support/oracle_e-business_suite/technology_stack_-_ebs" target="_blank">here</a> to collaborate with industry peers about
prompt <font color="#FF0000"><b><font size="+1">Database Initialization Parameter Settings</font></b></font> on My Oracle Support and search for solutions or post new questions about Database Initialization Parameter Settings in EBS.<br>
prompt As always, you can email the author directly <A HREF="mailto:takayuki.anzai@oracle.com?subject=%20Database%20Parameter%20Settings%20Analyzer%20Feedback">here</A><BR>
prompt Be sure to include the output of the script for review.
prompt       </p>
prompt       </td>
prompt    </tr>
prompt    </tbody>
prompt </table><BR>
prompt <a href="#top"><font size="-1">Back to Top</font></A><BR>


REM
REM ******************** End of the Report *************************
REM

begin
  select to_char(sysdate,'hh24:mi:ss') into :et_time from dual;
end;
/

declare
  st_hr1 varchar2(10);
  st_mi1 varchar2(10);
  st_ss1 varchar2(10);
  et_hr1 varchar2(10);
  et_mi1 varchar2(10);
  et_ss1 varchar2(10);
  hr_fact varchar2(10);
  mi_fact varchar2(10);
  ss_fact varchar2(10);
begin
  dbms_output.put_line('<br>PL/SQL Script was started at:'||:st_time);
  dbms_output.put_line('<br>PL/SQL Script is complete at:'||:et_time);
  st_hr1 := substr(:st_time,1,2);
  st_mi1 := substr(:st_time,4,2);
  st_ss1 := substr(:st_time,7,2);
  et_hr1 := substr(:et_time,1,2);
  et_mi1 := substr(:et_time,4,2);
  et_ss1 := substr(:et_time,7,2);

  if et_hr1 >= st_hr1 then
    hr_fact := to_number(et_hr1) - to_number(st_hr1);
  else
    hr_fact := to_number(et_hr1+24) - to_number(st_hr1);
  end if;
  if et_ss1 >= st_ss1 then
    mi_fact := to_number(et_mi1) - to_number(st_mi1);
    ss_fact := to_number(et_ss1) - to_number(st_ss1);
  else
    mi_fact := (to_number(et_mi1) - to_number(st_mi1))-1;
    ss_fact := (to_number(et_ss1)+60) - to_number(st_ss1);
  end if;
  dbms_output.put_line('<br><br>Total time taken to complete the script: '||hr_fact||' Hrs '||mi_fact||' Mins '||ss_fact||' Secs');
end;
/

prompt </HTML>

spool off
set heading on
set feedback on
set verify on
exit
;
