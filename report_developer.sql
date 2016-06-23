select * from BOND t
where instrument_nm = &<name="instrument_nm" type "string">;


select * from BOND t
where instrument_nm = &<name="instrument_nm" required="yes">;

select * from BOND t
where instrument_nm = &<name="instrument_nm" type "string" uppercase="yes" default="DB 0 12/27/13">;

--еслди оставить поле пустым то выбирутся все записи(необходимо указать ifempty="%")
select * from BOND t
where instrument_nm like &<name="instrument_nm" type "string" uppercase="yes" ifempty="%">;

select * from BOND t
where t.create_date = &<name="create_date" type "date" default="select sysdate from dual">;


select * from BOND t
where instrument_id = &<name="instrument_id"
                        list "19688676, Index, 
                        19690898, Bond,
                        19694231, Issue" 
                        description = "yes">;

select * from BOND t
where instrument_id = &<name="instrument_id" type "integer" 
                        list "19688676, Index, 
                        19690898, Bond,
                        19694231, Issue" 
                        description = "yes"
                        multiselect="yes">;
                        
select * from BOND t
where t.create_date = &<name="create_date" 
                        type "date" list "select create_date from BOND where create_date>sysdate -3"
                        /*default="select sysdate from dual"*/
                        checkbox="desc, asc">;                        


