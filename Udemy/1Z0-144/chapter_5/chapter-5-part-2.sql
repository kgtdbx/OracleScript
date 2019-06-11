
select * from employees
where department_id = 20;

-----------------------------------
declare
v_rows_updated number:=0;
begin
  update employees
  set salary=salary+100
  where department_id = 20;
  
v_rows_updated:=sql%rowcount;

dbms_output.put_line(' the records that updated: '||v_rows_updated);

end;
------------------------------------
select * from employees
where department_id = 20;


declare
v_rows_exist boolean:=true;
begin
  update employees
  set salary=salary+100
  where department_id = 9999;
  
v_rows_exist:=sql%found;

  if v_rows_exist=false then
  dbms_output.put_line(' the sql contains no records retrieved');
  else
  dbms_output.put_line(' the sql contains  records retrieved '||sql%rowcount);
  end if;
end;

rollback;
