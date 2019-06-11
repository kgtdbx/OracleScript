create or replace function get_sal_tax
(p_sal number)
return number
is

begin
commit;

 if p_sal<5000 then
 return p_sal* (10/100);
 else
 return p_sal* (15/100);
 end if;

end;

--------

--you can not function in select if the function contain commit;rollbacl
select employee_id, first_name, salary, get_sal_tax(salary)
from employees
where get_sal_tax(salary)>2000
order by get_sal_tax(salary);

--but it will work like this
declare
v number;
begin
v:=get_sal_tax(5000);
DBMS_OUTPUT.put_line(v);
end;

-------------------


create or replace function get_sal_tax
(p_sal number)
return number
is

begin

insert into DEPARTMENTS(DEPARTMENT_ID,DEPARTMENT_NAME)
values (-99,'test');

 if p_sal<5000 then
 return p_sal* (10/100);
 else
 return p_sal* (15/100);
 end if;
 
end;

--------
--you can not use function in select if the function contain dml
select employee_id, first_name, salary, get_sal_tax(salary)
from employees
where get_sal_tax(salary)>2000
order by get_sal_tax(salary);


--but it will work like this
declare
v number;
begin
v:=get_sal_tax(5000);
DBMS_OUTPUT.put_line(v);
end;

select * from  DEPARTMENTS
where DEPARTMENT_ID=-99;
------------------

--you can drop function

drop function get_sal_tax;
