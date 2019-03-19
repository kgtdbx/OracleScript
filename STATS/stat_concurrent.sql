alter system set parallel_adaptive_multi_user=false;

begin
dbms_stats.set_global_prefs('CONCURRENT', 'TRUE');
end;
/

select dbms_stats.get_prefs('concurrent') from dual

BEGIN
  SYS.DBMS_STATS.GATHER_SCHEMA_STATS (
     OwnName           => 'BARS'
    ,Granularity       => 'DEFAULT'
    ,Options           => 'GATHER'
    ,Gather_Temp       => FALSE
    ,Estimate_Percent  => NULL
    ,Method_Opt        => 'FOR ALL INDEXED COLUMNS'
    ,Degree            => 16
    ,Cascade           => TRUE
    ,No_Invalidate     => FALSE);
END;

