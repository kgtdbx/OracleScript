
select d.id,
       d.task_name,
       d.task_statement,
       d.sequence_number,
       listagg(d.branch || ' : ' ||
               to_char(extract(hour from d.elapsed_time), 'fm990') || ':' ||
               to_char(extract(minute from d.elapsed_time), 'fm00') || ':' ||
               to_char(extract(second from d.elapsed_time), 'fm00') || chr(10)) within group (order by d.branch),
       listagg(case when d.details is null then null else d.branch || chr(10) end || d.details) within group (order by d.branch),
       d.state_id
from   (select tt.id,
               tt.task_name,
               tt.task_statement,
               tt.sequence_number,
               t.branch,
               numtodsinterval(t.finish_time - t.start_time, 'day') elapsed_time,
               (select dbms_lob.substr(ttr.details, 2000)
                from   bars.tms_task_run_tracking ttr
                where  ttr.rowid = (select min(tr.rowid) keep (dense_rank last order by tr.id)
                                    from    bars.tms_task_run_tracking tr
                                    where  tr.task_run_id = t.id)) details,
                t.state_id
        from    bars.tms_task_run t
        left join  bars.tms_task tt on tt.id = t.task_id
        where  t.run_id = 41) d
group by d.id, d.task_name, d.task_statement, d.sequence_number, d.state_id

order by d.sequence_number;
