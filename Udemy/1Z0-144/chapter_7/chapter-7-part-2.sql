select * from DEPARTMENTS
where department_id=10;

create table copy_DEPARTMENTS
as select * from  DEPARTMENTS where 1=2;

select * from copy_DEPARTMENTS;
------------------------------
declare
type t_dept is record
( v_dept_id departments.department_id%type,
  v_dept_name  departments.department_name%type,
  v_dept_manager  departments.manager_id%type,
  v_dept_loc  departments.location_id%type
);

v_dept t_dept;

begin

  select department_id,department_name,manager_id,location_id
  into v_dept 
  from DEPARTMENTS  where department_id=10;
  
  insert into copy_DEPARTMENTS values v_dept;
  /*
  insert into copy_DEPARTMENTS values (v_dept.v_dept_id,v_dept.v_dept_name,.....
  */
end;

select * from copy_DEPARTMENTS;

---------------------


--using the %rowtype
declare

v_dept DEPARTMENTS%rowtype;

begin

select department_id,department_name,manager_id,location_id
into v_dept 
from DEPARTMENTS  where department_id=10;

insert into copy_DEPARTMENTS values v_dept;
/*
insert into copy_DEPARTMENTS values (v_dept.department_id,v_dept.department_name,.....
*/

end;

select * from copy_DEPARTMENTS;
----------------------------------------------------



--using the %rowtype  in update 
declare

v_dept DEPARTMENTS%rowtype;

begin

v_dept.department_id:=10;
v_dept.department_name:='test';

update copy_DEPARTMENTS
set row=v_dept;

end;

select * from copy_DEPARTMENTS;
------------------------------------------------------------------


