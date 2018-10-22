ORACLE: Ускорение pl/sql циклов и пользовательских функций
Метки: оптимизация, BULK COLLECT, forall, inline, oracle, pl/sql, sql, udf
Продолжаю тему оптимизации запросов ORACLE, хотелось бы коснуться циклов по SQL запросам в PLSQL.
Возможно, многим это уже известно, но все же.
Чаще всего запросы в plsql пишутся следующим образом:
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
У такого подхода есть существенный минус - для каждой записи из SELECT, ORACLE приходится менять контекст выполнения с SQL на PLSQL.
Такого рода операцию можно выполнить без смены контекста 2 способами:
* UPDATE без цикла - в простом варианте ДА, но не все циклы так просты.
* Использовать BULK COLLECT и FORALL
С BULK COLLECT и FORALL запрос получится следующий:
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
Разберем код:
* Создаем Тип "employee_ids_t" - это ассоциативный массив, где ключ PLS_INTEGER, а значение = employees.employee_id%TYPE
* l_employee_ids - это переменная типа employee_ids_t
* BULK COLLECT INTO - поместить отобранные select идентификаторы в коллекцию l_employee_ids. Помещаются все записи разом, в отличии от обычного INTO (одна запись)
* Конструкция FORALL - выполняет UPDATE столько раз, сколько записей в коллекции l_employee_ids и используя данные из нее.

Стоит заметить, что FORALL это не цикл, а конструкция языка, так что он имеет ряд особенностей:
* Внутри FORALL может быть только 1 DML запрос. Если нужно несколько запросов, то нужно использовать несколько FORALL
* При выполнении FORALL не происходит переключения контекста. Весь UPDATE выполняется за 1 раз, что дает значительное преимущество в скорости.

Стоит заметить, что время на смену контекста также расходуется при вызове пользовательских функций в DML запросах.
К примеру:
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
* Контекст будет сменен столько раз, сколько записей отберется в SELECT
Чтобы избежать смены контекста, можно :
* Попробовать объявить функцию как INLINE "PRAGMA INLINE "
* Или как используемую только в DML "PRAGMA UDF"
* Но лучший вариант в данном случае - отказаться от функции и сознательно денормализировать запрос до чистого SQL.