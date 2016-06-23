function f_replace(p_str in varchar2) return varchar2
-- функция убирает непечатаемые символы и серии пробелов
is
  x00_x1f varchar2(32) :=
     chr(00)||chr(01)||chr(02)||chr(03)||chr(04)||chr(05)||chr(06)||chr(07)||
     chr(08)||chr(09)||chr(10)||chr(11)||chr(12)||chr(13)||chr(14)||chr(15)||
     chr(16)||chr(17)||chr(18)||chr(19)||chr(20)||chr(21)||chr(22)||chr(23)||
     chr(24)||chr(25)||chr(26)||chr(27)||chr(28)||chr(29)||chr(30)||chr(31);

begin
    return
      replace(replace(replace(replace(replace(
        translate(trim(p_str),   x00_x1f, rpad(' ',32)),
        '      ',' '),
        '     ',' '),
        '    ',' '),
        '   ',' '),
        '  ',' ');

end;