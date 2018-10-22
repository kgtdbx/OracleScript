ORACLE: ��������� pl/sql ������ � ���������������� �������
�����: �����������, BULK COLLECT, forall, inline, oracle, pl/sql, sql, udf
��������� ���� ����������� �������� ORACLE, �������� �� ��������� ������ �� SQL �������� � PLSQL.
��������, ������ ��� ��� ��������, �� ��� ��.
���� ����� ������� � plsql ������� ��������� �������:
PROCEDURE increase_salary (
   department_id_in   IN employees.department_id%TYPE,
   increase_pct_in    IN NUMBER)
IS
BEGIN
   FOR employee_rec
      IN (SELECT employee_id
            FROM employees
           WHERE department_id =
                    increase_salary.department_id_in)
   LOOP
      UPDATE employees emp
         SET emp.salary = emp.salary + 
             emp.salary * increase_salary.increase_pct_in
       WHERE emp.employee_id = employee_rec.employee_id;
   END LOOP;
END increase_salary;
� ������ ������� ���� ������������ ����� - ��� ������ ������ �� SELECT, ORACLE ���������� ������ �������� ���������� � SQL �� PLSQL.
������ ���� �������� ����� ��������� ��� ����� ��������� 2 ���������:
* UPDATE ��� ����� - � ������� �������� ��, �� �� ��� ����� ��� ������.
* ������������ BULK COLLECT � FORALL
� BULK COLLECT � FORALL ������ ��������� ���������:
CREATE OR REPLACE PROCEDURE increase_salary (
  department_id_in   IN employees.department_id%TYPE,
  increase_pct_in    IN NUMBER)
IS
  TYPE employee_ids_t IS TABLE OF employees.employee_id%TYPE
          INDEX BY PLS_INTEGER; 
  l_employee_ids   employee_ids_t;
BEGIN
  SELECT employee_id
     BULK COLLECT INTO l_employee_ids
    FROM employees
   WHERE department_id = increase_salary.department_id_in;

  FORALL indx IN 1 .. l_employee_ids.COUNT
     UPDATE employees emp
        SET emp.salary =
                 emp.salary
               + emp.salary * increase_salary.increase_pct_in
      WHERE emp.employee_id = l_employee_ids (indx);
END increase_salary;
�������� ���:
* ������� ��� "employee_ids_t" - ��� ������������� ������, ��� ���� PLS_INTEGER, � �������� = employees.employee_id%TYPE
* l_employee_ids - ��� ���������� ���� employee_ids_t
* BULK COLLECT INTO - ��������� ���������� select �������������� � ��������� l_employee_ids. ���������� ��� ������ �����, � ������� �� �������� INTO (���� ������)
* ����������� FORALL - ��������� UPDATE ������� ���, ������� ������� � ��������� l_employee_ids � ��������� ������ �� ���.

����� ��������, ��� FORALL ��� �� ����, � ����������� �����, ��� ��� �� ����� ��� ������������:
* ������ FORALL ����� ���� ������ 1 DML ������. ���� ����� ��������� ��������, �� ����� ������������ ��������� FORALL
* ��� ���������� FORALL �� ���������� ������������ ���������. ���� UPDATE ����������� �� 1 ���, ��� ���� ������������ ������������ � ��������.

����� ��������, ��� ����� �� ����� ��������� ����� ����������� ��� ������ ���������������� ������� � DML ��������.
� �������:
FUNCTION betwnstr (
   string_in      IN   VARCHAR2
 , start_in       IN   INTEGER
 , end_in         IN   INTEGER
)
   RETURN VARCHAR2 
 
....

SELECT betwnstr (last_name, 2, 6) 
  FROM employees
 WHERE department_id = 10
* �������� ����� ������ ������� ���, ������� ������� ��������� � SELECT
����� �������� ����� ���������, ����� :
* ����������� �������� ������� ��� INLINE "PRAGMA INLINE "
* ��� ��� ������������ ������ � DML "PRAGMA UDF"
* �� ������ ������� � ������ ������ - ���������� �� ������� � ����������� ����������������� ������ �� ������� SQL.