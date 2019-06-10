drop table emp1;
create table emp1 ( emp_id number );

drop table emp2;
create table emp2 ( emp_id number );

begin
insert into emp1 values (1);
insert into emp1 values (2);
insert into emp1 values (3);
insert into emp2 values (1);
insert into emp2 values (2);
insert into emp2 values (3);
commit;
end;

select * from emp1;
select * from emp2;

create or replace procedure delete_any_table
( p_table_name varchar2)
is
v_no_rec number;
begin
execute immediate 'delete from '||p_table_name;
v_no_rec:=sql%rowcount;
commit; --same rules for commit and rollback
dbms_output.put_line(v_no_rec ||' record(s) deleted form '||p_table_name );
end;

execute delete_any_table('emp1');
select * from emp1;

----------------------
--we will do same but using DBMS_SQL

create or replace procedure delete_any_table2
( p_table_name varchar2)
is
v_no_rec number;
v_cur_id number;
begin
v_cur_id:=dbms_sql.open_cursor;
dbms_sql.parse(v_cur_id,'delete from '||p_table_name ,dbms_sql.native);
v_no_rec:=dbms_sql.execute(v_cur_id);
dbms_output.put_line(v_no_rec ||' record(s) deleted form '||p_table_name );
commit;
end;

execute delete_any_table2('emp1');

select * from emp1;
------------------------------------------------------------------------------------------------

delete emp1;

create or replace procedure add_rows 
( p_table_name varchar2,p_value number )
is
begin
EXECUTE IMMEDIATE 'insert into '||p_table_name ||' values(:1) ' using p_value;
end;

EXECUTE add_rows('emp1',10);

SELECT * FROM emp1;
---------------
--WE WILL DO SAME BUT DBMS_SQL

create or replace procedure add_rows2
( p_table_name varchar2,p_value number )
is
v_no_rec number;
v_cur_id number;
V_INSERT VARCHAR2(1000):='INSERT INTO '||p_table_name||' VALUES (:ID)';
begin
v_cur_id:=dbms_sql.open_cursor;
dbms_sql.parse(v_cur_id,V_INSERT ,dbms_sql.native);
dbms_sql.BIND_VARIABLE (v_cur_id,':ID',p_value);
v_no_rec:=dbms_sql.execute(v_cur_id);
dbms_output.put_line(v_no_rec ||' record(s) INSERTED TO '||p_table_name );
commit;
end;

EXECUTE add_rows2('emp1',90);

SELECT * FROM emp1;



