-- grant execute on  IT_WPN to SBOVKUSH;

CREATE OR REPLACE PACKAGE IT_WPN IS
  -- Author  : S.BOVKUSH
  -- Created : 23.05.2014 17:30:09

-- Main mobile_no add, activate, update if different is_redirect
PROCEDURE ADD_MAIN_MOBILE_NO(
          p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
          p_is_redirect     IN    IT_MOBILE_VAS.IS_REDIRECT%TYPE, 
          out_val           OUT   NUMBER);
-- Subordinate mobile_no add          
PROCEDURE ADD_SUB_MOBILE_NO(
          p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
          p_kurator_no      IN    IT_MOBILE_VAS.KURATOR_NO%TYPE, 
          out_val           OUT   NUMBER);
-- Main and subordinate mobile_no deactivate          
PROCEDURE DEACT_MOBILE_NO(
          p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
          out_val           OUT   NUMBER);
-- Main and subordinate mobile_no delete         
PROCEDURE DELETE_MOBILE_NO(
          p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
          out_val           OUT   NUMBER);
END IT_WPN;
----------------
CREATE OR REPLACE PACKAGE BODY IT_WPN IS

  /* 
  version history
  1.00  sbovkush  23.05.2014   was created
  */

PROCEDURE ADD_MAIN_MOBILE_NO(
p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
p_is_redirect     IN    IT_MOBILE_VAS.IS_REDIRECT%TYPE, 
out_val           OUT   NUMBER)
IS
p_id_vas          IT_MOBILE_VAS.ID_VAS%TYPE;
p_status          IT_MOBILE_VAS.STATUS%TYPE;
p_is_redirect_in  IT_MOBILE_VAS.IS_REDIRECT%TYPE;
p_kurator_no      IT_MOBILE_VAS.KURATOR_NO%TYPE;
p_count           NUMBER;
p_id_sq           NUMBER;
BEGIN
  BEGIN
  SELECT imv.id_vas,  
         imv.status, 
         NVL(imv.is_redirect, 0) is_redirect,
         imv.kurator_no 
  INTO   p_id_vas, p_status, p_is_redirect_in, p_kurator_no  
  FROM   itc.it_mobile_vas imv
  WHERE  imv.mobile_no = p_mobile_no
  AND    imv.id_vas = 'WPN';
  EXCEPTION
   WHEN no_data_found THEN
        --dbms_output.put_line('Main mobile_no entered is not in the database'/*||sqlerrm*/);
        /* если номера нет, происходит добавление номера как основного  
           в активном состоянии(status = 'A') с id_vas = 'WPN' */
  SELECT seq_it_mobile_vas.nextval INTO p_id_sq FROM dual;
   
  INSERT INTO itc.it_mobile_vas
        (mobile_no, detail, id_scenario, 
         id_vas, id_type, e_mail, kurator_no, 
         format, is_redirect, is_incall, 
         is_day, is_week, id, 
         status, date_activated, 
         date_deactivated, is_month, statistika)
  VALUES
        (p_mobile_no, NULL, NULL, 'WPN', NULL, NULL, NULL, NULL, p_is_redirect,
         NULL, NULL, NULL, p_id_sq, 'A', SYSDATE, NULL, NULL, NULL);
     --dbms_output.put_line('Main mobile_no add ' || p_mobile_no);
  END;     
   
  -- если номер существует но он деактивирован, то происходит активация  
   IF p_id_vas = 'WPN' AND p_status = 'D' AND p_kurator_no IS NULL  
   THEN
      UPDATE itc.it_mobile_vas imv
      SET    imv.status = 'A'
      WHERE  imv.mobile_no = p_mobile_no;
     --dbms_output.put_line('Main mobile_no activated ' || p_mobile_no);
   
   /* иначе если введенный номер существует, он активен, но с is_redirect отличным от введенного, то
      происходит обновление is_redirect */ 
   ELSIF p_id_vas = 'WPN' AND p_status = 'A' AND p_kurator_no IS NULL 
      AND p_is_redirect_in <> p_is_redirect  
   THEN
      UPDATE itc.it_mobile_vas imv
      SET    imv.is_redirect = p_is_redirect
      WHERE  imv.mobile_no = p_mobile_no;
     --dbms_output.put_line('For main mobile_no '|| p_mobile_no ||' update is_redirect - ' || p_is_redirect);  
  END IF;
  out_val := 0;
   
 EXCEPTION
   WHEN OTHERS THEN
        --dbms_output.put_line('Все плохо! '||sqlerrm);
        out_val := 1; 
 RAISE;        
