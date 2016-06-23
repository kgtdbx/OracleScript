
--insert с использованием переменной---------------
prompt =========================
prompt Loading new CATEGORY_ITEM into  CLASSIFICATION_CATEGORY_ITEM
prompt =========================

DECLARE
   l_category_id   NUMBER;
BEGIN
   SELECT cc.clsfctn_ctgry_id
     INTO l_category_id
     FROM classification_category cc
    WHERE cc.clsfctn_ctgry_cd = 'RDS Instrument Class';
   
   INSERT INTO classification_category_item cci (clsfctn_ctgry_itm_id,
                                                 clsfctn_ctgry_itm_cd,
                                                 clsfctn_ctgry_itm_name,
                                                 clsfctn_ctgry_id,
                                                 status_cd,
                                                 effective_dt)
        VALUES (seq_clsfctn_ctgry_itm_id.NEXTVAL,
                'INDEX',
                'INDEX',
                l_category_id,
                'A',
                SYSDATE);

   INSERT INTO classification_category_item cci (clsfctn_ctgry_itm_id,
                                                 clsfctn_ctgry_itm_cd,
                                                 clsfctn_ctgry_itm_name,
                                                 clsfctn_ctgry_id,
                                                 status_cd,
                                                 effective_dt)
        VALUES (seq_clsfctn_ctgry_itm_id.NEXTVAL,
                'ETP',
                'ETP',
                l_category_id,
                'A',
                SYSDATE);


   COMMIT;
END;
/
show errors
/
--insert с использованием select----------
insert into classification_category_item (clsfctn_ctgry_itm_id, clsfctn_ctgry_itm_cd, clsfctn_ctgry_itm_name, 
                                          clsfctn_ctgry_id, creator, create_date, status_cd)
select seq_clsfctn_ctgry_itm_id.nextval, 'B', 'B', c.clsfctn_ctgry_id, user, sysdate, 'A'
from classification_category c
where c.clsfctn_ctgry_cd = 'Contract Type';

insert into classification_category_item (clsfctn_ctgry_itm_id, clsfctn_ctgry_itm_cd, clsfctn_ctgry_itm_name, 
                                          clsfctn_ctgry_id, creator, create_date, status_cd)
select seq_clsfctn_ctgry_itm_id.nextval, 'J', 'J', c.clsfctn_ctgry_id, user, sysdate, 'A'
from classification_category c
where c.clsfctn_ctgry_cd = 'Contract Type';

commit;

--MERGE с использованием select--------------------
set define off
prompt Loading classification_category_item...
MERGE into classification_category_item a using (select 
   'WTR' CLSFCTN_CTGRY_ITM_CD,
   'Water' CLSFCTN_CTGRY_ITM_NM,
   null clsfctn_ctgry_itm_name,
   null clsfctn_ctgry_id,
   null creator,
   null create_date,
   null updated_by,
   null  update_date,
   null status_cd,
   null effective_dt from dual) b on (a.clsfctn_ctgry_itm_cd = b.CLSFCTN_CTGRY_ITM_CD and a.clsfctn_ctgry_id = 
 (select c.clsfctn_ctgry_id from classification_category c where c.CLSFCTN_CTGRY_CD = 'Bloomberg Issuer Industry Class')) 
   WHEN MATCHED THEN UPDATE SET CLSFCTN_CTGRY_ITM_NAME ='Water'
        when not matched then
          INSERT
        ( 
   clsfctn_ctgry_itm_id,
   clsfctn_ctgry_itm_cd,
   clsfctn_ctgry_itm_name,
   clsfctn_ctgry_id,
   creator,
   create_date,
   updated_by,
   update_date,
   status_cd,
   effective_dt)values (seq_clsfctn_ctgry_itm_id.nextval,'WTR','Water',(select c.clsfctn_ctgry_id from classification_category c where c.clsfctn_ctgry_cd='Bloomberg Issuer Industry Class'),'IRDS_OWNER',sysdate, 'IRDS_OWNER', sysdate, 'A',sysdate);
