select table_name,
       extractvalue(dbms_xmlgen.getxmltype('select count(1) cnt FROM ' ||
                                            table_name),
                    '/ROWSET/ROW/CNT') cnt
from   user_tables t
where  t.table_name in 
('BOND_ALT_IDTFCN', 
 'BOND_COUPON', 
 'BOND_DEAL', 
 'BOND_ISSUER')
order  by to_number(cnt) desc