drop table emp;

create table emp
(id number,
name varchar2(100)
);

drop table which_fired_first;

create table which_fired_first
(seq number,
 trigger_name varchar2(100)
 );
 
drop sequence s1;

create sequence s1;

create or replace trigger t1
before
insert
on emp
begin
insert into which_fired_first values ( s1.nextval,'t1');
end;


create or replace trigger t2
before
insert
on emp
begin
insert into which_fired_first values ( s1.nextval,'t2');
end;

insert into emp values (1,'khaled');

select * from which_fired_first
order by seq;

delete from which_fired_first


create or replace trigger t2
before
insert
on emp
follows t1
begin
insert into which_fired_first values ( s1.nextval,'t2');
end;

insert into emp values (1,'khaled');

select * from which_fired_first
order by seq;

