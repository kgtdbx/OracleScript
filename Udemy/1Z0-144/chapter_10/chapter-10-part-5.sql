delete products;
select * from products;

create or replace procedure add_products
(p_prod_id number,p_prod_name varchar2:='Ukowun',p_prod_type  varchar2 default 'Ukowun')
is
begin

  insert into products values (p_prod_id,p_prod_name,p_prod_type);
  dbms_output.put_line(p_prod_id||' '||p_prod_name||'  inserted ' );
 commit;

exception
when others then
dbms_output.put_line ('error in insert '||p_prod_id||' '||p_prod_name);
dbms_output.put_line (sqlcode);
dbms_output.put_line (sqlerrm);
end;
-----------

begin
add_products(10,'PC');
add_products(10,'Labtop');
add_products(20,'Keyboard');
end; 

select * from products;
-----------------------------------------------------------------------------------------------

delete products;
select * from products;


create or replace procedure add_products
(p_prod_id number,p_prod_name varchar2:='Ukowun',p_prod_type  varchar2 default 'Ukowun')
is
begin

  insert into products values (p_prod_id,p_prod_name,p_prod_type);
  dbms_output.put_line(p_prod_id||' '||p_prod_name||'  inserted ' );
 commit;
end;
-----------

begin
add_products(10,'PC');
add_products(10,'Labtop');
add_products(20,'Keyboard');
end;

select * from products;
----------------------------------------------------------------------------------------------

delete products;
select * from products;


create or replace procedure add_products
(p_prod_id number,p_prod_name varchar2:='Ukowun',p_prod_type  varchar2 default 'Ukowun')
is
begin

  insert into products values (p_prod_id,p_prod_name,p_prod_type);
  dbms_output.put_line(p_prod_id||' '||p_prod_name||'  inserted ' );

end;
-----------

begin
add_products(10,'PC');
add_products(10,'Labtop');
add_products(20,'Keyboard');
 commit;
end;

select * from products;

