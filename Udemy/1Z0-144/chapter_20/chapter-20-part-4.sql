--some other examples on plsql_ccflags
SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

alter session set plsql_ccflags='trace_time:true,maxsizev:2000';

SELECT name, value
FROM v$parameter
WHERE name ='plsql_ccflags' ;

create or replace procedure test_only
is
v varchar2($$maxsizev);
begin
    if $$trace_time then
    dbms_output.put_line(to_char(sysdate,'hh:mi:ss') );
    end if;
    
    for i in 1..1000
    loop
    dbms_output.put_line($$maxsizev);
    end loop;
    
    
    if $$trace_time then
    dbms_output.put_line(to_char(sysdate,'hh:mi:ss') );
    end if;
    
end;


exec test_only;

alter session set plsql_ccflags='trace_time:false,maxsizev:2000';

exec test_only;

--you should compile again 

create or replace procedure test_only
is
v varchar2($$maxsizev);
begin
    if $$trace_time then
    dbms_output.put_line(to_char(sysdate,'hh:mi:ss') );
    end if;
    
    for i in 1..1000
    loop
    dbms_output.put_line($$maxsizev);
    end loop;
    
    
    if $$trace_time then
    dbms_output.put_line(to_char(sysdate,'hh:mi:ss') );
    end if;
    
end;

select * from user_plsql_object_settings
where lower(name)='test_only';

exec test_only;



call dbms_preprocessor.print_post_processed_source
('procedure', 'hr','test_only');
