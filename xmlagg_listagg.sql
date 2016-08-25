with x as
(
	select 'four' as a, 4 as b from dual
	union all select 'two', 2 from dual
	union all select 'one', 1 from dual
	union all select 'three', 3 from dual
)
select wm_concat(a) over (order by b) a
	from x
	
------------------	
	select xmlagg(xmlelement(col, table_name||',') order by table_name).extract('/COL/text()').getclobval()  
from all_tables
group by owner;

---------------
select wm_concat(a) 
 from (select a from x order by b)
 
 ----------------
 
 listagg(...)within group(order by ...) 