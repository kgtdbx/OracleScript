--привелегии----
/*select * from user_sys_privs where username='SBOVKUSH';
select * from user_tab_privs where grantee='SBOVKUSH';
select * from user_col_privs where grantee='SBOVKUSH';*/
-------------------
SELECT HS.CODE,HS.CUSTOMER_NO,HS.MOBILE_NO,HS.MOBILE_NO_REF,HS.MIN_NO,HS.MIN_NO_REF,HS.SIM_ESN_NO, 
       HS.STATUS,HSS.EVDO,HSS.EVDO_PWD,HS.DEALER_NO,HS.DATE_TIME_ACTIVATED,HS.DATE_TIME_DEACTIVATED,
       HS.TERM_REASON,HS.COMMENTS,HS.SERVICE,HS.CONTRACT_TYPE_REF,HS.ACTION_TYPE,CU.CC_STAGE||CC.NAME,CU.STAGE_DATE,
       CU.NAME,CU.CUS_TYPE,CU.SUPPRESS,CU.SP_CODE
       
  FROM JAN.HANDSET HS
  RIGHT JOIN JAN.CUSTOMER CU
    ON (CU.CUSTOMER_NO = HS.CUSTOMER_NO)
  JOIN JAN.HANDSET_SERVICE HSS
    ON (HS.CODE = HSS.HANDSET_CODE)
  JOIN JAN.CC_STAGE CC
    ON (CC.SUPPRESS = CU.SUPPRESS AND CC.STAGE = CU.CC_STAGE AND
       CC.SP_CODE = CU.SP_CODE)
where 1=1
--and cu.name like '%PrP%'
and   CU.CUSTOMER_NO= '1514658'
--and   cu.address like  '%Погребняка%'
--and   hs.status in ('A','B')
--and cu. sp_code = '1007982'
--and hs.status = 'A'
--and     hs.code = '101555628'
and hs.MOBILE_NO_ref = '0443536311'
--and   hs.sim_esn_no in ('633830291','09901037350')
--and     hs.contract_type_ref = 'ITC5A'
and rownum <15 

------------------------------------
select * from JAN.HANDSET hss
where
--hss.code = '151465800'
--hss.type_rec = 'R' 
--hss.min_no = '0512001409'
--HSS.STATUS = 'Z'
--HSS.CONTRACT_TYPE_REF LIKE '3G_DAY%'
--HSS.DATE_TIME_DEACTIVATED IS NULL
hss.mobile_no is null
and hss.mobile_no_ref is not null
--hss.mobile_no ='0115120379'--0462006428
--hss.contract_type is not null
--code = '0114410590'
--hss.sp_code = '1107048' 
---customer_no = '1001251'
--HSS.SIM_ESN_NO = '3EBA804F'
--hss.comments like 'Переєстровано%'

select  * from JAN.HANDSET hss
right join JAN.customer c
on(hss.customer_no = c.customer_no)
where 
--hss.cost_centre in null
--c.sp_code = '1161127'
--hss.min_no like '%0020012829%'
--hss.status = 'B'
--hss.sim_esn_no = '09114498536'
--hss.mobile_no = '0332200955'
c.customer_no = '1514658'
--c.name like '%фанас%'
--c.sp_code = '1107048' 
--C.SUPPRESS = 'FGPT'
--AND HSS.MOBILE_NO IS NOT NULL
--hss.CODE = '101663966'
------------------------------------
select CU.CUSTOMER_NO, CU.NAME, cu.company_code 
from JAN.customer cu
where 
--CU.SP_CODE = '1028554'
--C.SUPPRESS = 'FGPT'
--cu.name like '%Бриз%'-- for update
cu.company_code IN ('33661417','36292016','22052546','32739864')
--cu.sortcode IS NULL
--CU.ID_NUMBER IN ('33661417','36292016','22052546','32739864')
--cu.customer_no = '1166740'-- for update
-----------------------активные клиенты=--------------------
SELECT hs.customer_no
FROM   JAN.CUSTOMER CU,
       JAN.HANDSET  HS
