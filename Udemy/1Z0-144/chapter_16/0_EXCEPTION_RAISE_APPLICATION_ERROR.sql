delete from DEPARTMENTS

declare
e_fk_err exception;
pragma EXCEPTION_INIT (e_fk_err, -02292);
begin
    delete from DEPARTMENTS;
exception
    when e_fk_err then
    RAISE_APPLICATION_ERROR (-20001, 'error');
end;


declare
e_fk_err exception;
pragma EXCEPTION_INIT (e_fk_err, -02292);
begin
    delete from DEPARTMENTS;
exception
    when e_fk_err then
    RAISE_APPLICATION_ERROR (-20001, 'error',true);
end;