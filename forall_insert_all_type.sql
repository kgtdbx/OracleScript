It is possible to do this in a single FORALL statement, provided you create the nested tables as SQL objects. This allows you to reference them as tables with the SQL. You can then use INSERT ALL to do a multi-table insert:

create or replace type t_inner_tab_t as table of varchar2(30); 
/

create or replace type outer_tab_t as object (
  num number,
  vals  t_inner_tab_t
);
/

create or replace type t_outer_tab_t is table of outer_tab_t;
/

declare
  inner_tab t_inner_tab_t;
  outer_tab t_outer_tab_t;
begin
    inner_tab := t_inner_tab_t('one', 'two', 'three');

    outer_tab := t_outer_tab_t();

    outer_tab.extend;

    outer_tab(outer_tab.last) := outer_tab_t(1, inner_tab);

    forall i in outer_tab.first .. outer_tab.last 
      insert all
        when r = 1 then
          into a (num) values (o)
        when r  >= 1 then
          into b (val) values (c)
        select column_value c, outer_tab(i).num o, 
               row_number() over (partition by outer_tab(i).num order by outer_tab(i).num) r 
        from   table(cast(outer_tab(i).vals as t_inner_tab_t));

end;
/

SELECT * FROM a;

NUM
---
  1 

SELECT * FROM b;


VAL                          
------------------------------
one                            
two                            
three      
The row_number() clause is to enable the conditional insert (when r = 1). Without this, you'll insert into a for every value present in your outer_tab.