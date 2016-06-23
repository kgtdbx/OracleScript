
Oracle/PLSQL: LEAD Function

This Oracle tutorial explains how to use the Oracle/PLSQL LEAD function with syntax and examples.


Description

The Oracle/PLSQL LEAD function is an analytic function that lets you query more than one row in a table at a time without having to join the table to itself. It returns values from the next row in the table. To return a value from a previous row, try using the LAG function.


Syntax

The syntax for the LEAD function in Oracle/PLSQL is:
LEAD ( expression [, offset [, default] ] )
over ( [ query_partition_clause ] order_by_clause )

Parameters or Arguments
expressionAn expression that can contain other built-in functions, but can not contain any analytic functions.offsetOptional. It is the physical offset from the current row in the table. If this parameter is omitted, the default is 1.defaultOptional. It is the value that is returned if the offset goes out of the bounds of the table. If this parameter is omitted, the default is null.

Applies To

The LEAD function can be used in the following versions of Oracle/PLSQL:
•Oracle 12c, Oracle 11g, Oracle 10g, Oracle 9i, Oracle 8i


Example

The LEAD function can be used in Oracle/PLSQL.

Lets look at an example. If we had an orders table that contained the following data:

ORDER_DATE PRODUCT_ID QTY

25/09/2007 1000 20 
26/09/2007 2000 15 
27/09/2007 1000 8 
28/09/2007 2000 12 
29/09/2007 2000 2 
30/09/2007 1000 4 

And we ran the following SQL statement:

select product_id, order_date,
LEAD (order_date,1) over (ORDER BY order_date) AS next_order_date
from orders;

It would return the following result:


PRODUCT_ID ORDER_DATE NEXT_ORDER_DATE

1000 25/09/2007 26/09/2007 
2000 26/09/2007 27/09/2007 
1000 27/09/2007 28/09/2007 
2000 28/09/2007 29/09/2007 
2000 29/09/2007 30/09/2007 
1000 30/09/2007 <NULL> 

Since we used an offset of 1, the query returns the next order_date.

If we had used an offset of 2 instead, it would have returned the order_date from 2 orders later. If we had used an offset of 3, it would have returned the order_date from 3 orders later....and so on.

If we wanted only the orders for a given product_id, we could run the following SQL statement:
select product_id, order_date,
LEAD (order_date,1) over (ORDER BY order_date) AS next_order_date
from orders
where product_id = 2000;

It would return the following result:


PRODUCT_ID ORDER_DATE NEXT_ORDER_DATE

2000 26/09/2007 28/09/2007 
2000 28/09/2007 29/09/2007 
2000 29/09/2007 <NULL> 

In this example, it returned the next order_date for product_id = 2000 and ignored all other orders.
