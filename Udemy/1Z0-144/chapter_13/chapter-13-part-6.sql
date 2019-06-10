--using pl/sql tables in packages
create or replace package emp_pkg
is
type emp_table_type is table of employees%rowtype
index by binary_integer;

procedure get_employees(p_emps out emp_table_type );

end;
-------------------------------
create or replace package body emp_pkg
is
  procedure get_employees(p_emps out emp_table_type )
  is
  begin
    for emp_record in (select * from employees)
    loop
   p_emps( emp_record.employee_id):=emp_record;
    end loop;

  end;
end;
-----------------------------------
declare
v_employees emp_pkg.emp_table_type;
begin
emp_pkg.get_employees(v_employees);
dbms_output.put_line(v_employees(101).first_name);
dbms_output.put_line(v_employees(200).first_name);
end;






