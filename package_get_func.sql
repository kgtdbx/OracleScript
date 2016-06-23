CREATE OR REPLACE PACKAGE pkg_list_tst IS

   FUNCTION f_get_lst(p_Id IN VARCHAR2) RETURN NUMBER;
      
procedure p_insert_listing;      

END pkg_list_tst;

/

CREATE OR REPLACE PACKAGE BODY pkg_list_tst IS

TYPE t_rec_conric IS RECORD 
  (
  n_list_id indices_listing_alt_idtfcn.indices_listing_id%TYPE,
  n_list_cd indices_listing_alt_idtfcn.indices_listing_alt_cd%TYPE
  );

TYPE t_conric IS TABLE OF t_rec_conric INDEX BY VARCHAR2(14);

   l_conric t_conric;

   /*----------------------------------------------------------------------------------------------------------------------------------------------*/
   /*----------------------------------------------------------------------------------------------------------------------------------------------*/
   /*----------------------------------------------------------------------------------------------------------------------------------------------*/
   FUNCTION f_get_lst(p_Id IN VARCHAR2)
      RETURN NUMBER IS
      r_conric t_rec_conric;
   BEGIN
      IF NOT l_conric.Exists(p_Id)
      THEN
          l_conric(p_Id) := r_conric;
         return 1;
      ELSE
        return 0;
      END IF;
   END f_get_lst;

procedure p_insert_listing is
  n number;
begin

insert into qqq
  select *
    from (with q as (select 1 as listing_id, 'A' as Status, 1 as val
                       from dual
                     union all
                     select 1 as listing_id, 'F' as Status, 2 as val
                       from dual
                     union all
                     select 2 as listing_id, 'A' as Status, 3 as val
                       from dual
                     union all
                     select 3 as listing_id, 'F' as Status, 4 as val
                       from dual), w as (select q.*,
                                                row_number() over(partition by listing_id order by status) rn
                                           from q)
           select *
             from w
            order by status)
            where Pkg_Hist_TST.f_Get_LST(listing_id) = 1;

end ;

END pkg_list_tst;
/