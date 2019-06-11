drop table products;

create table products
( prod_id number,
  prod_name varchar2(20),
  prod_type varchar2(20),
  constraint products_pk primary key (prod_id)
);

----------------------------------------------------------------
create or replace procedure add_products
(p_prod_id number,p_prod_name varchar2,p_prod_type  varchar2)
is
begin

  insert into products values (p_prod_id,p_prod_name,p_prod_type);
 commit;

exception
when others then
dbms_output.put_line ('error in insert ');
dbms_output.put_line (sqlcode);
dbms_output.put_line (sqlerrm);
end;

--let try to call the proc in many methods

--1 positional 
execute add_products (1,'Laptop','SW');

select * from products;

--try to miss one parameter 
-- it will give wrong number or types of arguments in call to 'ADD_PRODUCTS'
execute add_products (2,'PC');

--try to enter existing product
--this will go to exception 
execute add_products (1,'Laptop','SW');

-- 2 named

execute add_products (p_prod_id=>2,p_prod_name=>'PC',p_prod_type=>'SW');

select * from products;

execute add_products (p_prod_name=>'Keyboard',p_prod_id=>3,p_prod_type=>'HD');

select * from products;

--3 mixed
execute add_products (4,p_prod_type=>'SW',p_prod_name=>'Windows 10');
select * from products;

--------------------
--using the default value 
--2 ways ( default value or  := )
create or replace procedure add_products
(p_prod_id number,p_prod_name varchar2:='Ukowun',p_prod_type  varchar2 default 'Ukowun')
is
begin

  insert into products values (p_prod_id,p_prod_name,p_prod_type);
 commit;

exception
when others then
dbms_output.put_line ('error in insert ');
dbms_output.put_line (sqlcode);
dbms_output.put_line (sqlerrm);
end;

execute add_products(10);

select * from products;


