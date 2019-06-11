drop table t1;

create table t1
( emp_id number,
 ename varchar2(100)
);

insert into t1 values (1,'ford');
insert into t1 values (2,'aya');

---statement trigger
create or replace trigger t1_b4_update
before update --this timeing + event 
on t1
begin
DBMS_OUTPUT.PUT_LINE(':)');
end;

update t1
set ename=ename||' s';

update t1
set ename=ename||' s'
where emp_id=5555;

------------------------

--row trigger
create or replace trigger t1_b4_update
before update --this timeing + event 
on t1
for each row
begin
DBMS_OUTPUT.PUT_LINE(':)');
end;

update t1
set ename=ename||' s';

update t1
set ename=ename||' s'
where emp_id=5555;


