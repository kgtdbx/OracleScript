declare
v_seq number;

begin

for cur in (select pkg_rl_api.f_gen_group_pack as group_pack ,
           null as pack_id,
           srm.stg_id,
           srm.message_id,
           srm.action_type,
           srm.location,
           srm.isin,
           srm.cusip,
           srm.wkn,
           srm.security_description,
           srm.alias,
           srm.exception_flag,
           srm.restriction_timestamp,
           srm.deal_reference,
           srm.deal_company_reference,
           srm.primary_security_flag,
           srm.instrument_id,
           srm.snapshot_id,
           srm.restriction_type,
           srm.restriction_level,
           srm.restriction_category,
           srm.create_date
           
from stg_rl_message srm
where srm.pack_id is null
and srm.stg_id in (208234,208239))

loop
  v_seq:=seq_rl_stg_id.nextval;
  insert into stg_rl_message   (group_pack,
                              pack_id,
                              stg_id,
                              message_id,
                              action_type,
                              location,
                              isin,
                              cusip,
                              wkn,
                              security_description,
                              alias,
                              exception_flag,
                              restriction_timestamp,
                              deal_reference,
                              deal_company_reference,
                              primary_security_flag,
                              instrument_id,
                              snapshot_id,
                              restriction_type,
                              restriction_level,
                              restriction_category,
                              create_date) values ( cur.group_pack,
                                                    cur.pack_id,
                                                    v_seq,
                                                    cur.message_id,
                                                    cur.action_type,
                                                    cur.location,
                                                    cur.isin,
                                                    cur.cusip,
                                                    cur.wkn,
                                                    cur.security_description,
                                                    cur.alias,
                                                    cur.exception_flag,
                                                    cur.restriction_timestamp,
                                                    cur.deal_reference,
                                                    cur.deal_company_reference,
                                                    cur.primary_security_flag,
                                                    cur.instrument_id,
                                                    cur.snapshot_id,
                                                    cur.restriction_type,
                                                    cur.restriction_level,
                                                    cur.restriction_category,
                                                    cur.create_date);

  
  
update rl_xml_message rxm set stg_id = v_seq
where  rxm.stg_id =cur.stg_id;
 
end loop;

delete from stg_rl_message srm
where srm.stg_id in (208234,208239);

commit;

end;
