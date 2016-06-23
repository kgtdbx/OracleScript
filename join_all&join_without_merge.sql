--data in t1 and t2 without intersect
set serveroutput on
with t1 as
(
select 1 as id, 'A' as name from dual
union all
select 2 as id, 'B' as name from dual
union all
select 5 as id, 'F' as name from dual
)
, t2 as
(
select 1 as id, 'A2' as last_name from dual
union all
select 2 as id, 'B2' as last_name from dual
union all
select 6 as id, 'F2' as last_name from dual
)
select * from t1 full join t2 on (t1.id=t2.id)
where t1.id is null or t2.id is null;
------------data which include all rows with t1 and t2
set serveroutput on
with t1 as
(
select 1 as id, 'A' as name from dual
union all
select 2 as id, 'B' as name from dual
union all
select 5 as id, 'F' as name from dual
)
, t2 as
(
select 1 as id, 'A2' as last_name from dual
union all
select 2 as id, 'B2' as last_name from dual
union all
select 6 as id, 'F2' as last_name from dual
)
select * from t1 join t2 on (t1.id=t2.id);
--------------data which in t1 and not in t2
set serveroutput on
with t1 as
(
select 1 as id, 'A' as name from dual
union all
select 2 as id, 'B' as name from dual
union all
select 5 as id, 'F' as name from dual
)
, t2 as
(
select 1 as id, 'A2' as last_name from dual
union all
select 2 as id, 'B2' as last_name from dual
union all
select 6 as id, 'F2' as last_name from dual
)
select * from t1 left join t2 on (t1.id=t2.id)
where t2.id is null
---------------data which in t2 and not in t1
set serveroutput on
with t1 as
(
select 1 as id, 'A' as name from dual
union all
select 2 as id, 'B' as name from dual
union all
select 5 as id, 'F' as name from dual
)
, t2 as
(
select 1 as id, 'A2' as last_name from dual
union all
select 2 as id, 'B2' as last_name from dual
union all
select 6 as id, 'F2' as last_name from dual
)
select * from t1 right join t2 on (t1.id=t2.id)
where t1.id is null
