select employee_id,first_name,salary,department_id, case department_id 
                                                  when 90 then salary*1.1
                                                  when 60 then salary*1.2
                                                  when 100 then salary*1.3
                                                  else salary
                                                  END new_sal
                                          

from 
employees;

------------------------------------
select employee_id,first_name,salary,department_id, case 
                                                  when department_id=90  then salary*1.1
                                                  when department_id=60 then salary*1.2
                                                  when department_id=100  then salary*1.3                        
                                                  else salary
                                                  END new_sal
                                          

from 
employees
--------------------------------------

--here we use the case as experssion
DECLARE
v_sal number;
v_desc varchar2(100);
BEGIN
  select salary into v_sal
  from employees
  where employee_id=&emp_id;
  
  v_desc:=case 
  when v_sal is null  then 'no salay for the employee'
  when v_sal between 1000 and 3000  then 'salay is low'
  when v_sal between 3001 and 5000 then 'salay is medium'
   when v_sal between 5001 and 10000 then 'salay is good'
  else 'salay is High'
  end ; --here end  not end case 
    
  dbms_output.put_line(v_desc);
  
END;
------------------------

--here we use the case as statement
DECLARE
v_sal number;
v_desc varchar2(100);
BEGIN
  select salary into v_sal
  from employees
  where employee_id=&emp_id;
  
  case 
  when v_sal is null  then 
  dbms_output.put_line('no salay for the employee');
  when v_sal between 1000 and 3000  then
   dbms_output.put_line('salay is low');
  when v_sal between 3001 and 5000 then 
   dbms_output.put_line('salay is medium');
   when v_sal between 5001 and 10000 then 
    dbms_output.put_line('salay is good');
  else 
   dbms_output.put_line('salay is High');
  end case; --here end case

END;


