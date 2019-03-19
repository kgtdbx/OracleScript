--https://blogs.oracle.com/sql/how-to-find-the-next-business-day-and-add-or-subtract-n-working-days-with-sql

REM   Script: Functions to find the next business day, add/subtract N working days and get working days between dates
REM   A comparison of methods to calculate next working day, add or subtract N working days and find working days between dates.

create table calendar_dates ( 
  calendar_day   date not null primary key, 
  is_working_day varchar2(1) not null, 
  constraint is_midnight check ( calendar_day = trunc ( calendar_day ) ) 
);

-- Populate the table with 20 years' worth of data. Saturday and Sunday are non-working days.
insert into calendar_dates  
with dates as (  
  select date'2007-12-31'+level dt  
  from   dual  
  connect by level <= 7300  
)  
  select dt,   
         case   
           when to_char(dt, 'fmday') in ('sunday', 'saturday')   
           then 'N' else 'Y'  
         end  
  from dates;

commit


-- Find Next Working Day Case Expression
-- To find the next working day, skipping weekends:

- If today is Friday, add three days to jump to Monday
- If today is Saturday, add two days to jump to Monday
- Otherwise add one day
select calendar_day,   
       to_char(calendar_day, 'fmday') dy,   
       case    
         when to_char(calendar_day, 'fmday') = 'friday' then    
           calendar_day + 3   
         when to_char(calendar_day, 'fmday') = 'saturday' then    
           calendar_day + 2   
         else   
           calendar_day + 1   
       end next_day   
from   calendar_dates   
where  calendar_day between date'2018-01-01' and date'2018-01-07';

-- Add or Subtract N Working Days Loop
-- Naive add-N working days solution. From the start date, loop until the counter of working days equals N. Only increment the counter if today is a working day (Mon-Fri). If N is negative this will subtract this number of working days.
create or replace function add_n_working_days (    
  start_date date, working_days pls_integer   
) return date as   
  start_date_midnight date := trunc ( start_date );   
  end_date date := start_date_midnight;   
  counter  pls_integer := 0;   
begin   
     
  if working_days = 0 then   
    end_date := start_date_midnight;   
  elsif to_char(start_date_midnight, 'fmdy') in ('sat', 'sun') then   
    /* Move to next Monday when adding;   
       previous Friday when subtracting */   
    if sign(working_days) = 1 then    
      end_date := next_day(start_date_midnight, 'monday');   
    else   
      end_date := next_day(start_date_midnight-7, 'friday');   
    end if;   
  end if;   
     
  while (counter < abs(working_days)) loop   
    end_date := end_date + sign(working_days);   
    if to_char(end_date, 'fmdy') not in ('sat', 'sun') then   
      counter := counter + 1;   
    end if;   
  end loop;   
     
  return end_date;   
     
end add_n_working_days; 
/

-- Add or Subtract N Working Days Optimized Loop
-- An optimized loop. You can skip the number of weeks N spans minus one. Then loop through the remaining days. This gives an upper bound of 10 working days to loop through. You can only use this to skip weekends. This fails if you need to skip other non-working days.
create or replace function add_n_working_days_optimized (     
  start_date date, working_days pls_integer    
) return date as    
  end_date            date;    
  start_date_midnight date := trunc ( start_date );    
  counter             pls_integer := 0;    
  remaining_days      pls_integer;    
  weeks               pls_integer;    
begin    
      
  if working_days = 0 then    
    end_date := start_date_midnight;    
  elsif to_char(start_date_midnight, 'fmdy') in ('sat', 'sun') then    
    if sign(working_days) = 1 then     
      end_date := next_day(start_date_midnight, 'monday');    
    else    
      end_date := next_day(start_date_midnight-7, 'friday');    
    end if;    
  else    
    end_date := start_date_midnight;    
  end if;    
      
  if abs(working_days) <= 5 then    
    remaining_days := working_days;    
  else    
    weeks := floor ( abs(working_days) / 5 ) * sign(working_days);    
    end_date := end_date + ( weeks * 7 );    
    remaining_days := mod ( working_days, 5 );    
  end if;    
      
  while (counter < abs(remaining_days)) loop    
    end_date := end_date + sign(working_days);    
    if to_char(end_date, 'fmdy') not in ('sat', 'sun') then    
      counter := counter + 1;    
    end if;    
  end loop;    
      
  return end_date;    
      
end add_n_working_days_optimized; 
/

-- Get Working Days Between Dates Loop
-- Naive way to find how many working days there are between two dates. Loop through the number of days between start and end, incrementing a counter if it's a weekday (Mon-Fri).
create or replace function get_working_days_between (    
  start_date date, end_date date   
) return pls_integer as   
  counter    pls_integer := 0;   
  date_range pls_integer;   
