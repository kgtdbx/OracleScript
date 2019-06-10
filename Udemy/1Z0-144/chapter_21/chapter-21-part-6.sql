drop table products;
drop table all_products;
drop  synonym products ;

create table all_products
(producut_id number,
 producut_name varchar2(100),
 producut_category varchar2(100)
);

insert into all_products values (1,'Sony 52 Inch/Led M0014','TV');

create or replace synonym products for all_products;

select * from all_products;
select * from products;

create or replace view v_all_products
as
select * from products;

create or replace procedure read_from_synonym
is
begin
  for i in (select * from products)
  loop
  null;
  end loop;
  
end;


create or replace procedure read_from_synonym2
is
begin
  for i in (select producut_id from products)
  loop
  null;
  end loop;
  
end;


select * from user_objects 
where lower(object_name) in ('all_products','v_all_products','read_from_synonym','read_from_synonym2');

create or replace synonym products for employees;

select * from user_objects 
where lower(object_name) in ('all_products','v_all_products','read_from_synonym','read_from_synonym2');

select * from products;

exec read_from_synonym;

select * from user_objects 
where lower(object_name) in ('read_from_synonym');

exec read_from_synonym2;

select * from user_objects 
where lower(object_name) in ('read_from_synonym2');

select * from V_ALL_PRODUCTS;

---------------------------------------------------------------------
drop  synonym products ;
drop table products;
drop table all_products;
drop table all_products2;

create table all_products
(producut_id number,
 producut_name varchar2(100),
 producut_category varchar2(100)
);

insert into all_products values (1,'Sony 52 Inch/Led M0014','TV');

create table all_products2 as select * from all_products;

create or replace synonym products for all_products;

select * from all_products;
select * from products;

create or replace view v_all_products
as
select * from products;

select * from user_objects 
where lower(object_name) in ('all_products','v_all_products');

create or replace synonym products for all_products2;

select * from user_objects 
where lower(object_name) in ('all_products','v_all_products');





