BEGIN
FOR k IN 1..2014 LOOP 

insert into etp_basket_h 
SELECT * FROM etp_basket@ODS.DBDC.LUXOFT.COM  eb
WHERE 1=1
ORDER BY EB.MARKET_DT;
COMMIT;

END LOOP;

END;