begin   
   
  date_range := end_date - start_date;   
     
  for dys in 1 .. abs( date_range ) loop   
    if to_char (   
      start_date + ( dys * sign ( date_range ) ), 'fmdy'   
    ) not in ('sat', 'sun') then   
      counter := counter + 1;   
    end if;   
  end loop;   
     
  return counter;   
     
end get_working_days_between; 
/

-- Add or Subtract N Working Days SQL Loop
-- Data driven add-N working days. This accounts for non-working days between Monday and Friday, such as public holidays. This loops through the dates until the counter reaches N working days. If N is negative, this will subtract this many working days.
create or replace function add_n_working_days_sql_loop (    
  start_date date, working_days pls_integer   
) return date as   
  end_date            date;   
  start_date_midnight date := trunc ( start_date );   
  counter             pls_integer := 0;   
  date_cur            sys_refcursor;   
  date_rec            calendar_dates%rowtype;   
begin   
   
  if working_days = 0 then   
    end_date := start_date_midnight;   
  elsif working_days < 0 then   
    open date_cur for   
      select * from calendar_dates   
      where  calendar_day < start_date_midnight   
      and    is_working_day = 'Y'   
      order  by calendar_day desc;   
  else   
    open date_cur for   
      select * from calendar_dates   
      where  calendar_day > start_date_midnight   
      and    is_working_day = 'Y'   
      order  by calendar_day;   
  end if;   
     
  loop   
       
    fetch date_cur into date_rec;   
       
    end_date := date_rec.calendar_day;   
    counter := counter + 1;   
       
    exit when counter > abs ( working_days );   
       
  end loop;   
     
  close date_cur;   
     
  return end_date;   
     
end add_n_working_days_sql_loop; 
/

-- Add or Subtract N Working Days SQL Loop Bulk Collection
-- You can improve the performance of the previous loop by using bulk collection. This is most beneficial for "large" values of N.
create or replace function add_n_working_days_sql_bulk (    
  start_date date, working_days pls_integer   
) return date as   
  end_date            date;   
  start_date_midnight date := trunc ( start_date );   
  counter             pls_integer := 0;   
  date_cur            sys_refcursor;   
  fetch_limit         pls_integer := 100;   
     
  type date_arr is table of    
    calendar_dates%rowtype index by pls_integer;   
     
  date_rec          date_arr;   
  beyond_date_limit exception;   
begin   
   
  if working_days = 0 then   
    end_date := start_date_midnight;   
  elsif working_days < 0 then   
    open date_cur for   
      select * from calendar_dates   
      where  calendar_day <= start_date_midnight   
      and    is_working_day = 'Y'   
      order  by calendar_day desc;   
  else   
    open date_cur for   
      select * from calendar_dates   
      where  calendar_day >= start_date_midnight   
      and    is_working_day = 'Y'   
      order  by calendar_day;   
  end if;   
     
  if date_cur%isopen then   
    <<row_loop>> loop   
      fetch date_cur bulk collect into date_rec limit fetch_limit;   
         
      if date_rec.count = 0 then   
        raise beyond_date_limit;   
      end if;   
         
      counter := counter + 1;   
     
      if abs (working_days) < ( counter * fetch_limit ) then   
        end_date := date_rec( mod ( abs (working_days), fetch_limit ) + 1 ).calendar_day;   
        exit row_loop ;   
      else   
        end_date := date_rec( date_rec.last ).calendar_day;   
      end if;   
          
    end loop;   
       
    close date_cur;   
  end if;   
     
  return end_date;   
   
exception   
  when beyond_date_limit then   
    raise_application_error(-20001, 'Date: ' || start_date || ' add ' || working_days || ' out of range');   
     
end add_n_working_days_sql_bulk; 
/

-- Add or Subtract N Working Days SQL
-- The pure SQL method to find the next working day. This uses lead or lag for adding or subtracting N days respectively. This processes all the rows before/after the start date. This gives similar performance whatever the value of N. It's notably slower than the loop methods.
create or replace function add_n_working_days_sql (    
  start_date date, working_days pls_integer   
) return date as   
  end_date date;   
  start_date_midnight date := trunc ( start_date );   
begin   
     
  if working_days = 0 then   
    end_date := start_date_midnight;   
  elsif working_days > 0 then   
    with dates as (   
      select * from calendar_dates   
      where  calendar_day >= start_date_midnight   
      and    is_working_day = 'Y'   
    ), plus_n_days as (   
      select lead(calendar_day, working_days)    
               over (order by calendar_day) dt   
      from   dates   
    )   
      select min(dt) into end_date from plus_n_days;   
  else   
    with dates as (   
      select * from calendar_dates   
      where  calendar_day <= start_date_midnight   
      and    is_working_day = 'Y'   
    ), minus_n_days as (   
      select lag(calendar_day, abs(working_days))    
               over (order by calendar_day) dt   
      from   dates   
    )   
      select max(dt) into end_date from minus_n_days;     
  end if;   
     
  return end_date;   
     