WHERE  CU.CUSTOMER_NO = HS.CUSTOMER_NO
--and  CU.SUPPRESS IN ('FGPN')
and    hs.status in ('A','B')
GROUP BY hs.customer_no
HAVING SUM(TO_NUMBER(DECODE(HS.STATUS,'A',1,0)))> 0

---------------------------------CUSTOMER_EMAIL--------------
SELECT * FROM JAN.CUSTOMER_EMAIL_ITC CEI, jan.customer cu
WHERE cei.customer_no = cu.customer_no(+) 
and Cu.CUSTOMER_NO = '9272442'
---------------------------------
SELECT * FROM JAN.HANDSET_CONTRACT hc
WHERE handset_code = '100252525'
hc.contract_type like '%'
------------------------------------дополнительные поля---
SELECT * FROM   JAN.SALES_AUDIT  SA, JAN.LOOKUP lo
where sa.customer_no = '1154862'
and LO.PREFIX(+) = SA.REASON

select  distinct(c.customer_no), lo.descr,c.cus_type,c.disk_bill,C.SUPPRESS from JAN.customer c
join  JAN.LOOKUP lo
--on(c.cus_type = lo.prefix)                           --1 тип клиента
on  (c.disk_bill = lo.prefix)                        --2 доставка счета
--ON C.SUPPRESS = LO.PREFIX                              --3 ЦКК

where 
--c.cus_type in ('FDЧ','FDК')--Физики\Юрики           --1
c.disk_bill in ('AI01','AI02','AI10')-- доставка счетов     --2
--C.SUPPRESS IN ('FGZ','FGW','FGPN','FGA','FGV','FGK','FGPT','FGPV','FGX')  --3	
and rownum<10
-------
SELECT * FROM  JAN.LOOKUP lo
where 
--lo.descr like '%ур%'
lo.prefix IN ('FGZ','FGW','FGPN','FGA','FGV','FGK','FGPT','FGPV','FGX')
----CKK------------
SELECT  c.*
FROM   JAN.CC_STAGE cc,JAN.CUSTOMER c, JAN.LOOKUP lo
WHERE C.CUSTOMER_NO=9272442
AND lo.prefix=c.SUPPRESS
AND CC.SUPPRESS=c.SUPPRESS
AND CC.STAGE=c.CC_STAGE
-------------------------
SELECT * FROM JAN.COST_CENTRE CC
WHERE CC.CODE = '37418' 

-------------------------
SELECT * FROM JAN.HANDSET HS, 
              JAN.HANDSET_ACTION HA
WHERE HS.ACTION_TYPE = HA.CODE(+)
AND HS.CUSTOMER_NO = '1499016'

SELECT  *
FROM    JAN.ALL_COMMENT AC
where --ac.code = 'M0811'
AC.COMMENTS LIKE '%акц%'

------------------------------------
SELECT * FROM JAN.CONTRACT_TARIFF CT
where ct.CONTRACT_TYPE like '%DB_B_1126%'
--CT.DESCRIPTION LIKE '%лужб%'
--абонплата------------

SELECT HS.CONTRACT_TYPE, round(IT.AMOUNT*1.2, 2)ABON
            FROM   JAN.INVOICE_TYPE IT, JAN.HANDSET_INVOICE HI, JAN.HANDSET HS
            WHERE  IT.CODE = HI.INVOICE_TYPE_CODE 
            AND    HI.HANDSET_CODE =  HS.CODE
            AND    HI.ACTIVE = 'Y'
            AND    HS.TYPE_REC = 'T'
            AND    SUBSTR(IT.CHARGE_CODE,1,2) = 'IA'
            and    HS.CONTRACT_TYPE = 'DB_B_1126' 
