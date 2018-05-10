set serveroutput on;

declare
    l_value varchar2(4000 byte);
    l integer default 0;
    l_number_list number_list;
    i integer;
    l_start timestamp;
begin
    dbms_session.set_sql_trace(true);

    l_start := systimestamp;
    select ref
    bulk collect into l_number_list
    from (select ref, row_number() over (order by ref) row_num
          from oper)
    where row_num between 20000000 and 30000000;
    dbms_output.put_line('Fetch time is : ' || (systimestamp - l_start));
    dbms_output.put_line('Fetched records count is : ' || l_number_list.count);

    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from operw t where t.ref = l_number_list(i) and t.tag = 'ND';

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('OPERW Unique key search done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    l := 0;
    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from test_operw_part t where t.ref = l_number_list(i) and t.tag = 'ND';

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('Partitioned OPERW Unique key search done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    l := 0;
    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from test_operw_part2 t where t.ref = l_number_list(i) and t.tag = 'ND';

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('Partitioned OPERW with local index Unique key search done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    l := 0;
    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from operw t where t.ref = l_number_list(i);

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('OPERW Range scan done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    l := 0;
    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from test_operw_part t where t.ref = l_number_list(i);

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('Partitioned OPERW Range scan done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    l := 0;
    l_start := systimestamp;
    i := l_number_list.first;
    while (i is not null) loop
        select min(value) keep (dense_rank last order by 100) into l_value from test_operw_part2 t where t.ref = l_number_list(i);

        if (l_value is not null) then
            l := l + 1;
        end if;

        i := l_number_list.next(i);
    end loop;
    dbms_output.put_line('Partitioned OPERW with local index range scan done in : ' || (systimestamp - l_start) || ', values found : ' || l);

    dbms_session.set_sql_trace(false);
    select value into l_value from v$diag_info where name = 'Default Trace File';
    dbms_output.put_line(l_value);
end;
/
rollback;
disconnect;
