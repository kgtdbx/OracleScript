---------------------------------------------------------------------
create or replace package proc_rules_calling
is
 procedure print_emp_details 
 (p_emp_id number);
end;


create or replace package body proc_rules_calling
is
 function get_no_work_days (p_emp_id number)
 return number
 is
 v_hiredate date;
 begin
   select HIRE_DATE into v_hiredate
   from employees
   where EMPLOYEE_ID=p_emp_id;
   return round(sysdate-v_hiredate);
 end;
 procedure print_emp_details 
 (p_emp_id number)
 is
 -- we will call the funcion from this procedure
 --so it should be defined above in order to invoke it
 v_details employees%rowtype;
 begin
 select * into v_details
 from employees
 where EMPLOYEE_ID=p_emp_id;
   dbms_output.put_line( 'id:'||v_details.EMPLOYEE_ID);
   dbms_output.put_line( 'fname:'||v_details.FIRST_NAME);
   dbms_output.put_line( 'salary:'||v_details.salary);
   dbms_output.put_line( 'hire date:'||v_details.HIRE_DATE);
   dbms_output.put_line( 'no of days work:'||get_no_work_days(p_emp_id));
 end;
end;

execute proc_rules_calling.print_emp_details(101);
------------------------------------------------------------------------------

--same example but we will change the order
create or replace package proc_rules_calling
is
 procedure print_emp_details 
 (p_emp_id number);
end;

--it will give error
--'GET_NO_WORK_DAYS' not declared in this scope
create or replace package body proc_rules_calling
is
  procedure print_emp_details 
 (p_emp_id number)
 is
 v_details employees%rowtype;
 begin
 select * into v_details
 from employees
 where EMPLOYEE_ID=p_emp_id;
   dbms_output.put_line( 'id:'||v_details.EMPLOYEE_ID);
   dbms_output.put_line( 'fname:'||v_details.FIRST_NAME);
   dbms_output.put_line( 'salary:'||v_details.salary);
   dbms_output.put_line( 'hire date:'||v_details.HIRE_DATE);
   dbms_output.put_line( 'no of days work:'||get_no_work_days(p_emp_id));
 end;
 
 function get_no_work_days (p_emp_id number)
 return number
 is
 v_hiredate date;
 begin
   select HIRE_DATE into v_hiredate
   from employees
   where EMPLOYEE_ID=p_emp_id;
   return round(sysdate-v_hiredate);
 end;
 
end;
------------------------------------------------------------------
--the solution is to do forward declaration
drop package proc_rules_calling;

create or replace package proc_rules_calling
is
 procedure print_emp_details 
 (p_emp_id number);
end;


create or replace package body proc_rules_calling
is
 function get_no_work_days (p_emp_id number)
 return number;  -- we put the function specification only
 
  procedure print_emp_details 
 (p_emp_id number)
 is
 -- we will call the funcion from this procedure
 --so it should be defined above in order to invoke it
 v_details employees%rowtype;
 begin
 select * into v_details
 from employees
 where EMPLOYEE_ID=p_emp_id;
   dbms_output.put_line( 'id:'||v_details.EMPLOYEE_ID);
   dbms_output.put_line( 'fname:'||v_details.FIRST_NAME);
   dbms_output.put_line( 'salary:'||v_details.salary);
   dbms_output.put_line( 'hire date:'||v_details.HIRE_DATE);
   dbms_output.put_line( 'no of days work:'||get_no_work_days(p_emp_id));
 end;
 
 function get_no_work_days (p_emp_id number)
 return number
 is
 v_hiredate date;
 begin
   select HIRE_DATE into v_hiredate
   from employees
   where EMPLOYEE_ID=p_emp_id;
   return round(sysdate-v_hiredate);
 end;
 
end;

execute proc_rules_calling.print_emp_details(104);


 