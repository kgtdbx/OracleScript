create or replace package cur_pkg
is
 cursor c_emp is
 select employee_id from employees;
 
 procedure open;
 procedure close;
 procedure printnext_20;
end;


create or replace package body cur_pkg is
     procedure open
     is
     begin
       if not c_emp%isopen then 
       open c_emp;
       end if;
     end open;------------
     procedure close
     is 
     begin
       if c_emp%isopen then 
       close c_emp;
       end if;
     end close;------------------------
     procedure printnext_20
     is
     v_emp_id number;
     begin
           for i in 1..20
           loop
            fetch c_emp into v_emp_id;
            dbms_output.put_line(v_emp_id);
              if c_emp%notfound then dbms_output.put_line('no more');
               close c_emp;
              exit;
              end if;
            end loop;
     end printnext_20;
 end cur_pkg;
----------------------------------------------------

begin
cur_pkg.open;
cur_pkg.printnext_20;
end;

begin
cur_pkg.close;
end;



