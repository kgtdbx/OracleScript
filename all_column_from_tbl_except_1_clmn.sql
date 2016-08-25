Как выводить в запросе все столбцы кроме одного, не перечисляя их?
    Моисеенко С.И. (20-02-2012) 
Другими словами, как исключить столбец с известным именем из результата запроса select * from Table?
Перечислять столбцы также приходится в операторе INSERT, исключая из списка автоинкрементируемые столбцы или столбцы, которым нужно присвоить значение по умолчанию. 
Допустим, требуется выбрать все столбцы из таблицы Laptop кроме столбца code. Чтобы вывести все столбцы таблицы, достаточно написать

SELECT * FROM Laptop;
Но чтобы исключить из списка столбец code, мы вынуждены перечислить все остальные столбцы:

SELECT model, speed, ram, hd, price, screen
FROM Laptop;
Было бы неплохо, если мы могли написать что-то типа

SELECT *[^code] FROM Laptop;
Подобная возможность позволила бы нам избежать рутинной работы с вероятностью ошибиться при наборе и пригодилась бы при динамическом формировании запроса, когда заранее не известна ни таблица, ни число столбцов в ней.
Но, увы, такой возможности у нас нет. Зато мы можем сформировать список столбцов с помощью вспомогательного скрипта, чтобы в дальнейшем использовать его результаты в запросах. Это мы можем сделать, используя стандартное представление метаданных, которое называется информационной схемой:

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Laptop' AND
	COLUMN_NAME NOT IN ('code');
Предикат NOT IN мы используем для того, чтобы можно было в перспективе исключать не один, а несколько столбцов. Теперь нам нужно получить результат в виде строки символов, представляющей собой разделенный запятыми перечень столбцов. Для этого нам уже придется использовать нестандартные средства.
SQL Server 
В частности, для SQL Server мы можем это сделать при помощи конструкции FOR XML PATH, заменив попутно с помощью функции REPLACE пробел между именами столбцов на запятые:

SELECT REPLACE(
(SELECT COLUMN_NAME AS 'data()'
 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Laptop' AND
	COLUMN_NAME NOT IN ('code')
ORDER BY ORDINAL_POSITION
FOR XML PATH(''))
,' ',', ');
В принципе, мы в состоянии сформировать требуемый оператор целиком с тем, чтобы его можно было динамически использовать в коде приложения:

SELECT 'SELECT ' +REPLACE(
(SELECT COLUMN_NAME AS 'data()'
 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Laptop' AND
	COLUMN_NAME NOT IN ('code')
ORDER BY ORDINAL_POSITION
FOR XML PATH(''))
,' ',', ') + ' FROM Laptop';
MySQL
В случае MySQL мы можем воспользоваться специальной агрегатной функцией GROUP_CONCAT:

SELECT GROUP_CONCAT(COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'computers' AND
	TABLE_NAME='Laptop' AND
    COLUMN_NAME NOT IN ('code')
ORDER BY ORDINAL_POSITION;
Следует отметить, что в MySQL информационная схема относится не к отдельной базе данных, а ко всему серверу. Поэтому на тот случай, если в разных базах сервера имеются таблицы с одинаковыми именами, в условия отбора нужно добавить предикат с указанием схемы (базы данных): TABLE_SCHEMA='computers'. 
Конкатенация в MySQL выполняется с помощью функции CONCAT. В итоге окончательное решение нашей задачи можно написать так:

SELECT CONCAT('SELECT ',
(SELECT GROUP_CONCAT(COLUMN_NAME)
 FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_SCHEMA='computers' AND
 	TABLE_NAME='Laptop' AND
    COLUMN_NAME NOT IN ('code')
 ORDER BY ORDINAL_POSITION
), ' FROM Laptop');
PostgreSQL
В PostgreSQL задачу представления значений столбца в виде текстового списка можно решить при помощи двух встроенных функций: ARRAY и ARRAY_TO_STRING. Первая из них преобразует выборку в массив значений, а вторая преобразует массив в список. При этом вторым параметром функции ARRAY_TO_STRING задается символ, который будет являться разделителем элементов списка. Теперь решение нашей задачи можно записать в виде:

SELECT 'SELECT ' ||
ARRAY_TO_STRING(ARRAY(SELECT COLUMN_NAME::VARCHAR(50)
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='laptop' AND
    	COLUMN_NAME NOT IN ('code')
	ORDER BY ORDINAL_POSITION
), ', ') || ' FROM Laptop';
Заметим, что для конкатенации строк в PostgreSQL используется стандартный оператор "||", и отметим необходимость явного приведения типа данных столбца COLUMN_NAME (information_schema.sql_identifier) к типу CHAR/VARCHAR.