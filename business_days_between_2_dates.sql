Simple SQL solution that can easily be included in a function

To exclude business holidays, I created a table containing the 2018 Business Holidays that we have and populated it as follow

dba@12Cr2> select *
2 from business_holidays;

HOLIDAY_NAME HOLIDAY
-------------------------------------------------- --------------------
New Years Day 01-Jan-2018 00:00:00
Martin Luther King, Jr. Day 15-Jan-2018 00:00:00
Presidents Day Monday 19-Feb-2018 00:00:00
Memorial Day 28-May-2018 00:00:00
Independence Day 04-Jul-2018 00:00:00
Labor Day 03-Sep-2018 00:00:00
Veterans Day 12-Nov-2018 00:00:00
Thanksgiving 22-Nov-2018 00:00:00
Christmas 25-Dec-2018 00:00:00

9 rows selected.

Yeah we have 9 holidays ... :)

Now If I want to find the Business Days for 2018, excluding weekends and the 9 days above, I run

dba@12Cr2> select sum( business_day ) business_days
2 from (
3 select start_date + ( level - 1 ) current_date,
4 to_char( start_date + ( level - 1 ), 'Day D' ) current_day,
5 level,
6 case
7 when to_char( start_date + ( level - 1 ), 'DY' ) in( 'SAT', 'SUN' ) then 0
8 else 1
9 end business_day
10 from ( select to_date( '&start_date', 'mm/dd/yyyy' ) start_date,
11 to_date( '&end_date', 'mm/dd/yyyy' ) end_date,
12 to_date( '&end_date', 'mm/dd/yyyy' ) - to_date( '&start_date', 'mm/dd/yyyy' ) days_count
13 from dual )
14 where 1 = 1
15 connect by level <= days_count + 1
16 )
17 where 1 = 1
18 and not exists( select 'x'
19 from business_holidays
20 where holiday = current_date );

Enter value for start_date: 01/01/2018
old 10: from ( select to_date( '&start_date', 'mm/dd/yyyy' ) start_date,
new 10: from ( select to_date( '01/01/2018', 'mm/dd/yyyy' ) start_date,
Enter value for end_date: 12/31/2018
old 11: to_date( '&end_date', 'mm/dd/yyyy' ) end_date,
new 11: to_date( '12/31/2018', 'mm/dd/yyyy' ) end_date,
Enter value for end_date: 12/31/2018
Enter value for start_date: 01/01/2018
old 12: to_date( '&end_date', 'mm/dd/yyyy' ) - to_date( '&start_date', 'mm/dd/yyyy' ) days_count
new 12: to_date( '12/31/2018', 'mm/dd/yyyy' ) - to_date( '01/01/2018', 'mm/dd/yyyy' ) days_count

BUSINESS_DAYS
-------------
261

And to verify that this works for Connors example above

dba@12Cr2> /
Enter value for start_date: 01/01/2000
old 10: from ( select to_date( '&start_date', 'mm/dd/yyyy' ) start_date,
new 10: from ( select to_date( '01/01/2000', 'mm/dd/yyyy' ) start_date,
Enter value for end_date: 01/05/2000
old 11: to_date( '&end_date', 'mm/dd/yyyy' ) end_date,
new 11: to_date( '01/05/2000', 'mm/dd/yyyy' ) end_date,
Enter value for end_date: 01/05/2000
Enter value for start_date: 01/01/2000
old 12: to_date( '&end_date', 'mm/dd/yyyy' ) - to_date( '&start_date', 'mm/dd/yyyy' ) days_count
new 12: to_date( '01/05/2000', 'mm/dd/yyyy' ) - to_date( '01/01/2000', 'mm/dd/yyyy' ) days_count

BUSINESS_DAYS
-------------
3

--#############################################--


