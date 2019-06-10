--create sequence test_sqnc;

create view test_v(id, country_name) as
select test_sqnc.nextval as id, country_name
from COUNTRIES;

--desc COUNTRIES

select * from locations where country_id in (
select test_sqnc.nextval as id--, country_name
from COUNTRIES);


create table COUNTRIES2 as
select * from COUNTRIES;

delete COUNTRIES2 where COUNTRY_ID in (select test_sqnc.nextval as id--, country_name
from COUNTRIES);

update COUNTRIES2 c2 set c2.COUNTRY_ID = (select c1.COUNTRY_ID--test_sqnc.nextval as id--, country_name
from COUNTRIES c1 where c2.country_name = c1.country_name);

select * from COUNTRIES2;

insert into COUNTRIES2(COUNTRY_ID, COUNTRY_NAME, REGION_ID)
select COUNTRY_ID,  country_name, REGION_ID from COUNTRIES2 where country_id in (
select test_sqnc.nextval as id
from COUNTRIES);

insert into COUNTRIES2(COUNTRY_ID, COUNTRY_NAME, REGION_ID)
with t as (
select test_sqnc.nextval as id, country_name, REGION_ID
from COUNTRIES)
select * from t;


--we can use sequence curval and nextval only for insert stmt in select 
insert into COUNTRIES2(COUNTRY_ID, COUNTRY_NAME, REGION_ID)
select test_sqnc.nextval as id, country_name, REGION_ID
from COUNTRIES;

---------

drop table COUNTRIES2 purge;

drop sequence test_sqnc;