commit;
set define on
prompt Done.


--insert с использованием переменной во время процесса sql plus----------
prompt =========================
prompt Loading new CATEGORY_ITEM
prompt =========================
col clsfctn_ctgry_id new_value nCTGRY_ID
select c.clsfctn_ctgry_id
from classification_category c
where c.clsfctn_ctgry_cd = 'Exercise Style';
insert into classification_category_item
(clsfctn_ctgry_itm_id, clsfctn_ctgry_itm_cd, clsfctn_ctgry_itm_name, clsfctn_ctgry_id, creator, create_date, updated_by, update_date, status_cd, effective_dt)
values
(seq_clsfctn_ctgry_itm_id.nextval,'AS','ASIAN',&&nCTGRY_ID,user, sysdate, null, null, 'A', null);
insert into classification_category_item
(clsfctn_ctgry_itm_id, clsfctn_ctgry_itm_cd, clsfctn_ctgry_itm_name, clsfctn_ctgry_id, creator, create_date, updated_by, update_date, status_cd, effective_dt)
values
(seq_clsfctn_ctgry_itm_id.nextval,'B','BERMUDAN',&&nCTGRY_ID,user, sysdate, null, null, 'A', null);
commit;
prompt Done.

--insert с использованием переменных возвращеных из первого insert sql plus---------------------------------------------
DECLARE
  v_cci_id NUMBER;
  v_mp_id NUMBER;
BEGIN
  INSERT INTO classification_category_item
    (clsfctn_ctgry_itm_id,
     clsfctn_ctgry_itm_cd,
     clsfctn_ctgry_itm_name,
     clsfctn_ctgry_id,
     creator,
     create_date,
     updated_by,
     update_date,
     status_cd,
     effective_dt)
  VALUES
    (seq_clsfctn_ctgry_itm_id.nextval,
     'PIP',
     'Per Index Point',
     (SELECT clsfctn_ctgry_id
        FROM classification_category c
       WHERE c.clsfctn_ctgry_cd = 'Trade Unit Measurement Type'),
     'IRDS_OWNER',
     SYSDATE,
     NULL,
     NULL,
     'A',
     NULL)
   RETURNING clsfctn_ctgry_itm_id INTO v_cci_id;

   SELECT cci.clsfctn_ctgry_itm_id 
     INTO v_mp_id
     FROM classification_category_item cci
    WHERE cci.clsfctn_ctgry_itm_cd = 'MAPS TO';

    INSERT INTO classification_item_map
      (clsfctn_map_id,
       prmry_clsfctn_itm_id,
       scnd_clsfctn_itm_id,
       rltnp_clsfctn_itm_id,
       creator,
       create_date,
       updated_by,
       update_date,
       status_cd,
       effective_dt)
    VALUES
      (seq_clsfctn_map_id.nextval,
       v_cci_id,
       v_cci_id,
       v_mp_id,
       USER,
       SYSDATE,
       NULL,
       NULL,
       'A',
       SYSDATE);
END;
/
COMMIT;


---************************************************
declare
procedure add (p_kf varchar2, p_ru varchar2)
is
begin
  insert into kf_ru (kf, ru)
  values (p_kf, p_ru);
exception when dup_val_on_index then null;
end;
begin
	add('300465', '01');
	add('324805', '02');
	add('302076', '03');
	add('303398', '04');
	add('305482', '05');
	add('335106', '06');
	add('311647', '07');
	add('312356', '08');
	add('313957', '09');
	add('336503', '10');
	add('322669', '11');
	add('323475', '12');
	add('304665', '13');
	add('325796', '14');
	add('326461', '15');
	add('328845', '16');
	add('331467', '17');
	add('333368', '18');
	add('337568', '19');
	add('338545', '20');
	add('351823', '21');
	add('352457', '22');
	add('315784', '23');
end;
/
commit;