END ADD_MAIN_MOBILE_NO;

PROCEDURE ADD_SUB_MOBILE_NO(
p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
p_kurator_no      IN    IT_MOBILE_VAS.KURATOR_NO%TYPE, 
out_val           OUT   NUMBER)
IS
p_main_mobile_no  IT_MOBILE_VAS.MOBILE_NO%TYPE;
p_id_vas          IT_MOBILE_VAS.ID_VAS%TYPE;
p_status          IT_MOBILE_VAS.STATUS%TYPE;
p_count           NUMBER;
p_id_sq           NUMBER;
BEGIN
  BEGIN
  SELECT imv.mobile_no,
         imv.id_vas,  
         imv.status
  INTO   p_main_mobile_no, p_id_vas, p_status
  FROM   itc.it_mobile_vas imv
  WHERE  imv.mobile_no = p_kurator_no
  AND    imv.id_vas = 'WPN';
  EXCEPTION
   WHEN no_data_found THEN
        --dbms_output.put_line('Main mobile_no is not in the database'/*||sqlerrm*/);
        raise_application_error(-20001,'Main mobile_no entered is not in the database ');
  END;     
  -- проверка на наличие номера в таблице itc.it_mobile_vas  
  SELECT COUNT(1)
  INTO   p_count
  FROM  itc.it_mobile_vas imv
  WHERE imv.mobile_no = p_mobile_no;
  
  IF p_count = 0 AND p_kurator_no IS NOT NULL 
     AND p_status = 'A' AND p_id_vas = 'WPN' AND p_kurator_no = p_main_mobile_no
  THEN
  /* если подчиненного номера нет и введенный основной номер(p_kurator_no) 
     есть в таблице itc.it_mobile_vas, он активен и имеет статус 'WPN', 
     происходит добавление номера как подчиненного, с признаком основного номера, 
     в активном состоянии(status = 'A') с id_vas = 'WPN'*/
  SELECT seq_it_mobile_vas.nextval INTO p_id_sq FROM dual;
   
  INSERT INTO itc.it_mobile_vas
        (mobile_no, detail, id_scenario, 
         id_vas, id_type, e_mail, kurator_no, 
         format, is_redirect, is_incall, 
         is_day, is_week, id, 
         status, date_activated, 
         date_deactivated, is_month, statistika)
  VALUES
        (p_mobile_no, NULL, NULL, 'WPN', NULL, NULL, p_kurator_no, NULL, NULL,
         NULL, NULL, NULL, p_id_sq, 'A', SYSDATE, NULL, NULL, NULL);
     --dbms_output.put_line('Subordinate mobile_no add ' || p_mobile_no);
   -- иначе выводится сообщение 
  ELSE
     raise_application_error(-20001,'Subordinate mobile_no '|| p_mobile_no||' already exists in the table
                            or main mobile_no '||p_kurator_no||' not activated 
                            or p_id_vas <> WPN ');
  END IF;
  out_val := 0;
   
 EXCEPTION
   WHEN OTHERS THEN
        --dbms_output.put_line('Все плохо! '||sqlerrm);
        out_val := 1;
 RAISE;
END ADD_SUB_MOBILE_NO;

PROCEDURE DEACT_MOBILE_NO(
p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
out_val           OUT   NUMBER)
IS
p_deact_mobile_no IT_MOBILE_VAS.MOBILE_NO%TYPE;
p_status          IT_MOBILE_VAS.STATUS%TYPE;
p_kurator_no      IT_MOBILE_VAS.KURATOR_NO%TYPE;
p_count           NUMBER;
BEGIN
  BEGIN
  SELECT imv.mobile_no, imv.kurator_no, imv.status 
  INTO   p_deact_mobile_no, p_kurator_no, p_status  
  FROM   itc.it_mobile_vas imv
  WHERE  imv.mobile_no = p_mobile_no
  AND    imv.id_vas = 'WPN';
  EXCEPTION
   WHEN no_data_found THEN
        --dbms_output.put_line('Main mobile_no entered is not in the database '/*||sqlerrm*/);
        raise_application_error(-20001,'Mobile_no entered is not in the database ');
  END;     
  -- проверка на наличие номера в таблице itc.it_mobile_vas  
  SELECT COUNT(1)
  INTO   p_count
  FROM  itc.it_mobile_vas imv
  WHERE imv.mobile_no = p_mobile_no;
  
  /* если номер есть, он основной и активен, происходит деактивация 
     как основного номера так и его подчиненных номеров(status = 'D') */
  IF p_count = 1 AND p_kurator_no IS NULL AND p_status = 'A'
     THEN 
      UPDATE itc.it_mobile_vas imv
      SET    imv.status = 'D'
      WHERE  imv.mobile_no IN (SELECT mobile_no
                               FROM   itc.it_mobile_vas
                               WHERE  status = 'A'
                               AND    mobile_no = p_mobile_no
                               UNION
                               SELECT mobile_no
                               FROM   itc.it_mobile_vas
                               WHERE  status = 'A'
                               AND    kurator_no = p_mobile_no);
    --dbms_output.put_line('Main and subordinate mobile_no deactivated ' || p_mobile_no);
   -- иначе если номер существует и он подчиненный, то происходит только его деактивация  
   ELSIF p_count = 1 AND p_kurator_no IS NOT NULL AND p_status = 'A'
    THEN
      UPDATE itc.it_mobile_vas imv
      SET    imv.status = 'D'
      WHERE  imv.mobile_no = p_mobile_no;
    --dbms_output.put_line('Subordinate mobile_no deactivated ' || p_mobile_no);
  END IF;
  out_val := 0;
   
 EXCEPTION
   WHEN OTHERS THEN
        --dbms_output.put_line('Все плохо! '||sqlerrm);
        out_val := 1;
 RAISE;        
END DEACT_MOBILE_NO;

PROCEDURE DELETE_MOBILE_NO(
p_mobile_no       IN    IT_MOBILE_VAS.MOBILE_NO%TYPE,
out_val           OUT   NUMBER)
IS
p_kurator_no      IT_MOBILE_VAS.KURATOR_NO%TYPE;
p_count           NUMBER;
BEGIN
  BEGIN
  SELECT imv.kurator_no INTO p_kurator_no
  FROM   itc.it_mobile_vas imv
  WHERE  imv.mobile_no = p_mobile_no
  AND    imv.id_vas = 'WPN';
  EXCEPTION
   WHEN no_data_found THEN
        --dbms_output.put_line('Mobile_no entered is not in the database '/*||sqlerrm*/);
        raise_application_error(-20001,'Mobile_no entered is not in the database ');
  END;     
  -- проверка на наличие номера в таблице itc.it_mobile_vas  
  SELECT COUNT(1)
  INTO   p_count
  FROM  itc.it_mobile_vas imv
  WHERE imv.mobile_no = p_mobile_no;
  
  IF p_count = 1 AND p_kurator_no IS NULL
  /* если номер есть и он основной , происходит удаление 
     как основного номера так и его подчиненных номеров */
    THEN 
      DELETE FROM itc.it_mobile_vas imv
      WHERE  imv.mobile_no IN (SELECT mobile_no
                               FROM   itc.it_mobile_vas
                               WHERE  mobile_no = p_mobile_no
                               UNION
                               SELECT mobile_no
                               FROM   itc.it_mobile_vas
                               WHERE  kurator_no = p_mobile_no);
    --dbms_output.put_line('Main and subordinate mobile_no deleted ' || p_mobile_no);
   -- иначе если номер существует и подчиненный, то происходит только его удаление  
   ELSIF p_count = 1 AND p_kurator_no IS NOT NULL 
    THEN
      DELETE FROM itc.it_mobile_vas imv
      WHERE  imv.mobile_no = p_mobile_no;
    --dbms_output.put_line('Subordinate mobile_no deleted ' || p_mobile_no);
  END IF;
  out_val := 0;
   
 EXCEPTION
   WHEN OTHERS THEN
        --dbms_output.put_line('Все плохо! '||sqlerrm);
        out_val := 1;
 RAISE;         
END DELETE_MOBILE_NO;

END IT_WPN;
