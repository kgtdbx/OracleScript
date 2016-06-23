declare
l_smt varchar2(32767);

    function get_table_fields(p_table varchar2, p_prefix varchar2, p_suffix varchar2)
    return varchar2
    is
    l_uptable   varchar2(61) := upper(p_table);
    l_owner     varchar2(30) := substr(l_uptable, 1, instr(l_uptable,'.')-1);
    l_table     varchar2(30) := substr(l_uptable, instr(l_uptable,'.')+1);
    l_fields    varchar2(32767);
    begin
        select max( sys_connect_by_path(p_prefix||column_name||' as '||column_name||'_'||p_suffix, ',')) into l_fields
        from (
               select column_name, row_number() over (order by column_id) as num
                 from all_tab_columns
                where owner=l_owner
                  and table_name=l_table
             )
        connect by  prior num = num-1
        start with num = 1;
        return substr(l_fields, 2);
    end get_table_fields;

begin
  
 l_smt := get_table_fields('bars.customer', 'a.', 'A');
dbms_output.put_line(l_smt);
end;