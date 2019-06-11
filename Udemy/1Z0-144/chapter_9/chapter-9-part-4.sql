select * from EMPLOYEES
where EMPLOYEE_ID=15154;

select sum(salary) from employees
where DEPARTMENT_ID=888;

Declare
v_sum_sal number;
begin
   
   select sum(salary) into v_sum_sal
   from employees
   where DEPARTMENT_ID=&dno;
   DBMS_OUTPUT.PUT_LINE('the sum is '||v_sum_sal);
   DBMS_OUTPUT.PUT_LINE(sql%rowcount);
   
   
   EXCEPTION 
   when no_data_found then
   DBMS_OUTPUT.PUT_LINE('no data found');

end;
--------------------------

Declare
v_sum_sal number;
v_er exception;
begin
   
   select sum(salary) into v_sum_sal
   from employees
   where DEPARTMENT_ID=&dno;
   
   if v_sum_sal is not null then 
   DBMS_OUTPUT.PUT_LINE('the sum is '||v_sum_sal);
   DBMS_OUTPUT.PUT_LINE(sql%rowcount);
   else
   raise v_er;
   end if;
  
   EXCEPTION 
   when v_er then
   DBMS_OUTPUT.PUT_LINE('no data found');

end;

------------------

Declare
v_sum_sal number(2);
v_er exception;
begin
   
   begin
   select sum(salary) into v_sum_sal
   from employees
   where DEPARTMENT_ID=&dno;
    
       if v_sum_sal is not null then 
       DBMS_OUTPUT.PUT_LINE('the sum is '||v_sum_sal);
       DBMS_OUTPUT.PUT_LINE(sql%rowcount);
       else
       raise v_er;
       end if;
   
   EXCEPTION 
   when v_er then
   DBMS_OUTPUT.PUT_LINE('no data found');
   end;
   
EXCEPTION    
when others then 
dbms_output.put_line(sqlcode);
dbms_output.put_line(sqlerrm);
end;
