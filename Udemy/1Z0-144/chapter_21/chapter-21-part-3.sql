drop table students;
drop view v1_students;
drop view v2_students;
drop  procedure print_all_students;
drop procedure print_all_students_from_v1;


create table students
(student_id number,
 student_name varchar2(100),
 dob date
 );
 
insert into students(student_id,student_name,dob) values (1,'aya ahmed','1-jan-1980');
insert into students(student_id,student_name,dob) values (2,'sara mahmoud','1-jan-1980');
insert into students(student_id,student_name,dob) values (3,'nabil alail','1-jan-1980');
commit;

select * from students;

create or replace view v1_students
as
select * from students;

create or replace view v2_students
as
select student_id,dob 
from students;

create or replace procedure print_all_students
is
begin
  for i in (select student_id from students)
  loop
  dbms_output.put_line(i.student_id);
  end loop;
  
end;

Create or replace procedure print_all_students_from_v1
is
begin
  for i in (select * from v1_students)
  loop
  dbms_output.put_line(i.student_id);
  end loop;
  
end;


select * from user_objects
where lower(object_name) in 
('v1_students','v2_students','print_all_students','print_all_students_from_v1');

alter table students
modify student_name varchar2(200); 

select * from user_objects
where lower(object_name) in ('v1_students','v2_students','print_all_students','print_all_students_from_v1');

execute PRINT_ALL_STUDENTS_FROM_V1;--now the server will recompile

select * from user_objects
where lower(object_name) in ('v1_students','v2_students','print_all_students','print_all_students_from_v1');

