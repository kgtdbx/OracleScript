---1 simple if statement

DECLARE
v_no NUMBER:=&v;
BEGIN
   IF v_no >=10 THEN
   dbms_output.put_line('the number you enterd is >=10');
   END IF;
   
END;
-----------------------------------

---2 simple if statement with else
DECLARE
v_no NUMBER := &v;
BEGIN
   IF v_no >=10 THEN
   dbms_output.put_line('the number you enterd is >=10');
   ELSE
   dbms_output.put_line('number is is less than 10');
   END IF;
   
END;

-------------------------------------

--if /elsif
--This logic need enhancement
--Try to enter negative or value >100

DECLARE
v_grade NUMBER := &v;
BEGIN
   IF v_grade between 90 and 100 THEN
   dbms_output.put_line('the grade is A');
   ELSIF v_grade between 80 and 89 THEN
   dbms_output.put_line('the grade is B');
   ELSIF v_grade between 70 and 79 THEN
   dbms_output.put_line('the grade is C');
    ELSIF v_grade between 60 and 69 THEN
   dbms_output.put_line('the grade is D');
   ELSE
   dbms_output.put_line('the grade is F');
   END IF;
   
END;
---------------------------------


DECLARE
v_grade NUMBER := &v;
BEGIN
  IF v_grade BETWEEN 0 AND 100 THEN
  
     IF v_grade between 90 and 100 THEN
     dbms_output.put_line('the grade is A');
     ELSIF v_grade between 80 and 89 THEN
     dbms_output.put_line('the grade is B');
     ELSIF v_grade between 70 and 79 THEN
     dbms_output.put_line('the grade is C');
      ELSIF v_grade between 60 and 69 THEN
     dbms_output.put_line('the grade is D');
     ELSE
     dbms_output.put_line('the grade is F');
     END IF;
     
  ELSE
  dbms_output.put_line('the grade should be number between 0 and 100');
  END IF;

END;
------------------


/* Write a block the take the employee id as substitute variable
Output message: 'yes, the salary is >=15000' if his salary >=15000
Output message: 'No, the salary is <15000' if his salary <15000
*/

declare
v_sal employees.salary%type;
begin
select salary into v_sal
from employees
where employee_id=&emp_id;

  if v_sal>=15000 then
  dbms_output.put_line('yes, the salary is >=15000');
  else
  dbms_output.put_line('No, the salary is <15000');
  end if;
end;







