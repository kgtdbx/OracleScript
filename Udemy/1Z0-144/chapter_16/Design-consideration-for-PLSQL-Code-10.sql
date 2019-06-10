--INDICES OF

select * from employees
where employee_id in (100,101,102,103);


declare
type emp_table_type is table of number index by binary_integer;
emp_table emp_table_type;
begin
emp_table(1):=100;
emp_table(2):=101;
emp_table(3):=102;
emp_table(100):=103;
  dbms_output.put_line(emp_table.first);
    dbms_output.put_line(emp_table.last);
  forall i in emp_table.first..emp_table.last save exceptions
  
  update employees
  set salary=salary+5
  where employee_id =emp_table(i);
  commit;

end;
------------------------------------

declare
type emp_table_type is table of number index by binary_integer;
emp_table emp_table_type;
begin
emp_table(1):=100;
emp_table(2):=101;
emp_table(3):=102;
emp_table(100):=103;
  dbms_output.put_line(emp_table.first);
    dbms_output.put_line(emp_table.last);
  forall i in INDICES OF emp_table
  
  update employees
  set salary=salary+5
  where employee_id =emp_table(i);
  commit;

end;
---------

select * from employees
where employee_id in (100,101,102,103);