select name,value 
from v$parameter
where name='plsql_warnings'
--1--
--Modify the current session's warning settings
/*
dbms_warning.add_warning_setting_cat(
 warning_category  IN VARCHAR2,
 warning_value    IN VARCHAR2,
 scope            IN VARCHAR2)
*/

--now we can modify the setting
begin
dbms_warning.add_warning_setting_cat('SEVERE', 'ENABLE', 'SESSION');
end;

--we can check the new value by
select name,value 
from v$parameter
where name='plsql_warnings'
--or 
SELECT dbms_warning.get_warning_setting_string FROM dual;
--------------------


--2
/*
dbms_warning.add_warning_setting_num(
 warning_number  IN PLS_INTEGER,
 warning_value  IN VARCHAR2,
 scope          IN VARCHAR2);
*/

EXEC dbms_warning.add_warning_setting_num(6002, 'DISABLE', 'SESSION');

SELECT dbms_warning.get_warning_setting_num(6002)
 FROM dual;
 
EXEC dbms_warning.add_warning_setting_num(6002, 'ENABLE', 'SESSION');

SELECT dbms_warning.get_warning_setting_num(6002)
FROM dual;
-----------------------------

--3
/*
dbms_warning.set_warning_setting_string(
 value IN VARCHAR2,
 scope IN VARCHAR2);

*/

exec dbms_warning.set_warning_setting_string('ENABLE:ALL', 'SESSION');

SELECT  dbms_warning.get_warning_setting_string
FROM dual;
--------------------

--4
/*
dbms_warning.get_category(warning_number IN PLS_INTEGER)
 RETURN VARCHAR2

*/
-- severe
 SELECT dbms_warning.get_category(5000)
 FROM dual;

 -- informational
 SELECT dbms_warning.get_category(6002)
 FROM dual;

 -- performance
 SELECT dbms_warning.get_category(7203)
 FROM dual;
 ------------------------------------------
 
 --5
 /*
 dbms_warning.get_warning_setting_cat(warning_category IN VARCHAR2)
 RETURN VARCHAR2
*/

 SELECT dbms_warning.get_warning_setting_cat('SEVERE')
 FROM dual;

 SELECT dbms_warning.get_warning_setting_cat('INFORMATIONAL')
 FROM dual;

SELECT dbms_warning.get_warning_setting_cat('PERFORMANCE')
 FROM dual;

------------
--6

--dbms_warning.get_warning_setting_num(warning_number IN PLS_INTEGER)
--RETURN VARCHAR2 

SELECT dbms_warning.get_warning_setting_num(5000)
FROM dual;

SELECT dbms_warning.get_warning_setting_num(6002)
FROM dual;

SELECT dbms_warning.get_warning_setting_num(7203)
FROM dual; 


