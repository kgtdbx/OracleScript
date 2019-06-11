CREATE OR REPLACE PROCEDURE UPDATE_SAL
(P_EMP_ID IN NUMBER, P_AMOUNT IN NUMBER)
IS
--here you define variables
-- n number;
BEGIN

  UPDATE employees
  set salary=salary+P_AMOUNT
  where employee_id=P_EMP_ID;
 commit;
 
exception

WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE (SQLCODE);
DBMS_OUTPUT.PUT_LINE (SQLERRM);

END;
--try to do it in sqlplus

--also the error can be found in user_errors
select * from user_errors
where name='UPDATE_SAL'
-----------------------------------------------------------------------------------------
select * from employees
where employee_id=100;

--call the PROCEDURE alone
execute UPDATE_SAL (100,50);

select * from employees
where employee_id=100;
----------------------------------------------------------------------------------------

--calling the PROCEDURE for a block

begin

UPDATE_SAL (&emp_id,&amount); --UPDATE_SAL (100,50)
end;

select * from employees
where employee_id=100;

--------------------------------------------

select * from user_objects
where object_name='UPDATE_SAL';

select * from user_source
where name='UPDATE_SAL'
order by line;

--to drop the procedure

drop procedure UPDATE_SAL;





