------case 1    impact on the view when  adding/altering orginal table
DROP TABLE customer;

create table customer
( cust_id number,
  name varchar2(100),
  tel varchar2(10)
);

create or replace view v_customer
as
select cust_id,name
from customer;

create or replace view v2_customer
as
select *
from customer;

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer');

--adding column to table customer will not invalidate v_customer
--this started in 11g

alter table customer
add( dob date);

select * from user_objects
where lower(object_name)in ('customer','v_customer','v2_customer');

--alter column to table customer may or may not invalidate the views
alter table customer
modify tel varchar2(20);

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer');

--here it will compile again 
select * from v2_customer;

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer');
------------------------------------------------------------

------case 2    impact on the function when  adding/altering orginal table
create or replace function get_cust_name
( p_cust_id number)
return varchar2
is
v_name customer.name%type;
begin
select name into v_name
from customer
where cust_id=p_cust_id;
  exception
  when others then return null;
end;

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer','get_cust_name');

--adding col to a table will invalidate the function
alter table customer
add( location number);

select * from user_objects
where lower(object_name)  in ('customer','v_customer','v2_customer','get_cust_name');

--but when you run it, it will compile it again
select get_cust_name(10) from dual;

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer','get_cust_name');

--alter col in table may or may not invalidate the function
alter table customer
modify tel varchar2(300);

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer','get_cust_name');

alter table customer
modify name varchar2(300);

select * from user_objects
where lower(object_name) in ('customer','v_customer','v2_customer','get_cust_name');
-----------------------------

------case 3    impact on the proc when  adding/altering orginal table
create or replace procedure p1
is
begin
for i in (select cust_id from customer)
  loop
  dbms_output.put_line(i.cust_id);
  end loop;

end;

create or replace procedure p2
is
begin
for i in (select * from customer)
  loop
  dbms_output.put_line(i.cust_id);
  end loop;

end;

select * from user_objects
where lower(object_name) in ('p1','p2');

--ading column to proce May or May not invalidate according for the logic of changes 
alter table customer
add( addresss varchar2(100));


select * from user_objects
where lower(object_name) in ('p1','p2');
 
--altering column to proce May or May not invalidate according for the logic of changes                              
alter table customer
modify cust_id number(10);

select * from user_objects
where lower(object_name) in ('p1','p2');