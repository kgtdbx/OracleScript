-- Create the types for the table function's output collection 
-- and collection elements

CREATE TYPE TickerType AS OBJECT 
(
  ticker VARCHAR2(4),
  PriceType VARCHAR2(1),
  price NUMBER
);

CREATE TYPE TickerTypeSet AS TABLE OF TickerType;

-- Define the ref cursor type

CREATE PACKAGE refcur_pkg IS
  TYPE refcur_t IS REF CURSOR RETURN StockTable%ROWTYPE;
END refcur_pkg;
/

-- Create the table function

CREATE FUNCTION StockPivot(p refcur_pkg.refcur_t) RETURN TickerTypeSet
PIPELINED ... ;
/


/*
Implementing the Native PL/SQL Approach
In PL/SQL, the PIPE ROW statement causes a table function to pipe a row and continue processing. 
The statement enables a PL/SQL table function to return rows as soon as they are produced. 
(For performance, the PL/SQL runtime system provides the rows to the consumer in batches.) 
For example:
*/
CREATE FUNCTION StockPivot(p refcur_pkg.refcur_t) RETURN TickerTypeSet
PIPELINED IS
  out_rec TickerType := TickerType(NULL,NULL,NULL);
  in_rec p%ROWTYPE;
BEGIN
  LOOP
    FETCH p INTO in_rec; 
    EXIT WHEN p%NOTFOUND;
    -- first row
    out_rec.ticker := in_rec.Ticker;
    out_rec.PriceType := 'O';
    out_rec.price := in_rec.OpenPrice;
    PIPE ROW(out_rec);
    -- second row
    out_rec.PriceType := 'C';   
    out_rec.Price := in_rec.ClosePrice;
    PIPE ROW(out_rec);
  END LOOP;
  CLOSE p;
  RETURN;
END;
/

/*
In the example, the PIPE ROW(out_rec) statement pipelines data out of the PL/SQL table function.

The PIPE ROW statement may be used only in the body of pipelined table functions; an error is raised if it is used anywhere else. The PIPE ROW statement can be omitted for a pipelined table function that returns no rows.

A pipelined table function must have a RETURN statement that does not return a value. The RETURN statement transfers the control back to the consumer and ensures that the next fetch gets a NO_DATA_FOUND exception.
*/

--Example 13-6 How to Use a Pipelined Table Function with REF CURSOR Arguments

SELECT * FROM TABLE(StockPivot(CURSOR(SELECT * FROM StockTable)));