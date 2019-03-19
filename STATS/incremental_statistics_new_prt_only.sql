This is exactly what incremental statistics was built for.
--https://docs.oracle.com/database/121/TGSQL/tgsql_stats.htm#GUID-7BECE839-ACC5-4768-8BE6-A16AAD14A9ED

With incremental statistics, Oracle will only gather partition statistics for partitions that have changed. Synopses are built for each partition, and those synopses are quickly combined to create global statistics without having to re-scan the whole table.

To enable it you only need to set a table preference and then gather statistics. The first gather will be slow but future statistics gathering will be much faster.

begin
    dbms_stats.set_table_prefs('TABLE_OWNER', 'TABLE_NAME', 'incremental', 'true');
    dbms_stats.gather_table_stats('TABLE_OWNER', 'TABLE_NAME');
end;
/
