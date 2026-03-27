
```
docker run --name demo-postgres \
    -p 5433:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -d postgres \
    -c log_statement=all \
    -c log_min_duration_statement=0 \
    -c log_destination=stderr \
    -c logging_collector=off  -c shared_preload_libraries=pg_stat_statements
```

```
postgres=# CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION
```


```
SELECT                                                                                     
    query,
    calls,                                                        
    total_exec_time AS total_execution_time, -- Renaming for clarity
    rows,
    stats_since AS last_stats_reset_or_start_time -- Renaming for clarity
FROM
    pg_stat_statements
ORDER BY
    stats_since DESC -- Order by when the stats for this query were last accumulated/reset
LIMIT 50;
```