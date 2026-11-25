SELECT * FROM ami_silver AS ami
WHERE ami.device_id = (SELECT ami FROM ppe_ami_dict ORDER BY rand() LIMIT 1)
ORDER BY measurement_time DESC
LIMIT 10


SELECT * FROM SQLDay2026.vw_ppe_stats 
WHERE ppe = (SELECT ppe FROM SQLDay2026.ppe_ami_dict ORDER BY rand() LIMIT 1)
ORDER BY year DESC, month DESC
LIMIT 6;
--
SELECT
    count() AS queries,
    round(avg(query_duration_ms), 2) AS avg_ms,
    round(quantile(0.5)(query_duration_ms), 2) AS p50_ms,
    round(quantile(0.95)(query_duration_ms), 2) AS p95_ms,
    round(quantile(0.99)(query_duration_ms), 2) AS p99_ms
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%ami_silver%ORDER BY rand() LIMIT 1%'
  AND event_time >= now() - INTERVAL 10 MINUTE;


SELECT
    count() AS queries,
    round(avg(query_duration_ms), 2) AS avg_ms,
    round(quantile(0.5)(query_duration_ms), 2) AS p50_ms,
    round(quantile(0.95)(query_duration_ms), 2) AS p95_ms,
    round(quantile(0.99)(query_duration_ms), 2) AS p99_ms
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%vw_ppe_stats%ORDER BY rand() LIMIT 1%'
  AND event_time >= now() - INTERVAL 10 MINUTE;
