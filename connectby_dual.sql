select sqrt(avg(mod(level,2)*5000))/8000 from dual
connect by level <110000


insert into spdata(id, radius, location)
select
   id,
   dbms_random.value(10000,20000),
   sdo_geometry(2001, 8307,
       sdo_point_type (floor(dbms_random.value(-180,180)),floor(dbms_random.value(-90,90)) , null),
       null, null
   )
from (
select level id
from dual
connect by level <= 100
) data;
 
commit;
