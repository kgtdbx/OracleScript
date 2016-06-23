DECLARE
CURSOR cur IS
              select t.indices_listing_id, t.indices_listing_alt_cd
              from (
              select      w.indices_listing_alt_cd, 
                          w.indices_listing_id,
                          w.rn 
                   from (    
                        select  ilai.indices_listing_alt_cd, 
                                il.indices_listing_id,
                                row_number()over(partition by ilai.indices_listing_id order by ilai.status_cd ) rn
                         from   indices_listing_alt_idtfcn ilai,
                                indices_listing il
                         where  ilai.indices_listing_id = il.indices_listing_id
                           and  ilai.status_cd in ('A','F')
                           and  il.status_cd = 'A'
                           and  ilai.indices_listing_idtfcn_typ_id=(select  i.clsfctn_ctgry_itm_id
                                                                       from  classification_category_item i
                                                                       where i.clsfctn_ctgry_itm_cd='RIC'
                                                                         and i.effective_dt is null)
                         and     il.indices_listing_id = 1558487                                                           
                         ) w
                 where w.rn = 1
              ) t;


TYPE t_conric IS TABLE OF indices_listing_alt_idtfcn.indices_listing_alt_cd%TYPE INDEX BY BINARY_INTEGER;--VARCHAR2(14);

l_conric t_conric;

v_counter INTEGER := 0;

BEGIN

FOR rec IN cur LOOP
v_counter := v_counter + 1;

l_conric(v_counter) := rec.indices_listing_alt_cd;

DBMS_OUTPUT.put_line('indices_listing_alt_cd: '||' '||l_conric(v_counter));

END LOOP;

END;
