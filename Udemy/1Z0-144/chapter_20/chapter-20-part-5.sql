--without wrap
create or replace function get_sum_sal_dept
( dept_id number )  
return number
is
v_sal number;
begin
  select sum(salary)
  into v_sal
  from
  employees
  where department_id =dept_id;
  return v_sal;
 
 exception 
 when others then return null;
end;

select get_sum_sal_dept(90) from dual;

select line,text from user_source
where lower(name)='get_sum_sal_dept';

--with warap

begin
dbms_ddl.create_wrapped
(
      'create or replace function get_sum_sal_dept
      ( dept_id number )  
      return number
      is
      v_sal number;
      begin
        select sum(salary)
        into v_sal
        from
        employees
        where department_id =dept_id;
        return v_sal;
       
       exception 
       when others then return null;
      end;'
);
end;

select get_sum_sal_dept(90) from dual;

select line,text from user_source
where lower(name)='get_sum_sal_dept';


--with wrap dynamic

declare
v1 varchar2(1000):='create or replace function get_sum_sal_dept
                ( dept_id number )  
                return number
                is
                v_sal number;
                begin
                  select sum(salary)
                  into v_sal
                  from
                  employees
                  where department_id =dept_id;
                  return v_sal;
                 
                 exception 
                 when others then return null;
                end;';
begin
dbms_ddl.create_wrapped(v1);
end;
