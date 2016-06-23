select 1 
from dual 
where (case when 1=2 then 1 
when 2=2 then 2 
when 3=2 then 3 
else 4 
end 
)=2

--------pl\sql----------
set serveroutput on
declare
v_emp_id employees.employee_id%type :=100;
v_sal employees.salary%type;
v_res varchar2(30);
begin
select e.salary into v_sal from employees e where e.employee_id = v_emp_id;
v_res:= case when v_sal > 20000 then 'excelent salary'
             when v_sal > 10000 then 'good salary'
             else 'poor salary'
        end;
dbms_output.put_line (v_res);	
end;
----------dif case----------
set serveroutput on
declare
v_emp_id employees.employee_id%type :=100;
v_sal employees.salary%type;
v_res varchar2(30);
begin
select e.salary into v_sal from employees e where e.employee_id = v_emp_id;
case when v_sal > 20000 then 
     dbms_output.put_line ('excelent salary');
     when v_sal > 10000 then 
     dbms_output.put_line ('good salary');
     else 
     dbms_output.put_line ('poor salary');
end case;
end;
--or
set serveroutput on
declare
v_emp_id employees.employee_id%type :=100;
v_sal employees.salary%type;
v_res varchar2(30);
begin
select e.salary into v_sal from employees e where e.employee_id = v_emp_id;
case when v_sal > 20000 then 
     update employees set salary = v_sal/2 where employee_id = v_emp_id;
     dbms_output.put_line ('salary for employee_id = '||v_emp_id||' was apdated');
     when v_sal > 10000 then 
     update employees set salary = v_sal*2 where employee_id = v_emp_id;
     dbms_output.put_line ('salary for employee_id = '||v_emp_id||' was apdated');
     else 
     dbms_output.put_line ('not found salary for update');
end case;
--commit;
end;

--***************************************************
procedure p_run_test (ip_type_sp in varchar2,
                      ip_type_inst in varchar2)
  is
  begin
    case
      when ip_type_sp=CT_HST and ip_type_inst='ETF'
        then
          p_run_history_etf ;

      when ip_type_sp=CT_HST and ip_type_inst='INDEX'
        then
          p_run_history_index;

      when ip_type_sp=CT_CUR and ip_type_inst='ETF'
        then
          p_run_current_etf;

      when ip_type_sp=CT_CUR and ip_type_inst='INDEX'
        then
          p_run_current_index ;
     end case;
  end;
 --***************************************************
 function f_is_val_type_ts(ip_timestamp         in timestamp,
                           ip_is_mandatory in varchar2) return varchar2 deterministic as
 begin
  case
   when ip_is_mandatory = f_get_val_yes
    and ip_timestamp is null
   then return f_get_val_no;
   else null;
  end case;
  return f_get_val_yes;
 exception
  when others
   then return f_get_val_no;
 end;

--*************************************************** 
 function get_obj_type_replaced(p_object_type in varchar2) return varchar2 is
  begin
    case p_object_type
      when c_obj_package then
        return c_obj_package_body;
      when c_obj_type then
        return c_obj_type_body;
      when c_obj_table then
        return c_obj_table_constr;
      else
        return p_object_type;
    end case;
  end get_obj_type_replaced;