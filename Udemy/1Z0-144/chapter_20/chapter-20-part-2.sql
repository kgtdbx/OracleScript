SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

alter session set plsql_ccflags='language:1';

SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

--to print this directive
begin
dbms_output.put_line($$language);
dbms_output.put_line($$plsql_ccflags);
end;
  
--to use it in PLSQL code

create or replace function get_curr_lang
return varchar2
is
v_lang varchar2(100);
begin
v_lang:='the curr language in system is '||
  $if $$language=1 $then 'English'
  $else 'Arabic'
  $end
  ;
return v_lang;
end;

select get_curr_lang from dual;

select * from user_plsql_object_settings
where lower(name)='get_curr_lang';

alter session set plsql_ccflags='language:2';

select * from user_plsql_object_settings
where lower(name)='get_curr_lang';

create or replace function get_curr_lang
return varchar2
is
v_lang varchar2(100);
begin
v_lang:='the curr language in system is '||
  $if $$language=1 $then 'English'
  $else 'Arabic'
  $end
  ;
return v_lang;
end;


select * from user_plsql_object_settings
where lower(name)='get_curr_lang';

select get_curr_lang from dual;


-----------------------------

--from left to right 
alter session set plsql_ccflags='plsql_ccflags:true,debug:true,debug:0';

SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

begin
 dbms_output.put_line ($$plsql_ccflags);
end;


begin
  if $$plsql_ccflags then
    dbms_output.put_line('plsql_ccflags value is true');
  end if;

 if $$debug=0 then
    dbms_output.put_line('debug value is 0');
  end if;
  dbms_output.put_line($$ddfdfgf);
end;

--now 
alter session set plsql_warnings='enable:all'

--now it should give warning, but it will not
--the warning only in subprograms
begin
  if $$plsql_ccflags then
    dbms_output.put_line('plsql_ccflags value is true');
  end if;

 if $$debug=0 then
    dbms_output.put_line('debug value is 0');
  end if;
  dbms_output.put_line($$ddfdfgf);
end;


create or replace procedure cc
is
begin
  if $$plsql_ccflags then
    dbms_output.put_line('plsql_ccflags value is true');
  end if;

 if $$debug=0 then
    dbms_output.put_line('debug value is 0');
  end if;
  dbms_output.put_line($$ddfdfgf);
end;


