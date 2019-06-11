-- create a function to calc tax on salary 
--if salary <5000 then tax 10%  else 15%

create or replace function get_sal_tax
(p_sal number)
return number
is

begin

 if p_sal<5000 then
 return p_sal* (10/100);
 else
 return p_sal* (15/100);
 end if;
 
end;
---------------------------------

select employee_id, first_name, salary, get_sal_tax(salary)
from employees;

select employee_id, first_name, salary, get_sal_tax(p_sal=>salary)
from employees;

select employee_id, first_name, salary, get_sal_tax(salary)
from employees
where get_sal_tax(salary)>2000
order by get_sal_tax(salary);








