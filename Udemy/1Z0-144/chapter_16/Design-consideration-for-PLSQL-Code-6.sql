begin
dbms_output.put_line(sqlerrm (-12899));
end;
-------------------------------------------------------------

--------------------------------------------------------------

drop table ename;

create table ename
as select distinct first_name from employees;

select first_name  
from ename;
 

declare
type ename_t  is table of varchar2(100);
ename_table ename_t:=ename_t();
c number:=0;
errors number;
begin
for i in (select * from ename )
  loop
  c:=c+1;
  ename_table.extend;
  ename_table(c):=i.first_name;
  end loop;

  forall i in ename_table.first.. ename_table.last save exceptions
  update ename
  set first_name=first_name||' to be added:)' --14 char
  where first_name=ename_table(i);

  exception 
  when others then
   errors := sql%bulk_exceptions.count;
 dbms_output.put_line ('The total number of errors occured are '|| errors);
          for j in 1..errors loop
            dbms_output.put_line ('The error iteration is  '
                                 || sql%bulk_exceptions(j).error_index
                                  || ' and the error code is '
                                || sql%bulk_exceptions(j).error_code
                                 || ' and the error message is '
                                 || sqlerrm ( -sql%bulk_exceptions(j).error_code)
                                );
        end loop;

end;

select * from ename
-----------------------------

drop table ename;

create table ename
as select distinct first_name from employees;

select first_name  
from ename;

declare
type ename_t  is table of varchar2(100);
ename_table ename_t:=ename_t();
c number:=0;
errors number;
begin
  /*
  for i in (select * from ename )
  loop
  c:=c+1;
  ename_table.extend;
  ename_table(c):=i.first_name;
  end loop;
  */
  select first_name bulk collect into ename_table 
  from ename;

  forall i in ename_table.first.. ename_table.last save exceptions
  update ename
  set first_name=first_name||' to be added:)' --14 char
  where first_name=ename_table(i);

  exception 
  when others then
   errors := sql%bulk_exceptions.count;
 dbms_output.put_line ('The total number of errors occured are '|| errors);
          for j in 1..errors loop
            dbms_output.put_line ('The error iteration is  '
                                 || sql%bulk_exceptions(j).error_index
                                  || ' and the error code is '
                                || sql%bulk_exceptions(j).error_code
                                 || ' and the error message is '
                                 || sqlerrm ( -sql%bulk_exceptions(j).error_code)
                                );
        end loop;

end;

select * from ename