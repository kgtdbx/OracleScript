create or replace package pkg
is
procedure p1;
end;

create or replace package body pkg
is
  procedure p1
  is
  begin 
  dbms_output.put_line ('welcome');
  end;

end;

create or replace procedure call_from_pkg
is
begin
pkg.p1;
end;


select * from user_objects
where lower(object_name) in ('pkg','call_from_pkg');

create or replace package body pkg
is
  procedure p1
  is
  begin 
  dbms_output.put_line ('welcome');
   if 1=1 then
   dbms_output.put_line ('yes');
   end if;
  end;
end;


select * from user_objects
where lower(object_name) in ('pkg','call_from_pkg');

create or replace package pkg
is
procedure p1;
procedure p2;
end;

create or replace package body pkg
is
  procedure p1
  is
  begin 
  dbms_output.put_line ('welcome');
  end;

  procedure p2
  is
  begin 
  dbms_output.put_line ('welcome');
  end;
end;

select * from user_objects
where lower(object_name) ='call_from_pkg';