--------------детализация--------------------
SELECT chr(39)||C.MOBILE_NO                                                            "С номера",
       chr(39)||C.NCH_MOBILE_NO                                                        "На номер",
       C.CALL_DATE_TIME                                                               "Дата время",
     round(c.DURATION/1024,2) 
        /*DECODE(c.DURATION,NULL,'000000',                            
                LPAD(TRUNC(c.DURATION/3600),2,'0')||':'||           
                LPAD(MOD(TRUNC(c.DURATION/60),60),2,'0')||':'||     
                LPAD(MOD(c.DURATION,60),2,'0')
              )  */                                                                 "Продолж-сть",
       round((nvl(C.USED_BUNDLED, 0) + nvl(C.L_USED_BUNDLED, 0) +
             nvl(C.NEW_COST, 0) + nvl(C.LONG_COST, 0)) * 1.2, 2)                       "Стоимость с НДС",
       round((nvl(C.USED_BUNDLED, 0) + nvl(C.L_USED_BUNDLED, 0)) * 1.2, 2)             "Скидка с НДС",
       round((nvl(C.NEW_COST, 0) + nvl(C.LONG_COST, 0)) * 1.2, 2)                      "К оплате с НДС"

FROM   jan.CALL     c,   --j.arch_call  c,
       jan.handset  h,
       jan.customer cu
WHERE  /*C.HANDSET_CODE = h.code
AND    */h.customer_no = cu.customer_no

AND    C.CALL_DATE_TIME BETWEEN TO_DATE('01.01.2013', 'dd.mm.yyyy') AND  
                                TO_DATE('01.03.2013', 'dd.mm.yyyy')- 1 / 86400

--AND    C.Handset_Code = '101675893'
AND    H.CUSTOMER_NO = '9075644'
AND    C.MOBILE_NO = '0442280623'
                     --'0114422963'
AND    c.duration > 0
ORDER  BY 1, 3


------------------заборони----------------
select * from JAN.BAR B

select * from JAN.MOBILE_BAR
where mobile_no = '0552440026'
-------инф-я по номер/оборудование----------
SELECT * FROM  JAN.mobin m
where 1=1--m.msn LIKE '%977f87%'
AND m.msn = 'h7957D998' --is null
and m.sp_code = '1068554'
and m.min_no like '047%'

SELECT * FROM JAN.MOBILE_SN msn  
where 1=1
AND msn.hardware_no = '12105757336'
--AND msn.msn = 'h25c77b93'

SELECT * FROM 
JAN.HISTORY_IMSI_ITC HII
WHERE HII.MDN = '0114401034' 

SELECT * FROM JAN.MOBILE MB
WHERE 1=1
AND   mb.mobile_no = '0114401034'
AND   mb.sp_code = '1033985'
AND   mb.dealer_no is null
AND   mb.service = 'U'
AND   mb.gold_no = 'N'
AND   mb.tariff_code is null
--mb.bar_code = 'C'
mb.mobile_no = '0472384915' for update
--mb.num_type = 'PRP'
------------------------------------
SELECT * FROM  JAN.CUSTOMER_DEFAULT --CUSTOMER для USER_DEFAULT
SELECT * FROM  JAN.CC_STAGE

SELECT * FROM  JAN.USER_DEFAULT

SELECT * FROM JAN.USER_ACCESS UA

SELECT * FROM JAN.SYSTEM_FIELD sf
----доступ--
select *
from dba_users
where account_status = 'OPEN'
--------
select * from SESSION_ROLES
select * from all_users
SELECT clerk as "Клерк" 
FROM jan.JBILL_CLERK jc

SELECT * FROM jan.JBILL_CLERK jc
where jc.clerk = 'OGAVRILYUK' for update
--jc.position_clerk like '%нжен%'

select * from JAN.CLERK_EMAIL_V t
where t.CLERK = 'TANYAFINA'
SELECT * FROM jan.Jbill_Permission
SELECT * FROM jan.Jbill_Usergroup
SELECT * FROM jan.Jbill_Clerk_Det_Itc ji
where ji.clerk = 'TANYAFINA'
SELECT * FROM jan.Jbill_Clerk_Sp
----

SELECT * FROM jan.JBILL_CLERK_SP JC,jan.sp_code_by_company sp
WHERE jc.sp_code = sp.sp_code
and JC.IS_DEFAULT = 'Y'
--AND SP_CODE = '1161124'
and jc.clerk = 'TANYAFINA'

SELECT * FROM  JAN.ADD_PARAMS
SELECT * FROM  JAN.ADD_PARAMS_DATA

