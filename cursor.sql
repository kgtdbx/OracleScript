declare 

begin
  FOR CUR IN (SELECT * FROM irds_schedule)
LOOP

  for cus in (SELECT a.instrument_id, a.market_dt  
              FROM (
                     SELECT ich.instrument_id,ich.market_dt, DENSE_RANK()
                     OVER (PARTITION BY ich.instrument_id ORDER BY ich.market_dt DESC) cnt
                     FROM index_constituent_h ich
                     WHERE 1=1
                     GROUP BY ich.instrument_id, ich.market_dt
                     )a
                      WHERE  a.cnt=cur.day_retention)
    loop
      
    dbms_output.put_line( 'instrument_id ' || cus.instrument_id||' ' || 'market_dt '|| cus.market_dt);
    
      end loop;
END LOOP;
end;
----------неявный курсор------------
--set autoprint off
variable b_rows_del varchar2(30)
declare
v_emp_id employees.employee_id%type :=106;
begin
delete from employees e where e.employee_id = v_emp_id;
:b_rows_del:= (sql%rowcount||' rows deleted');
end;
/
print b_rows_del
------------------------------------

   
