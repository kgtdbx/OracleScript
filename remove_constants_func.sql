declare

  function remove_constants(p_query in varchar2) return varchar2 deterministic as
    l_query     v$sqlarea.SQL_TEXT%type;
    l_char      varchar2(1);
    l_in_quotes boolean default FALSE;
  begin
    for i in 1 .. length(p_query) loop
      l_char := substr(p_query, i, 1);
      if (l_char = '''' and l_in_quotes) then
        l_in_quotes := FALSE;
      elsif (l_char = '''' and NOT l_in_quotes) then
        l_in_quotes := TRUE;
        l_query     := l_query || '''#';
      end if;
      if (NOT l_in_quotes) then
        l_query := l_query || l_char;
      end if;
    end loop;
    l_query := translate(l_query, '0123456789', '@@@@@@@@@@');
    for i in 0 .. 8 loop
      l_query := replace(l_query, lpad('@', 10 - i, '@'), '@');
      l_query := replace(l_query, lpad(' ', 10 - i, ' '), ' ');
    end loop;
    return upper(l_query);
  end remove_constants;

begin
  for c in (select remove_constants(v.SQL_TEXT) as sql_text_wo_constants,
                   count(*) cnt
              from v$sqlarea v
             group by remove_constants(v.SQL_TEXT)
            having count(*) > 1
             order by cnt) loop
    dbms_output.put_line(rpad(to_char(c.cnt), 5, ' ') || ' | ' ||
                         c.sql_text_wo_constants);
  end loop;
end;