----------------------------------
SELECT * FROM jan.Jbill_Clerk_Det_Itc
where clerk = 'OGAVRILYUK'
------------------------------------
SELECT * FROM JAN.DEBTCOLLECTOR
--------------TARIF----------------------
SELECT HS.MOBILE_NO                                                 "НОМЕР_ТЕЛ",
       CT.TARIFF_NAME                                               "ТП"
     
FROM   
       JAN.HANDSET           HS,
       JAN.CONTRACT_TARIFF   CT

WHERE HS.CONTRACT_TYPE_REF = CT.CONTRACT_TYPE(+)
AND   HS.MOBILE_NO = '0116200040'
---------------------------------------------------
SELECT  TR.CODE, TR.NAME, TR.SHORT_NAME
        FROM    JAN.TARIFF TR, JAN.NETWORK NT
        WHERE   NT.CODE = TR.NETWORK_CODE

SELECT * FROM  JAN.NETWORK NT

SELECT * FROM  JAN.TARIFF TR
where tr.name like '%онтакт%'

select * from JAN.HANDSET hss
where 
HSS.CUSTOMER_NO = '1040089'
--HSS.STATUS = 'Z'
HSS.CONTRACT_TYPE_REF LIKE 'KO300%'

SELECT * FROM  JAN.CONTRACT_TARIFF ct
where --ct.TARIFF_NAME like '%ерт%'
substr(ct.CONTRACT_TYPE,1,5) = 'EVD25'
or substr(ct.CONTRACT_TYPE,1,5) = 'EVD40'


select * from JAN.INVOICE_TYPE IT
where it.charge_code like '%DIS%'
------------------------------------

select * from jan.transaction tr
where 
--tr.name = 'CHANGE_DN_OW_ITC'
--tr.clerk = 'UJAROVA'
--and TR.STAGE = 'N'
tr.handset_code = '100252531'
--tr.handset_code = '0552441020'
------------------------------------
select * from jan.history h
where 1=1
--AND H.HARDWARE_NO = '00480009031'

/*AND H.HIS_TIMEDATE BETWEEN TO_DATE('19.03.2013 09:00:01 ', 'DD.MM.YYYY HH24:MI:SS') 
                       AND TO_DATE('20.03.2013 13:00:59 ', 'DD.MM.YYYY HH24:MI:SS')
--and H.COMMENT_CODE = 'M0811'*/

--AND (H.COMMENT_CODE = 'S040R' or H.COMMENT_CODE = 'X')

--AND   h.clerk = 'VALER'
--and (h.comments like ('%іграц%') or h.comments like ('%план%'))
--and h.comments  like ('%Batch%')
--AND H.HIS_TIMEDATE> CURRENT_DATE - INTERVAL '1' DAY
--and h.comments not like ('%ЗБРНО%')
and  h.customer_no = '9145446'
AND (H.COMMENTS LIKE '%0512722087%' or H.COMMENTS LIKE '%0512722150%' or H.COMMENTS LIKE '%0512724135%')
--and h.his_timedate between to_date('05.08.2011','dd.mm.yyyy') AND to_date('30.09.2011','dd.mm.yyyy')
--and h.customer_no = '1152367'
--order by H.HIS_TIMEDATE DESC

--h.comment_code in ('M033','M034')
--h.his_timedate between to_date('01.09.2011','dd.mm.yyyy') AND to_date('30.09.2011','dd.mm.yyyy')

------------------------------------
SELECT handset_code FROM JAN.HANDSET_CONTRACT
WHERE 1=1
group by handset_code
having count(handset_code)>5

SELECT * FROM JAN.HANDSET_CONTRACT
WHERE handset_code = '101730055' for update
------------------------------------
SELECT * FROM JAN.HANDSET_SERVICE hs--пароль и улуга EVDO
where hs.handset_code in ('100160220') FOR UPDATE--,'101670624')

select jan.EVDO.getUserPwd('0116920873') from dual -- пароль к EVDO

begin jan.evdo.deactivate('0116920783'); commit; end;  --deactivate EVDO
-----
begin jan.evdo.activate('0115520011');  commit; end; --activate EVDO 
 ---проверка---
