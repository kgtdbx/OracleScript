drop table students;

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
  for i in (select * from students)
  loop
  dbms_output.put_line(i.student_id||' '||i.student_name);
  end loop;
  
end;

select * 
from 
user_dependencies
where referenceD_name='STUDENTS';


create or replace procedure print_all_students_from_v1
is
begin
  for i in (select * from v1_students)
  loop
  dbms_output.put_line(i.student_id);
  end loop;
  
end;

select * 
from 
user_dependencies
where referenceD_name='STUDENTS';

--in order to see the direct and indirect dependencies
--we run script called utldtree.sql

@f:\utldtree.sql

select * from user_objects
where lower(object_name) like '%tree%';

exec DEPTREE_FILL ('TABLE','HR','STUDENTS');


SELECT * FROM  DEPTREE
ORDER BY SEQ#

CREATE OR REPLACE PROCEDURE TRT
IS
BEGIN
print_all_students_from_v1;
END;

exec DEPTREE_FILL ('TABLE','HR','STUDENTS');


SELECT * FROM  DEPTREE
ORDER BY SEQ#




 