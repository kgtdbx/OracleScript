DECLARE

TYPE t_rec_conric IS RECORD 
  (
  n_list_id indices_listing_alt_idtfcn.indices_listing_id%TYPE,
  n_list_cd indices_listing_alt_idtfcn.indices_listing_alt_cd%TYPE
  );


t_conric t_rec_conric;

BEGIN

select t.indices_listing_id, t.indices_listing_alt_cd into t_conric
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
	         and 	  il.indices_listing_id = 1558487                                                           
           ) w
   where w.rn = 1
) t;
DBMS_OUTPUT.put_line(t_conric.n_list_cd||' '||TO_CHAR(t_conric.n_list_id));

END;