/*
SELECT HSR.EVDO FROM JAN.HANDSET_SERVICE HSR,JAN.HANDSET HS
WHERE HSR.HANDSET_CODE = HS.CODE
AND HS.MOBILE_NO IN ( '0116920783')
*/

  
--provise_vas_after_conn,
begin   JAN.RESTART_VAS_COMMAND('100279681');   commit;  end;

----------------------------------Chap_ss------------------------------------------
select *--hw.evdo_chap_ss 
from jan.hardware hw         -- 1 способ
where hw.hardware_no = '09605665657' 

--из пакета jan.hardwares
select jan.hardwares.get_evdo_chap_ss('04800289046') from dual; -- 2 способ
--###########################################################################
begin  jan.hardwares.set_evdo_chap_ss(p_hardware_no => '00801716850',
                                      p_evdo_chap_ss => :p_evdo_chap_ss);
end;
------------------------------------######------------------------------------------
SELECT * FROM  JAN.NETWORK NT

SELECT * FROM JAN.MOBILE MB,JAN.NETWORK NT
WHERE MB.NETWORK_CODE = NT.CODE
AND   MB.MOBILE_NO = '0456341322' 

---------------------------------------
SELECT * FROM  JAN.mobin m, JAN.MOBILE_SN msn  
where m.msn = msn.msn 
and msn.hardware_no = '8083bdee' 

SELECT * FROM  JAN.mobin m
where m.msn LIKE '%8083bdee%'

SELECT * FROM JAN.MOBILE_SN msn  
where --msn.hardware_no = 'A0000001244D0F'
msn.msn = 'h8083bdee'

select * from JAN.HANDSET_INVOICE  HI
WHERE HI.HANDSET_CODE = '101695124'
------------------------------------
select * from JAN.INVOICE_TYPE IT
WHERE CODE = '3646112'
--substr(it.CHARGE_CODE, 1, 2) = 'IB'

IT.NAME LIKE ('%траф%')

------------------------------------все по оборуд-ю-------------
SELECT *
  FROM JAN.HARDWARE_HISTORY HI,
       JAN.DELIVERY         DL,
       JAN.HARDWARE         HR,
       JAN.RETURNSCRAP      RS,
       JAN.STOCK_ITEM       SI,
       JAN.INVOICE_TYPE     IT,
       JAN.TRANSFER         TR,
       JAN.DEALER           DR

 WHERE HI.DELIVERY_NO = DL.DELIVERY_NO(+)
   AND HI.HARDWARE_NO = HR.HARDWARE_NO
   AND HR.HARDWARE_NO = RS.HARDWARE_NO(+)
   AND HR.STOCK_CODE = SI.STOCK_CODE
   AND SI.ITEM_CODE = IT.CODE
   AND HI.TRANSFER_CODE = TR.CODE(+)
   AND DR.DEALER_NO = SI.DEPOT_NO
      
   AND HI.HARDWARE_NO IN (
'8008A1C6'/*,
'3EBA809B',
'3EBA6CB5',
'3EBA809C',
'3EBA8094' */
)
   
/*для того чтобы серийка принадлежала только складу(в нашем случае 1926) 
в таблице jan.hardware(текущие данные о местонахождении оборуд-я) 
обнуляем customer_no  и в hardware_status устанавливаем U - непривязанный*/


SELECT *
  FROM JAN.HARDWARE HR
 WHERE HR.HARDWARE_NO = '8008A1C6'
   FOR UPDATE


SELECT *
  FROM JAN.HARDWARE_HISTORY HI
  where hi.hardware_no = '18115994080'

--список складов
SELECT D.DEALER_NO, C.NAME, C.SP_CODE, C.CITY,C.CUSTOMER_NO,C.CUS_REC_TYPE
  FROM JAN.DEALER D, JAN.CUSTOMER C
 WHERE D.CUSTOMER_NO = C.CUSTOMER_NO
 AND C.CUS_REC_TYPE in ('D','T')
 AND D.DEALER_NO = '1005'
-- and   c.customer_no = '1583186'
----------------------------------------------------------


