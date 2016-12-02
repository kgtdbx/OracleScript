DECLARE 

 ----------------------------------------------------
 SLEEP_TIMEOUT constant number := 2;
 l_isclear boolean;

 PART_NOT_EXISTS exception;
 pragma exception_init(PART_NOT_EXISTS, -2149);

 RESOURCE_BUSY exception;
 pragma exception_init(RESOURCE_BUSY, -54 );

 CANT_DROP_LAST_PART exception;
 pragma exception_init(CANT_DROP_LAST_PART, -14758 );

 ----------------------------------------------------
begin
 -- удаляем старые партиции
 for c in ( select * from iot_calendar
            where
-- отключено временно до полной ликвидации "хвостов" по своду док дня
------------------cdat between p_fdat-16 and p_fdat-6 or
                  cdat=p_fdat
            order by cdat desc
           )
 loop
   l_isclear := false;
   loop
     begin
       execute immediate
         'alter table PART_ZVT_DOC drop partition for (to_date('''||to_char(c.cdat,'dd.mm.yyyy')||''',''dd.mm.yyyy''))';
       l_isclear := true;
      exception when CANT_DROP_LAST_PART then l_isclear := true;
                when PART_NOT_EXISTS     then l_isclear := true;
                when RESOURCE_BUSY       then dbms_lock.sleep(SLEEP_TIMEOUT);
     end;

     exit when (l_isclear);

 end loop;
 logger.trace('партиция %s за дату удалена', to_char(c.cdat,'dd.mm.yyyy'));
 end loop;
 
 end;