desc departments;

insert into departments(DEPARTMENT_ID ,DEPARTMENT_NAME)
values (1,null );

--SQL Error: ORA-01400: cannot insert NULL into ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")

begin
insert into departments(DEPARTMENT_ID ,DEPARTMENT_NAME)
values (1,null );

end;
----------------------------------------------
declare
e_insert exception;
pragma exception_init(e_insert,-01400);
begin
    insert into departments(DEPARTMENT_ID ,DEPARTMENT_NAME)
    values (1,null );
    
    exception 
    when e_insert then
    dbms_output.put_line('insert failed');
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);
    
    when others then
    null;
end;
------------------------------------------------

--now the way for creating this code is wrong
-- the update will not executed when there is exp in the first insert
declare
e_insert exception;
pragma exception_init(e_insert,-01400);
begin
      insert into departments(DEPARTMENT_ID ,DEPARTMENT_NAME)
      values (1,null );
      
        update employees
        set employee_id='ss'
        where employee_id=100;
        
      exception 
      when e_insert then
      dbms_output.put_line('insert failed');
      dbms_output.put_line(sqlcode);
      dbms_output.put_line(sqlerrm);

end;
------------------------------------------------------------

--this is the correct code
declare
e_insert exception;
pragma exception_init(e_insert,-01400);
begin     
          begin
            insert into departments(DEPARTMENT_ID ,DEPARTMENT_NAME)
            values (1,null );
          exception 
          when e_insert then
            dbms_output.put_line('insert failed');
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
          end;
          
          begin
             update employees
             set employee_id='ss'
             where employee_id=100;
          exception
          when others then
            dbms_output.put_line('update failed');
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
          end;
          

end;

