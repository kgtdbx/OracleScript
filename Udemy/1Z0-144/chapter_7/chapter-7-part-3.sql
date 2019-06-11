drop table emp_tel;

create table emp_tel
(emp_id number primary key,
 full_name varchar2(100),
 mob1 varchar2(20),
 mob2 varchar2(20),
 landline varchar2(20)
 )
 
 insert into emp_tel values 
 (1,'khaled alkhudari','+971505914999','+97125914777','+971508105499');
 
 select * from emp_tel
 
declare
 type t_tel is record
   ( v_mob1 emp_tel.mob1%type,
     v_mob2 emp_tel.mob2%type,
     v_landline emp_tel.landline%type
   );
   
  type t_emp_tel is record
  (v_emp_id emp_tel.emp_id%type, 
   v_full_name emp_tel.full_name%type,
   v_tel t_tel
   );
   
   v_rec t_emp_tel;
begin
   select emp_id, full_name,
          mob1,mob2,landline
   into   v_rec.v_emp_id,v_rec.v_full_name,
          v_rec.v_tel.v_mob1, v_rec.v_tel.v_mob2, v_rec.v_tel.v_landline
   from emp_tel
   where emp_id=1;
   DBMS_OUTPUT.PUT_LINE( 'emp_id:'||v_rec.v_emp_id);
    DBMS_OUTPUT.PUT_LINE('landline:'||v_rec.v_tel.v_landline);
end;
   
 
 