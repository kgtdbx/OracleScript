drop table customer;

create table customer
(cust_id number,
 name varchar2(100),
 birthday date
);

--case 1 ( 2 procedure differ in number of parameters
create or replace package overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date);
 procedure add_cust(p_id number,p_name varchar2);
end;
-------
create or replace package body overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date)
 is 
 begin
 insert into customer (cust_id,name,birthday)
 values (p_id,p_name,p_bd);
 commit;
 
 end;
 
 procedure add_cust(p_id number,p_name varchar2)
 is 
 begin
 insert into customer (cust_id,name)
 values (p_id,p_name);
 commit;
 
 end;
end;

execute overload_proc.add_cust(1,'jack','1-jan-90');

select * from customer;

execute overload_proc.add_cust(2,'ford');

select * from customer;
-------------------------------------------------

--case 2 ( 2 procedure same number of parameters, differ in type)
create or replace package overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date);
 procedure add_cust(p_id number,p_name varchar2);
 procedure add_cust(p_name varchar2,p_id number);
end;
-------
create or replace package body overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date)
 is 
 begin
 insert into customer (cust_id,name,birthday)
 values (p_id,p_name,p_bd);
 commit;
 
 end;
 
 procedure add_cust(p_id number,p_name varchar2)
 is 
 begin
 insert into customer (cust_id,name)
 values (p_id,p_name);
 commit;
 
 end;
 
  procedure add_cust(p_name varchar2,p_id number)
 is 
 begin
 insert into customer (name,cust_id)
 values (p_name,p_id);
 commit;
 
 end;
 
end;

execute overload_proc.add_cust('ali',3);

select * from customer;
-------------------------------------------------------------------

--case 3 ( 2 procedure same number of parameters, same family)
create or replace package overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date);
 procedure add_cust(p_id integer,p_name varchar2,p_bd date);
end;

create or replace package body overload_proc
is
 procedure add_cust(p_id number,p_name varchar2,p_bd date)
 is 
 begin
 insert into customer (cust_id,name,birthday)
 values (p_id,p_name,p_bd);
 commit;
 end;
 
 procedure add_cust(p_id integer,p_name varchar2,p_bd date)
 is 
 begin
 insert into customer (cust_id,name,birthday)
 values (p_id,p_name,p_bd);
 commit;
  end;
  
 end;

execute overload_proc.add_cust(10.6,'dina','1-jan-90');
------------------------------------------------------------------

--function case 1
create or replace package overload_funcion
is
  function f1 (p1 number) return number;
  function f1 (p1 number) return varchar2;

end;

create or replace package body overload_funcion
is
  function f1 (p1 number) return number
  is
  begin
  return p1;
  end;
  
  function f1 (p1 number) return varchar2
  is 
  begin
  return p1||'hi';
  end;
  
end;

select overload_funcion.f1(1) from dual;

-------------------------------------------------------
--function case 2

create or replace package overload_funcion
is
  function f1 (p1 number) return number;
  function f1 (p1 varchar2) return varchar2;

end;

create or replace package body overload_funcion
is
  function f1 (p1 number) return number
  is
  begin
  return p1;
  end;
  
  function f1 (p1 varchar2) return varchar2
  is 
  begin
  return p1||'hi';
  end;
  
end;

select overload_funcion.f1(1) from dual;

select overload_funcion.f1('1') from dual;







 