select * from jan.history h
where h.comment_code = 'LOADB0'
and h.his_timedate > current_date - interval '5' day

SELECT * FROM JAN.ALL_COMMENT ac
where --ac.comments like '%лієнт%'
ac.code = 'LOADB0'
------------------------------------
SELECT * FROM --JAN.HARDWARE_service              -- ОБОРУДОВАНИЕ
              --JAN.HARDWARE_HISTORY HG
              --where hg.hardware_no = '12801918771'
              --JAN.DELIVERY DG              --ПОСТАВКА
              /*JAN.HARDWARE hw
              where hw.customer_no = '1053638'*/
              /*JAN.RETURNSCRAP RG           --возврат
              WHERE RG.CUSTOMER_NO = '1498444'*/
              --JAN.STOCK_ITEM SI
              --WHERE SI.DEPOT_NO = '1007'
              JAN.INVOICE_TYPE IT
              WHERE IT.SHORT_NAME LIKE '%CTL%'*/
           /*   JAN.TRANSFER TR
              JAN.INVOICE_TYPE_DEFAULT IT
              JAN.DEALER DE
              JAN.DESPATCH_ITEM DI
              JAN.DESPATCH D*/
              --JAN.STOCK_TYPE

SELECT * FROM JAN.STOCK_ISSUED_VIEW_1 SIV--перемещение между складами, продажа, возврат оборуд-я
where-- siv.CUSTOMER_NO = '1583956'
siv.SERIAL_NUMBER = '18115994080'

siv.SERIAL_NUMBER IN (
'3EBA808D',
'3EBA809B',
'3EBA6CB5',
'3EBA809C',
'3EBA8094' 
)
------------------------------------
select *
  from JAN.STOCK_ITEM SI,
       jan.hardware hr,
       jan.invoice_type it,
       jan.order_out oo,
       jan.handset  hs
 where SI.stock_code = hr.stock_code
       and it.code = SI.item_code
       AND   HARDWARE_NO IN (
'12813112727' 
)
       --AND HS.
       and hr.hardware_no = hs.sim_esn_no(+)
       and hs.code = oo.handset_code(+)
       
select * from  JAN.virt_mobile
where esn = '081A3272'

select jan.EVDO.getUserPwd('0115520011') from dual

------------------------------------БАЛАНС------------
SELECT * --ltrim(to_char(v.balance, '9999990.00')) 
FROM JAN.SA_BAL_OV_V vv
where vv.CUSTOMER_NO = '1154862'
VV.OVERDUE_1M IS NOT NULL
AND	 ROWNUM<5
----
SELECT  *
FROM  JAN.VOICE_BALANCE_V VB
WHERE VB.HANDSET_CODE = '100274294'

SELECT * /*LTRIM(TO_CHAR(OVERDUE,'9999990.00'))                      OVERDUE_TOTAL,
        LTRIM(TO_CHAR(DEPOSIT,'9999990.00'))                      DEPOSIT,
        LTRIM(TO_CHAR(BALANCE,'9999990.00'))                      BALANCE,
        LTRIM(TO_CHAR(HELD_ITEMS,'9999990.00'))                   HELD_ITEMS*/
FROM    JAN.SA_BAL_OV_V
WHERE   CUSTOMER_NO = '1562190'

---------------------------------------------
SELECT  *--sum(sa.POSTED_OPEN_AMOUNT)
FROM    JAN.SALES_AUDIT_V SA        
WHERE   SA.CUSTOMER_NO = '1154862'
---------------------------------------------
SELECT
SA.CUSTOMER_NO,
sa.AUDIT_DATE,
round(jan.sales.getopenamount(sa.code), 2) op

FROM JAN.SALES_AUDIT  SA
     
WHERE  SA.TYPE in ('IR','MI')
--AND (round(jan.sales.getopenamount(sa.code), 2) < -0.10 OR round(jan.sales.getopenamount(sa.code), 2) > 0.10)
AND   SA.CUSTOMER_NO = 9071935
and   sa.audit_date BETWEEN TO_DATE('01.01.2013', 'DD.MM.YYYY') AND
                            TO_DATE('01.04.2013', 'DD.MM.YYYY')- 1/86400
