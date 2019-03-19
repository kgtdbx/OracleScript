WITH DATA AS (
select table_name,
       partition_name,
       to_date (
          trim (
          '''' from regexp_substr (
                     extractvalue (
                       dbms_xmlgen.getxmltype (
                       'select high_value from all_tab_partitions where table_name='''
                                || table_name
                                || ''' and table_owner = '''
                                || table_owner
                                || ''' and partition_name = '''
                                || partition_name
                                || ''''),
                             '//text()'),
                          '''.*?''')),
          'syyyy-mm-dd hh24:mi:ss')
          high_value_in_date_format
  FROM all_tab_partitions
 WHERE table_name = 'SALES' AND table_owner = 'SH'
 )
 SELECT * FROM DATA
   WHERE high_value_in_date_format < SYSDATE
/

TABLE_NAME           PARTITION_NAME       HIGH_VALU
-------------------- -------------------- ---------
SALES                SALES_Q4_2003        01-JAN-04
SALES                SALES_Q4_2002        01-JAN-03
SALES                SALES_Q4_2001        01-JAN-02
SALES                SALES_Q4_2000        01-JAN-01
SALES                SALES_Q4_1999        01-JAN-00
SALES                SALES_Q4_1998        01-JAN-99
SALES                SALES_Q3_2003        01-OCT-03
SALES                SALES_Q3_2002        01-OCT-02
SALES                SALES_Q3_2001        01-OCT-01
SALES                SALES_Q3_2000        01-OCT-00
SALES                SALES_Q3_1999        01-OCT-99
SALES                SALES_Q3_1998        01-OCT-98
SALES                SALES_Q2_2003        01-JUL-03
SALES                SALES_Q2_2002        01-JUL-02
SALES                SALES_Q2_2001        01-JUL-01
SALES                SALES_Q2_2000        01-JUL-00
SALES                SALES_Q2_1999        01-JUL-99
SALES                SALES_Q2_1998        01-JUL-98
SALES                SALES_Q1_2003        01-APR-03
SALES                SALES_Q1_2002        01-APR-02
SALES                SALES_Q1_2001        01-APR-01
SALES                SALES_Q1_2000        01-APR-00
SALES                SALES_Q1_1999        01-APR-99
SALES                SALES_Q1_1998        01-APR-98
SALES                SALES_H2_1997        01-JAN-98
SALES                SALES_H1_1997        01-JUL-97
SALES                SALES_1996           01-JAN-97
SALES                SALES_1995           01-JAN-96

28 rows selected.

------------------------------------------------------------


CREATE OR REPLACE FUNCTION part_hv_to_date (p_table_owner    IN  VARCHAR2,
                                            p_table_name     IN VARCHAR2,
                                            p_partition_name IN VARCHAR2)
  RETURN DATE
-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/miscellaneous/part_hv_to_date.sql
-- Author       : Tim Hall
-- Description  : Create a function to turn partition HIGH_VALUE column to a date.
-- Call Syntax  : @part_hv_to_date
-- Last Modified: 19/01/2012
-- Notes        : Has to re-select the value from the view as LONG cannot be passed as a parameter.
--                Example call:
--
-- SELECT a.partition_name, 
--        part_hv_to_date(a.table_owner, a.table_name, a.partition_name) as high_value
-- FROM   all_tab_partitions a;
--
-- Does no error handling. 
-- -----------------------------------------------------------------------------------
AS
  l_high_value VARCHAR2(32767);
  l_date DATE;
BEGIN
  SELECT high_value
  INTO   l_high_value
  FROM   all_tab_partitions
  WHERE  table_owner    = p_table_owner
  AND    table_name     = p_table_name
  AND    partition_name = p_partition_name;
  
  EXECUTE IMMEDIATE 'SELECT ' || l_high_value || ' FROM dual' INTO l_date;
  RETURN l_date;
END;
/


---------------------------------
function get_prt_name_by_data
  ( ip_table_owner  in all_tab_partitions.table_owner%type
  , ip_table_name   in all_tab_partitions.table_name%type
  , ip_date         in date
  ) return varchar2 is
    l_prt_name varchar2(30 char);
  begin
    WITH stmt AS (
    select table_name,
           partition_name,
           to_date (
              trim (
              '''' from regexp_substr (
                         extractvalue (
                           dbms_xmlgen.getxmltype (
                           'select high_value from all_tab_partitions where table_name='''
                                    || table_name
                                    || ''' and table_owner = '''
                                    || table_owner
                                    || ''' and partition_name = '''
                                    || partition_name
                                    || ''''),
                                 '//text()'),
                              '''.*?''')),
              'syyyy-mm-dd hh24:mi:ss')
              high_value_in_date_format
      FROM all_tab_partitions
     WHERE table_name = ip_table_name AND table_owner = ip_table_owner)
     SELECT partition_name into l_prt_name
       FROM stmt
       WHERE high_value_in_date_format = ip_date+1;
    if ( l_prt_name is not null )
    then
        return l_prt_name;
    else
        return null;
    end if;
    exception when NO_DATA_FOUND then return null;
              when TOO_MANY_ROWS then return null;
              when others then raise;
  end get_prt_name_by_data;
  
  
  ----------------------------------------

Question:  I have a partitioned table and I need to display the most recent partition created.  How do you display the most recent table partition created?

Answer:  Here is a PL/SQL function by Laurent Schneider that will return the latest partition for any partitioned Oracle table:

WITH FUNCTION d (b BLOB, len number) RETURN DATE IS
d DATE;
BEGIN
   IF DBMS_LOB.SUBSTR (b, 1, 1) = hextoraw('07') and len=83
   THEN
      DBMS_STATS.convert_raw_value (DBMS_LOB.SUBSTR (b, 12, 2), d);
   ELSE
      d := NULL;
   END IF;
RETURN d;
END;

Here is an example of the function to display the most recent partition name.  Note that you could also check the high_value from dba_tab_partitions:


select 
   u.name owner,
   o.name table_name,
   max(d (bhiboundval, hiboundlen)) last_partition
from 
   sys.tabpart$ tp
join 
   sys.obj$ o USING (obj#)
join 
   sys.user$ u ON u.user# = o.owner#
where 
   u.name='MYOWNER'
group by 
   u.name, 
   o.name
order by 
   last_partition desc;
   
--------------------------------------

create table t (
  x date 
) partition by range (x) (
  partition p0 values less than (date'2015-01-01'),
  partition p1 values less than (date'2015-06-01'),
  partition pmax values less than (maxvalue)
);

with xml as (
  select dbms_xmlgen.getxmltype('select table_name, partition_name, high_value from user_tab_partitions where table_name = ''T''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws;

TABLE_NAME PARTITION  HIGH_VALUE                                                                               
---------- ---------- ------------------------------------------------------------------------------------------
T          P0         TO_DATE(' 2015-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')       
T          P1         TO_DATE(' 2015-06-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')       
T          PMAX       MAXVALUE

---------------------------------------   