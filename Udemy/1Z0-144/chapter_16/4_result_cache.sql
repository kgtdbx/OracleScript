--1 Cache and parallel are only in oracle enterprise editions 
--also the DBA make changes in these values
--parameter shared_pool_size
--parameter result_cache_max_size
--parameter result_cache_mode

/*
sho parameter SHARED_POOL_SIZE
sho parameter RESULT_CACHE_MAX_SIZE
sho parameter RESULT_CACHE_MODE
*/

---SELECT DBMS_RESULT_CACHE.status FROM dual;

/*
SELECT id, type, creation_timestamp, block_count,
       column_count, pin_count, row_count, cache_id
  FROM V$RESULT_CACHE_OBJECTS
 WHERE cache_id = '8fpza04gtwsfr6n595au15yj4y';
*/

/*
RESULT_CACHE_MAX_SIZE
Specifies the memory allocated to the server result cache. To disable the server result cache, set this parameter to 0.
RESULT_CACHE_MAX_RESULT
Specifies the maximum amount of server result cache memory (in percent) that can be used for a single result. Valid values are between 1 and 100. 
The default value is 5%. You can set this parameter at the system or session level.
RESULT_CACHE_REMOTE_EXPIRATION
Specifies the expiration time (in minutes) for a result in the server result cache that depends on remote database objects. 
The default value is 0, which specifies that results using remote objects will not be cached. 
If a non-zero value is set for this parameter, DML on the remote database does not invalidate the server result cache.
*/
/*
To set the result cache mode:
Set the value of the RESULT_CACHE_MODE initialization parameter to determine the behavior of the result cache.
You can set this parameter for the instance (ALTER SYSTEM), session (ALTER SESSION), or in the server parameter file.

MANUAL
Query results can only be stored in the result cache by using a query hint or table annotation. 
This is the default and recommended value.

FORCE
All results are stored in the result cache. If a query result is not in the cache, then the database executes the query and stores the result in the cache. 
Subsequent executions of the same SQL statement, including the result cache hint, retrieve data from the cache. Sessions uses these results if possible. 
To exclude query results from the cache, the /*+ NO_RESULT_CACHE */ query hint must be used.
Note: FORCE mode is not recommended because the database and clients will attempt to cache all queries, 
which may create significant performance and latching overhead. Moreover, because queries that call non-deterministic PL/SQL functions are also cached, 
enabling the result cache in such a broad-based manner may cause material changes to the results.

*/


/*
Managing the Server Result Cache Using DBMS_RESULT_CACHE
The DBMS_RESULT_CACHE package provides statistics, information, and operators that enable you to manage memory allocation for the server result cache. 
Use the DBMS_RESULT_CACHE package to perform operations such as retrieving statistics on the cache memory usage and flushing the cache.

SQL> SET SERVEROUTPUT ON
SQL> EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT

Flushing the Server Result Cache
This section describes how to remove all existing results and purge the result cache memory using the DBMS_RESULT_CACHE package.
To flush the server result cache:
Execute the DBMS_RESULT_CACHE.FLUSH procedure.
*/

create or replace function get_sum_sal_dept
( dept_id number )  
return number result_cache
is
v_sal number;
begin
  select sum(salary)
  into v_sal
  from
  employees
  where department_id =dept_id;
  return v_sal;
  
end;

select get_sum_sal_dept(10) from dual;
select get_sum_sal_dept(20) from dual;
select get_sum_sal_dept(30) from dual;

--now when you do :
select get_sum_sal_dept(10) from dual;
--it should be faster because the resulte is stored in cashe,


--relies_on (employees) is optional 
--This option has become obsolete since version 11G release 2. 
--The database figures out where the function relies on. 
--You can still include the relies_on clause, 
--but it will be for documentation purposes only.
create or replace function get_sum_sal_dept
( dept_id number )  
return number result_cache relies_on (employees)
is
v_sal number;
begin
  select sum(salary)
  into v_sal
  from
  employees
  where department_id =dept_id;
  return v_sal;
  
end;
------------