---------------------------------------------
SELECT SA.CODE, SA.CUSTOMER_NO, SA.AUDIT_DATE, SA.AMOUNT, SA.TYPE,A.AMOUNT BAL
       
FROM    
JAN.SALES_AUDIT SA,
(
SELECT SUM(SA.AMOUNT)                          AMOUNT,
       SA.CUSTOMER_NO                          CUSTOMER_NO
FROM JAN.SALES_AUDIT SA, JAN.BATCH BT
WHERE SA.CUSTOMER_NO = '9071935'
AND BT.CODE = SA.BATCH_CODE AND BT.POSTED = 'Y'
AND TRUNC(SA.DUE_DATE) <= TO_DATE('01.01.2013', 'DD.MM.YYYY')
GROUP BY SA.CUSTOMER_NO
) A
WHERE   1=1
AND     SA.AUDIT_DATE BETWEEN TO_DATE('01.01.2013', 'DD.MM.YYYY')
                      AND     TO_DATE('01.02.2013', 'DD.MM.YYYY') - 1/86400 
AND   A.CUSTOMER_NO = SA.CUSTOMER_NO                      
AND   SA.CUSTOMER_NO = '9071935'                      
---------------------------------------------
SELECT
SA.CUSTOMER_NO,
sa.AUDIT_DATE,
round(jan.sales.getbalance(sa.CUSTOMER_NO), 2) op,
JAN.GET_BALANCE_ON_DATE(sa.CUSTOMER_NO, SA.AUDIT_DATE) BL1

FROM JAN.SALES_AUDIT  SA
     
WHERE  SA.CUSTOMER_NO = '9071935'
and   sa.audit_date = TO_DATE('01.03.2013', 'DD.MM.YYYY') 
---------------------------------------------
select * from JAN.INVOICE_run IR

select * from JAN.INVOICE_ITEM II
WHERE II.inv_code ='1015902549'

/*Type in (DC-Discount, IR-Invoice run, DR-DD or CC  Run, MP-Manual Cash, MI-Manual Invoice, 
         JR-Journal, CN-Credit Note, CC-Credit Control,  DP-Deposit, UC-Unpaid, UH-Cash, 
         UD-Unpaid DD, RF-Refund)*/
         
SELECT  *
FROM    JAN.SALES_AUDIT SA
where 1=1
--and   sa.code = '1015587769'
and     sa.mess LIKE '020106%'
AND     SA.AUDIT_DATE BETWEEN TO_DATE('01.01.2012','DD.MM.YYYY')
                      AND     TO_DATE('01.01.2013','DD.MM.YYYY') - 1/86400;

, 
        JAN.INVOICE_ITEM II
        
WHERE   II.INV_CODE = '1012517266'--SA.CUSTOMER_NO = '1070134'
AND     II.INV_CODE(+) = SA.CODE
--AND     

SELECT  *
FROM    JAN.TAX_WAYBILL

------------------------------------
SELECT * FROM   JAN.INVOICE_TYPE IT--, JAN.USER_DEFAULT UD
WHERE   /*IT.SP_CODE = UD.SP_CODE
--and   it.charge_code like 'IM%'
and */it.code = '212209924'

------------------------------------
SELECT * FROM   JAN.CASH_PAYMENT_OTHER

SELECT * 
FROM 
       JAN.SALES_AUDIT                                                    SA,
       JAN.BATCH                                                          BA, 
       JAN.BATCH_TYPE                                                     BT

WHERE  SA.BATCH_CODE = BA.CODE
AND    BA.CASH_TYPE  = BT.CASH_TYPE
and    sa.CUSTOMER_NO in ('1496335','1533072','1581995')


------------------------------------
SELECT * FROM   
--JAN.tmp$print_parameters TMP
--JAN.INVOICE_RUN IR
JAN.SYSTEM_FIELD SF
------------------------------------
SELECT * FROM   
--JAN.PRINT_RUN_MAIN_VIEW_ITC I
--JAN.PRINT_ORDER_V V
--JAN.PRINT_TW
JAN.PRINT_CUST_STAT PCU
where Pcu.CUSTOMER_NO = 1120099

