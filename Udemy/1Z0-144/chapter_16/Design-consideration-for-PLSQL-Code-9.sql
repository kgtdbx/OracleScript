--using returning in bulk collect
--but first returning it can be used lik this
create or replace procedure update_sal_x (emp_id number,p_amount number)
is
v_new_sal number;
begin

update employees
set salary=salary +p_amount
where employee_id=emp_id
returning salary into v_new_sal;
dbms_output.put_line('the new sal now is '||v_new_sal);
end;

select * from employees
where employee_id=200;

exec update_sal_x(200,1);



--using returning in bulk collect

drop table ename_test;

create table ename_test
as select employee_id,salary
from employees;

select * from ename_test
order by 1;

declare
type emp_t  is table of ename_test%rowtype;
emp_table emp_t:=emp_t();
emp_new_sal emp_t:=emp_t();
begin
select * bulk collect into emp_table from ename_test ;

 forall i in emp_table.first..emp_table.last
 update ename_test
 set salary=salary/2
 where employee_id=emp_table(i).employee_id
 returning employee_id,salary bulk collect into emp_new_sal;
 
 for i in emp_new_sal.first..emp_new_sal.last
 loop
 dbms_output.put_line(emp_new_sal(i).employee_id||' '||emp_new_sal(i).salary);
 end loop;
end;

---------------










