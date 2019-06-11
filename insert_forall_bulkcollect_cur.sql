Если есть необходимость вставлять много строк, то варианта всего два (и они уже оба упоминались):
1) Генерировать столько инсертов, сколько строк нужно вставить.
2) Сформировать запрос, формирующий необходимое множество данных и вставить все множетсво сразу.

Ой ли? :)
Зависит от клиента. Используйте синтаксис value (), но
1. OCI: производится биндинг массивов. Далее единственный exec и весь буфер влетает в таблицы.
2. PL/SQL: используйте "forall". Очень похоже на п.1.


----пример инсерта с измерением времени исполнения-------------
DROP TABLE parts1;
CREATE TABLE parts1 (
  pnum INTEGER,
  pname VARCHAR2(15)
);
 
DROP TABLE parts2;
CREATE TABLE parts2 (
  pnum INTEGER,
  pname VARCHAR2(15)
);

DECLARE
  TYPE NumTab IS TABLE OF parts1.pnum%TYPE INDEX BY PLS_INTEGER;
  TYPE NameTab IS TABLE OF parts1.pname%TYPE INDEX BY PLS_INTEGER;
  pnums   NumTab;
  pnames  NameTab;
  iterations  CONSTANT PLS_INTEGER := 50000;
  t1  INTEGER;
  t2  INTEGER;
  t3  INTEGER;
BEGIN
  FOR j IN 1..iterations LOOP  -- populate collections
    pnums(j) := j;
    pnames(j) := 'Part No. ' || TO_CHAR(j);
  END LOOP;

  t1 := DBMS_UTILITY.get_time;

  FOR i IN 1..iterations LOOP
    INSERT INTO parts1 (pnum, pname)
    VALUES (pnums(i), pnames(i));
  END LOOP;

  t2 := DBMS_UTILITY.get_time;

  FORALL i IN 1..iterations
    INSERT INTO parts2 (pnum, pname)
    VALUES (pnums(i), pnames(i));

  t3 := DBMS_UTILITY.get_time;

  DBMS_OUTPUT.PUT_LINE('Execution Time (secs)');
  DBMS_OUTPUT.PUT_LINE('---------------------');
  DBMS_OUTPUT.PUT_LINE('FOR LOOP: ' || TO_CHAR((t2 - t1)/100));
  DBMS_OUTPUT.PUT_LINE('FORALL:   ' || TO_CHAR((t3 - t2)/100));
  COMMIT;
END;


--пример------
CREATE OR REPLACE PROCEDURE increase_salary (
    department_id_in   IN employees.department_id%TYPE,
    increase_pct_in    IN NUMBER)
 IS
    TYPE employee_ids_t IS TABLE OF employees.employee_id%TYPE
            INDEX BY PLS_INTEGER; 
    l_employee_ids   employee_ids_t;
    l_eligible_ids   employee_ids_t;

    l_eligible       BOOLEAN;
 BEGIN
    SELECT employee_id
      BULK COLLECT INTO l_employee_ids
      FROM employees
     WHERE department_id = increase_salary.department_id_in;

    FOR indx IN 1 .. l_employee_ids.COUNT
    LOOP
       check_eligibility (l_employee_ids (indx),
                          increase_pct_in,
                          l_eligible);

       IF l_eligible
       THEN
          l_eligible_ids (l_eligible_ids.COUNT + 1) :=
             l_employee_ids (indx);
       END IF;
    END LOOP;

    FORALL indx IN 1 .. l_eligible_ids.COUNT
       UPDATE employees emp
          SET emp.salary =
                   emp.salary
                 + emp.salary * increase_salary.increase_pct_in
        WHERE emp.employee_id = l_eligible_ids (indx);
 END increase_salary;
 ------------с лимитом---------------
 DECLARE
   c_limit PLS_INTEGER := 100;

   CURSOR employees_cur
   IS
      SELECT employee_id
        FROM employees
       WHERE department_id = department_id_in;

   TYPE employee_ids_t IS TABLE OF 
      employees.employee_id%TYPE;

   l_employee_ids   employee_ids_t;
BEGIN
   OPEN employees_cur;

   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employee_ids
      LIMIT c_limit;

      EXIT WHEN l_employee_ids.COUNT = 0;
   END LOOP;
END;
--------с вызовом исключений-------------
BEGIN
   FORALL indx IN 1 .. l_eligible_ids.COUNT SAVE EXCEPTIONS
      UPDATE employees emp
         SET emp.salary =
                emp.salary + emp.salary * increase_pct_in
       WHERE emp.employee_id = l_eligible_ids (indx);
EXCEPTION
   WHEN OTHERS
   THEN
      IF SQLCODE = -24381
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            DBMS_OUTPUT.put_line (
                  SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
               || ‘: ‘
               || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
      ELSE
         RAISE;
      END IF;
END increase_salary;

--

set serveroutput on
declare
  type t_pk is table of t1.pk%type;
  type t_c1 is table of t1.c1%type;
  v_pks t_pk;
  v_c1s  t_c1;
  v_new_pks t_pk;

  ex_dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_dml_errors, -24381);

begin
  -- get the batch of rows you want to insert
  select level newpk, 'value' c1
  bulk collect into v_pks, v_c1s
  from dual connect by level <= 10;

  -- bulk bind insert, saving exceptions and capturing the newly inserted
  -- records
  forall i in v_pks.first .. v_pks.last save exceptions 
    insert into t1 (pk, c1)
    values (v_pks(i), v_c1s(i)) returning pk bulk collect into v_new_pks;

exception
 -- Process the exceptions 
  when ex_dml_errors then
    for i in 1..SQL%BULK_EXCEPTIONS.count loop
      DBMS_OUTPUT.put_line('Error: ' || i || 
          ' Array Index: ' || SQL%BULK_EXCEPTIONS(i).error_index ||
          ' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
    end loop;
end;
/


################################################

declare

cursor cur_val_xi
  is
select 1703971607 from dual;

        
  type t_cur_val_xi is table of cur_val_xi%rowtype index by pls_integer;

  v_tt  t_cur_val_xi;
  
begin
 open cur_val_xi;
  loop

    fetch cur_val_xi bulk collect into v_tt limit 2000;
       
    exit when v_tt.count = 0;
       
    forall i in indices of v_tt
      insert into XREF_IDENTIFICATION_UPD values v_tt(i);
         
   commit;
    
  end loop;
   
  close cur_val_xi; 
  
end;
