procedure fill_arc_rrp
  is
    p               constant varchar2(62) := G_PKG||'.fill_arc_rrp';
    l_errmsg        varchar2(4000);
    l_min_data      date;
    l_max_data      date;
    l_exists        boolean;
    l_num           number;
    l_max_rec       number;
  begin
    --
    trace('%s: entry point', p);
    --
    bc.go(g_kf);
    --
    mgr_utl.before_fill('arc_rrp');
    --
    begin
        --
        for c in (select 'NONE' as partition_name, partitioned, 0 as partition_position, null as partition_stmt
                    from all_tables
                   where owner='KF'||g_kf
                     and table_name='ARC_RRP'
                     and partitioned='NO'
                   union all
                  select partition_name, 'YES' as partitioned, partition_position, 'partition('||partition_name||')' as partition_stmt
                    from all_tab_partitions
                   where table_owner='KF'||g_kf
                     and table_name='ARC_RRP'
                   order by partition_position asc
                 )
        loop
            -- проверяем наличие в arc_rrp данных партиции KF<>.arc_rrp
            execute immediate 'select min(dat_a), max(dat_a) from '||pkf('arc_rrp')||' '||c.partition_stmt into l_min_data, l_max_data;
            --
            l_exists := false;
            begin
                select 1
                  into l_num
                  from arc_rrp
                 where dat_a between l_min_data and l_max_data
                   and kf=g_kf
                   and rownum=1;
                --
                l_exists := true;
            exception
                when no_data_found then
                    null;
            end;
            --
            if l_exists
            then
                trace('Данные '||pkf('arc_rrp')||' '||c.partition_stmt||' уже импортированы в arc_rrp, пропускаем');
                continue;
            end if;
            -- наполняем данные партиции
            execute immediate
            '
            insert
              into arc_rrp (
                   rec, ref, mfoa, nlsa, mfob, nlsb,
                   dk, s, vob, nd, kv, datd, datp, nam_a, nam_b,
                   nazn, naznk, nazns, id_a, id_b, id_o, ref_a, bis, sign,
                   fn_a, dat_a, rec_a, fn_b, dat_b, rec_b, d_rec, blk, sos,
                   prty, fa_name, fa_ln, fa_t_arm3, fa_t_arm2, fc_name,
                   fc_ln, fc_t1_arm2, fc_t2_arm2, fb_name, fb_ln, fb_t_arm2,
                   fb_t_arm3, fb_d_arm3, kf)
            select to_number(a.rec||'''||g_ru||'''), nvl2(a.ref, to_number(a.ref||'''||g_ru||'''), null), a.mfoa, a.nlsa, a.mfob, a.nlsb,
                   a.dk, a.s, v.new_vob as vob, a.nd, a.kv, a.datd, trunc(a.datp) as datp, a.nam_a, a.nam_b,
                   a.nazn, a.naznk, a.nazns, a.id_a, a.id_b, a.id_o, a.ref_a, a.bis, a.sign,
                   a.fn_a, a.dat_a, a.rec_a, a.fn_b, a.dat_b, a.rec_b, a.d_rec, a.blk, a.sos,
                   a.prty, a.fa_name, a.fa_ln, a.fa_t_arm3, a.fa_t_arm2, a.fc_name,
                   a.fc_ln, a.fc_t1_arm2, a.fc_t2_arm2, a.fb_name, a.fb_ln, a.fb_t_arm2,
                   a.fb_t_arm3, a.fb_d_arm3, :g_kf as kf
              from '||pkf('arc_rrp')||' '||c.partition_stmt||' a, mgr_vob_map v
             where v.kf (+) = :g_kf
               and v.old_vob(+) = a.vob'
            using g_kf, g_kf;
            --
            trace('%s записей вставлено', to_char(sql%rowcount));
            --
            commit;
            --
            trace('импортирована таблица/партиция %s', c.partition_stmt);
            --
        end loop;
        --
        bc.home();
        --
        -- заново узнаем максимальный REC в ARC_RRP
        select trunc(nvl(max(rec),0)/100)+1
          into l_max_rec
          from arc_rrp;
        -- выставляем последовательность s_arc_rrp
        mgr_utl.reset_sequence('S_ARC_RRP', l_max_rec);

        trace('собираем статистику');
        --
        mgr_utl.gather_table_stats('bars', 'arc_rrp', cascade=>true);
        --
    exception
        when others then
            rollback;
            mgr_utl.save_error();
    end;
    --
    bc.home();
    --
    mgr_utl.finalize();
    --
    trace('%s: finished', p);
    --
  end fill_arc_rrp;