define OWNER='SCOTT';
define PARENT_TABLE ='TEST_1' ;
 
select level,lpad('> ',5*(level-1)) || to_char(child) "TABLE" from
(select b.table_name "PARENT",a.table_name "CHILD"
from all_constraints a,all_constraints b 
where a.owner=b.owner 
and a.owner='&OWNER'
and a.constraint_type='R'
and a.r_constraint_name=b.constraint_name 
order by b.table_name,a.table_name) 
start with parent='&PARENT_TABLE'
connect by prior child = parent ;

---------

SELECT DISTINCT table_name, 
                constraint_name, 
                column_name, 
                r_table_name, 
                position, 
                constraint_type 
FROM   (SELECT uc.table_name, 
               uc.constraint_name, 
               cols.column_name, 
               (SELECT table_name 
                FROM   user_constraints 
                WHERE  constraint_name = uc.r_constraint_name) r_table_name, 
               (SELECT column_name 
                FROM   user_cons_columns 
                WHERE  constraint_name = uc.r_constraint_name 
                       AND position = cols.position)           r_column_name, 
               cols.position, 
               uc.constraint_type 
        FROM   user_constraints uc 
               inner join user_cons_columns cols 
                       ON uc.constraint_name = cols.constraint_name 
        WHERE  constraint_type != 'C') 
START WITH table_name = '&&tableName' 
           AND column_name = '&&columnName' 
CONNECT BY NOCYCLE PRIOR table_name = r_table_name 
                         AND PRIOR column_name = r_column_name; 