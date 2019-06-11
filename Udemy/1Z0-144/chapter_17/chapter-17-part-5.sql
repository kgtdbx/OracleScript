--WE CAN USING triggers for default value
drop table customers;

create table customers
( cust_id number,
  name varchar2(100),
  status char(1)
);

create or replace trigger customers_defaulf_status
before
insert
on customers
FOR EACH ROW
begin
 :new.status:='A';
end;

--------

INSERT INTO customers(cust_id,name)
VALUES(1,'OMAR');

SELECT * FROM customers;