-----------------Печать счета ------

select * from  
JAN.PRINT_CUST_STAT PCU
where customer_no='9071935' for update
-----------------------
select * from 
JAN.PRINT_HANDSET
where customer_no='9071935' for update
-----------------------
select * from  
JAN.PRINT_SALES_AUDIT PSA
where customer_no='9071935' for update

------------------------------------IP-------
SELECT
  '',
 SIP.IP_VAL "IP",
 DECODE(SIP.IP_TYPE,'r','реальний','l','локальний') "тип" 
 FROM JAN.STAT_IP SIP
 WHERE 
 SIP.IP_VAL NOT IN (SELECT hss.ip_val FROM  JAN.HANDSET_SERVICE HSS where HSS.ip_val is not null) 
 ORDER BY 2;
 
SELECT * FROM  JAN.HANDSET_SERVICE HSS where HSS.ip_val in (select * from IP_011)

------------------------------------


SELECT  DECODE(SUBSTR(CHARGE_CODE,1,2),
                                'IA','a1',
                                'IB','a2',
                                'IC','a3',
                                'ID','a4',
                                'IE','a5',
                                'IF','a6',
                                'IG','a7',
                                'IH','a8',
                                'II','a9',
                                'IM','a10'
                ),
                        SUBSTR(CHARGE_CODE,3) CODE, NAME, SHORT_NAME,SUBSTR(CHARGE_CODE,3)
        FROM    JAN.INVOICE_TYPE_DEFAULT
        WHERE   LENGTH(CHARGE_CODE) > 2
------------------------------------

SELECT  NVL(H.MOBILE_NO, H.MOBILE_NO_REF), NA.CODE, IT.ABBREV, IT.NAME,
  TO_CHAR(SUM(NVL(II.QUANTITY,1))), TO_CHAR(SUM(II.AMOUNT),'99999990.9999'), SUBSTR(IT.ABBREV,1,2), II.HANDSET_CODE, '1',II.INV_CODE
FROM   JAN.INVOICE_ITEM II,JAN.INVOICE_TYPE IT,
  JAN.NOMINAL_ACCOUNT NA, JAN.HANDSET H
WHERE   IT.CODE = II.INV_TYPE_CODE
  AND H.CODE = '100033077'
  AND NA.CODE = IT.NOM_CODE
  AND NA.SP_CODE = IT.SP_CODE
  AND H.CODE(+) = II.HANDSET_CODE
  GROUP BY II.INV_CODE,H.MOBILE_NO,H.MOBILE_NO_REF,NA.CODE,IT.ABBREV,IT.NAME,II.AMOUNT,
  II.HANDSET_CODE,II.QUANTITY,II.INV_CODE

---------------ЗАБОРОНИ-------------------
SELECT  /*+
            ordered
            use_nl(MB,B)
            index(MB UNMB_MOBILE_NO_BAR_CODE)
        */
        '', B.NAME"НАЗВА", MB.STATUS"СТАТУС",
        TO_DATE(MB.BARUNBAR_DATE) "ДАТА"
FROM    JAN.MOBILE_BAR MB,
        JAN.BAR B
WHERE   MB.MOBILE_NO='0462974436'
AND     B.CODE=MB.BAR_CODE
--------------
SELECT MD.MOBILE_NO
       , Decode(md.EIGHT,'Y','+','Закритий')
       , Decode(md.TEN,'Y','+','Закритий')
       , hst.DESCRIPTION
       , hs.DATE_TIME_ACTIVATED
FROM JAN.HANDSET hs, JAN.MOBILE_ADD_ITC md, JAN.HANDSET hst
WHERE md.MOBILE_NO=hs.MOBILE_NO
AND hst.CONTRACT_TYPE=hs.CONTRACT_TYPE_REF
AND NVL(HS.MOBILE_NO, HS.MOBILE_NO_REF)=MD.MOBILE_NO
AND HS.STATUS IN ('A','B')
AND HS.CUSTOMER_NO= 1564626
ORDER BY 1
---------------
SELECT * FROM JAN.SP_CODE_BY_COMPANY SP
