drop table student;

create table student
( student_id number,
  first_name varchar2(100),
  birthday date,
  constraint student_pk primary key (student_id)
);


drop sequence student_seq;

create sequence student_seq;

--we need to create a package for insert, delete, query a student

--1 we create the package spec.
create or replace package General_student
is 
   procedure insert_student
   (p_first_name varchar2, p_birthday date);
  
   procedure delete_student
   (p_student_id number);

   function  get_name
   (p_student_id number )
   return varchar2;
   
end;
-------
--2 we create the package body

create or replace package body General_student
is 
   procedure insert_student
   (p_first_name varchar2, p_birthday date)
   is
   begin
   insert into student
   values (student_seq.nextval,p_first_name,p_birthday);
   commit;
   
   exception 
   when others then 
   dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);
   end;
   
  
   procedure delete_student
   (p_student_id number)
   is
   begin
    delete from student
    where student_id =p_student_id ;
      commit;
      
    exception 
    when others then 
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);
   end;
   

   function  get_name
   (p_student_id number )
   return varchar2
   is
   v_name student.first_name%type;
   begin
     select first_name into v_name
     from student
     where student_id=p_student_id;
     
     return v_name;
    
    exception
    when others then 
   return null;
   end;
   
   
end;

-------------------------
execute general_student.insert_student ('khaled ahmed','10-may-81');

execute general_student.insert_student ('samer ahmed','10-may-82');

select * from student;

execute general_student.delete_student(1);

select * from student;

select general_student.get_name (2) from dual;