end add_n_working_days_sql; 
/

-- Add or Subtract N Working Days SQL Optimized
-- You can make the pure SQL solution faster by supplying an upper (or lower bound) of dates to search. This is the longest stretch of consecutive non-working days you expect N to span. Ideally you should make safety_margin data driven. This allows you to adapt when holidays are announced.
create or replace function add_n_work_days_sql_opt (    
  start_date date, working_days pls_integer   
) return date as   
  end_date            date;   
  start_date_midnight date := trunc ( start_date );   
  safety_margin       pls_integer := 10;   
begin   
     
  if working_days = 0 then   
    end_date := start_date_midnight;   
  elsif working_days > 0 then   
    with dates as (   
      select * from calendar_dates   
      where  calendar_day between start_date_midnight    
                          and start_date_midnight + ( working_days / 5 * 7 ) + safety_margin   
      and    is_working_day = 'Y'   
    ), plus_n_days as (   
      select lead(calendar_day, working_days)    
               over (order by calendar_day) dt   
      from   dates   
    )   
      select min(dt) into end_date from plus_n_days;   
  else   
    with dates as (   
      select * from calendar_dates   
      where  calendar_day between start_date_midnight + ( working_days / 5 * 7 ) - safety_margin   
                          and start_date_midnight   
      and    is_working_day = 'Y'   
    ), minus_n_days as (   
      select lag(calendar_day, abs(working_days))    
               over (order by calendar_day) dt   
      from   dates   
    )   
      select max(dt) into end_date from minus_n_days;        
  end if;   
     
  return end_date;   
     
end add_n_work_days_sql_opt; 
/

-- Get Working Days Between Dates SQL
-- This calculates the working days between two dates, including the end date. To exclude it, change <= to < in the comparison to end_date.

This also assumes that start_date <= end_date. A complete solution should have logic to verify this!
create or replace function get_working_days_between_sql (    
  start_date date, end_date date   
) return pls_integer as   
  num_days pls_integer := 0;   
begin   
   
  select count(*)    
  into   num_days   
  from   calendar_dates   
  where  is_working_day = 'Y' 
  and    calendar_day > trunc ( start_date ) 
  and    calendar_day <= trunc ( end_date );   
     
  return num_days;   
     
end get_working_days_between_sql; 
/

-- Query to validate that all the functions calculate add N in the same way. This should return no rows. It includes the non-data driven functions. So it only works when Saturday and Sunday are the only non-working days!
with rws as (  
  select rownum-15 x from dual  
  connect by level <= 31  
), dates as (  
  select date'2018-03-01' + (level/3) dt from dual  
  connect by level <= 45  
), add_n as (  
  select x, dt,  
         add_n_working_days(dt, x) lp,  
         add_n_working_days_optimized(dt, x) opt,  
         add_n_working_days_sql(dt, x) sq,  
         add_n_working_days_sql_bulk(dt, x) bk,  
         add_n_work_days_sql_opt(dt, x) sopt  
  from   rws   
  cross join dates  
)  
  select * from add_n  
  where  lp <> opt  
  or     opt <> sq  
  or     bk <> sq  
  or     sopt <> bk  
  or     sopt is null


-- A script to test the performance of these methods. The time of one execution is in microseconds, so this does 100,000 calls of the method to give meaningful results.
create or replace procedure time_add_n (   
  fn_name varchar2, days int  
) as  
  res         date;  
  start_time  pls_integer;  
  run_time    pls_integer;  
  iterations  pls_integer := 100000;  
    
  --assert_fn_name varchar2(ora_max_name_len); 
  assert_fn_name varchar2(32000); 
  
begin  
  /* SQL injection check */  
  assert_fn_name := dbms_assert.sql_object_name (fn_name);  
    
  start_time := dbms_utility.get_time();  
  for i in 1 .. iterations loop  
    execute immediate 'begin  
  :res := ' || assert_fn_name || '(date''2018-01-01'', :days) ;  
end;' using out res, days;  
     
  end loop;  
  run_time := dbms_utility.get_time() - start_time;  
    
  /* Output the time / execution in hsecs */  
  dbms_output.put_line('N = ' || days || ' time ' ||   
     run_time || ' /exec ' || ( run_time / iterations ) || ' hsecs'  
  );  
end time_add_n; 
/

-- Performance Test Script
-- Script to test the performance of each method for increasing values of N. LiveSQL has low timeout thresholds. So this only does two calls. Comment out the rest to test in your environment.
begin    
   
  dbms_output.put_line ( ' **** add_n_working_days **** ' );   
  time_add_n('add_n_working_days', 1);   
  time_add_n('add_n_working_days', 5);   
