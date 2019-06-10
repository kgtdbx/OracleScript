drop table test_emp;

create table test_emp
( emp_id number,
  first_name varchar2(100) 
);

---now we will compound theses 4 triggers into one trigger

create or replace trigger comp_test
for insert or update or delete
on test_emp
compound trigger
--we can define vaiables here
--x number;
      before statement is
      --y number;
      begin
      DBMS_OUTPUT.PUT_LINE('1');
      end  before statement;
      
      before each row is
      begin
    DBMS_OUTPUT.PUT_LINE('2');
      end before each row;
      
      after each row is
      begin
     DBMS_OUTPUT.PUT_LINE('3');
      end after each row;
      
      after statement is
      begin
      DBMS_OUTPUT.PUT_LINE('4');
      end after statement;
end;


insert into  test_emp
values (1,'mazen');



insert into  test_emp
select employee_id, first_name
from
employees
where department_id = 20;

