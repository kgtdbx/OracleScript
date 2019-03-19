
https://oracle-base.com/articles/misc/string-aggregation-techniques

------------

set SERVEROUTPUT on
declare

v_stmt varchar2(500 char);
v_sql varchar2(1500 char);

ip_table_nm_to      all_tables.table_name%type := 'PRT_EV_EVENTS';
ip_table_nm_from        all_tables.table_name%type := 'EV_EVENTS_RBGT';

begin

with
demotable as
(
  select 1 group_id, date'2018-11-13' date_value from dual union all
  select 1 group_id, date'2018-11-14' date_value from dual union all
  select 1 group_id, date'2018-11-15' date_value from dual union all
  select 1 group_id, date'2018-11-22' date_value from dual 
)

select '''' ||REPLACE(date_values,',',''',''')||'''' into v_stmt 
from
(
select distinct 
    group_id, 
    listagg(date_value, ',') within group (order by date_value) over (partition by group_id) date_values 
from (select group_id, to_char(date_value, 'dd.mm.yyyy') as date_value from demotable) 
group by group_id, date_value
order by group_id);

v_sql :=   'insert'||chr(13)||chr(10)
              ||'  into '||ip_table_nm_to||chr(13)||chr(10)
              ||'select * '||chr(13)||chr(10)
              ||'  from '||ip_table_nm_from||' where reference_date in ('||v_stmt||')'; 
              
DBMS_OUTPUT.PUT_LINE(v_sql);
end;


------------

with
demotable as
(
  select 1 group_id, date'2018-11-13' date_value from dual union all
  select 1 group_id, date'2018-11-14' date_value from dual union all
  select 1 group_id, date'2018-11-15' date_value from dual union all
  select 1 group_id, date'2018-11-22' date_value from dual 
)

select group_id, 
regexp_replace(
    listagg(date_value, ',') within group (order by date_value)
    ,'([^,]+)(,\1)*(,|$)', '\1\3')
from demotable
group by group_id; 

---------------
select 
replace(
    regexp_replace(
     regexp_replace('BBall, BBall, BBall, Football, Ice Hockey ',',\s*',',')            
    ,'([^,]+)(,\1)*(,|$)', '\1\3')
,',',', ') 
from dual

-----

--###############################################--
ops$tkyte%ORA10GR2> create or replace type myTableType as table
  2  of varchar2 (255);
  3  /

Type created.

ops$tkyte%ORA10GR2>
ops$tkyte%ORA10GR2> create or replace
  2  function in_list( p_string in varchar2 ) return myTableType
  3  as
  4      l_string        long default p_string || ',';
  5      l_data          myTableType := myTableType();
  6      n               number;
  7  begin
  8    loop
  9        exit when l_string is null;
 10        n := instr( l_string, ',' );
 11        l_data.extend;
 12        l_data(l_data.count) :=
 13              ltrim( rtrim( substr( l_string, 1, n-1 ) ) );
 14        l_string := substr( l_string, n+1 );
 15   end loop;
 16   return l_data;
 17  end;
 18  /

Function created.

ops$tkyte%ORA10GR2>
ops$tkyte%ORA10GR2> select * from table( in_list(
  2  '793178994,74430189,979777790,934009393,478787739,70731413,107998083,970798439,708179438,807007739,918337439,379348870,300713393,949873993,918091939,377399834,173009933,943774973,939737779,709904389,913339870,70778049,389308349,370744884,74419399,747783183,977799334,848703839,337909303,934089397,194898070,979473977,773989343,149719808,197301103,707397771,4413373,198979370,307987394,377939904,937989733') )
  3  /

COLUMN_VALUE
-------------------------------------------------------------------------------
793178994
74430189
979777790
...
377939904
937989733

41 rows selected.

---------------------



--################################--
select regexp_substr('SMITH,ALLEN,WARD,JONES','[^,]+', 1, level) from dual
  2  connect by regexp_substr('SMITH,ALLEN,WARD,JONES', '[^,]+', 1, level) is not null;


REGEXP_SUBSTR(SMITH,A
----------------------
SMITH
ALLEN
WARD
JONES


We can pass this query to our select statement to get the desired output.


SQL> select * from emp where ename in (
  2  select regexp_substr('SMITH,ALLEN,WARD,JONES','[^,]+', 1, level) from dual
  3  connect by regexp_substr('SMITH,ALLEN,WARD,JONES', '[^,]+', 1, level) is not null );

--################################--