/*  time_add_n('add_n_working_days', 10);   
  time_add_n('add_n_working_days', 20);   
  time_add_n('add_n_working_days', 50);   
  time_add_n('add_n_working_days', 75);   
  time_add_n('add_n_working_days', 100);   
   
  dbms_output.put_line ( ' **** add_n_working_days_optimized **** ' );   
  time_add_n('add_n_working_days_optimized', 1);   
  time_add_n('add_n_working_days_optimized', 5);   
  time_add_n('add_n_working_days_optimized', 10);   
  time_add_n('add_n_working_days_optimized', 50);   
  time_add_n('add_n_working_days_optimized', 100);   
   
  dbms_output.put_line ( ' **** add_n_working_days_sql **** ' );   
  time_add_n('add_n_working_days_sql', 1);   
  time_add_n('add_n_working_days_sql', 5);   
  time_add_n('add_n_working_days_sql', 10);   
  time_add_n('add_n_working_days_sql', 50);   
  time_add_n('add_n_working_days_sql', 100);   
     
  dbms_output.put_line ( ' **** add_n_working_days_sql_loop **** ' );   
  time_add_n('add_n_working_days_sql_loop', 1);   
  time_add_n('add_n_working_days_sql_loop', 5);   
  time_add_n('add_n_working_days_sql_loop', 10);   
  time_add_n('add_n_working_days_sql_loop', 50);   
  time_add_n('add_n_working_days_sql_loop', 100);   
   
  dbms_output.put_line ( ' **** add_n_working_days_sql_bulk **** ' );   
  time_add_n('add_n_working_days_sql_bulk', 1);   
  time_add_n('add_n_working_days_sql_bulk', 5);   
  time_add_n('add_n_working_days_sql_bulk', 10);   
  time_add_n('add_n_working_days_sql_bulk', 50);   
  time_add_n('add_n_working_days_sql_bulk', 100);   
   
  dbms_output.put_line ( ' **** add_n_work_days_sql_opt **** ' );   
  time_add_n('add_n_work_days_sql_opt', 1);   
  time_add_n('add_n_work_days_sql_opt', 5);   
  time_add_n('add_n_work_days_sql_opt', 10);   
  time_add_n('add_n_work_days_sql_opt', 50);   
  time_add_n('add_n_work_days_sql_opt', 100);   
  */   
end; 
/

/*

SQL> 
 **** add_n_working_days **** 
N = 1 time 103 /exec .00103 hsecs
N = 5 time 126 /exec .00126 hsecs
N = 10 time 158 /exec .00158 hsecs
N = 20 time 219 /exec .00219 hsecs
N = 50 time 396 /exec .00396 hsecs
N = 75 time 541 /exec .00541 hsecs
N = 100 time 691 /exec .00691 hsecs

PL/SQL procedure successfully completed


SQL> 
 **** add_n_working_days_optimized **** 
N = 1 time 104 /exec .00104 hsecs
N = 5 time 129 /exec .00129 hsecs
N = 10 time 106 /exec .00106 hsecs
N = 50 time 116 /exec .00116 hsecs
N = 100 time 106 /exec .00106 hsecs

PL/SQL procedure successfully completed


SQL> 
 **** add_n_working_days_sql **** 
N = 1 time 17695 /exec .17695 hsecs
N = 5 time 17028 /exec .17028 hsecs
N = 10 time 17272 /exec .17272 hsecs
N = 50 time 17149 /exec .17149 hsecs
N = 100 time 16788 /exec .16788 hsecs

PL/SQL procedure successfully completed


SQL> 
 **** add_n_working_days_sql_loop **** 
N = 1 time 2417 /exec .02417 hsecs
N = 5 time 2469 /exec .02469 hsecs
N = 10 time 2542 /exec .02542 hsecs
N = 50 time 3006 /exec .03006 hsecs
N = 100 time 3512 /exec .03512 hsecs

PL/SQL procedure successfully completed


SQL> 
 **** add_n_working_days_sql_bulk **** 
N = 1 time 2661 /exec .02661 hsecs
N = 5 time 2677 /exec .02677 hsecs
N = 10 time 2677 /exec .02677 hsecs
N = 50 time 2696 /exec .02696 hsecs
N = 100 time 2884 /exec .02884 hsecs

PL/SQL procedure successfully completed


SQL> 
 **** add_n_work_days_sql_opt **** 
N = 1 time 1622 /exec .01622 hsecs
N = 5 time 1616 /exec .01616 hsecs
N = 10 time 1639 /exec .01639 hsecs
N = 50 time 1817 /exec .01817 hsecs
N = 100 time 2035 /exec .02035 hsecs

PL/SQL procedure successfully completed

*/
