/* TABLE INFO*/
SELECT
    formatReadableSize(total_bytes) AS compressed_size,
    formatReadableSize(total_bytes_uncompressed) AS uncompressed_size,
    formatReadableQuantity(total_rows) AS total_rows
FROM system.tables
WHERE name = 'ami_silver'
FORMAT vertical;

/*ANALYTICAL LONG QUERY*/
SELECT
    ppe.ppe,
    toYear(ami.measurement_time) AS year,
    toMonth(ami.measurement_time) AS month,
    avg(ami.energy_active_l1) AS avg_energy_usage_l1,
    avg(ami.energy_active_l2) AS avg_energy_usage_l2,
    avg(ami.energy_active_l3) AS avg_energy_usage_l3
    FROM ami_silver AS ami
JOIN ppe_ami_dict AS ppe ON ami.device_id = ppe.ami
WHERE ppe.ppe = 'PPE065221' 
--AND ami.device_id='AMI-PL-200000065221'
GROUP BY 
    ppe, 
    year, 
    month
ORDER BY year DESC,month DESC;

/*ANALYTICAL QUERY VER 2*/

SYSTEM CLEAR QUERY CACHE;
SYSTEM CLEAR QUERY CONDITION CACHE;
SYSTEM CLEAR UNCOMPRESSED CACHE;
SYSTEM CLEAR MARK CACHE;
SYSTEM CLEAR INDEX MARK CACHE;
SYSTEM CLEAR PRIMARY INDEX CACHE;
SYSTEM CLEAR COMPILED EXPRESSION CACHE;

SELECT
    ppe.ppe,
    toYear(ami.measurement_time) AS year,
    toMonth(ami.measurement_time) AS month,
    avg(ami.energy_active_l1) AS avg_energy_usage_l1,
    avg(ami.energy_active_l2) AS avg_energy_usage_l2,
    avg(ami.energy_active_l3) AS avg_energy_usage_l3
    FROM ami_silver AS ami
JOIN ppe_ami_dict AS ppe ON ami.device_id = ppe.ami
WHERE ppe.ppe = 'PPE065221' 
AND ami.device_id='AMI-PL-200000065221'
GROUP BY 
    ppe, 
    year, 
    month
ORDER BY year DESC,month DESC;

/*ANALYTIC QUERY AGG*/
SYSTEM CLEAR QUERY CACHE;
SYSTEM CLEAR QUERY CONDITION CACHE;
SYSTEM CLEAR UNCOMPRESSED CACHE;
SYSTEM CLEAR MARK CACHE;
SYSTEM CLEAR INDEX MARK CACHE;
SYSTEM CLEAR PRIMARY INDEX CACHE;
SYSTEM CLEAR COMPILED EXPRESSION CACHE;
SELECT
    year,
    month,
    avg_l1  AS avg_energy_usage_l1,
    avg_l2 AS avg_energy_usage_l2,
    avg_l3 AS avg_energy_usage_l3
FROM vw_ppe_stats
WHERE ppe = 'PPE065221'
ORDER BY year DESC,month DESC
SETTINGS use_query_cache = false;

/** SHOW SCHEMA FOR SQLDay2026*/

/*INSERT NEW DATA FOR THIS PPE*/
INSERT INTO ami_ingest(msg)
WITH last_data AS
    (
      SELECT
          ppe,
          max(energy_usage_total) AS energy_active_total,
          max(last_measurement_time) AS last_measurement_time
      FROM vw_ppe_stats
      GROUP BY ALL
    ), reads 
    AS
    (
SELECT
    concat('MSG-', toString(toUnixTimestamp(current_timestamp())), toString(rowNumberInAllBlocks())) AS message_id,
    case when year(ld.last_measurement_time) = 1970 then toDateTime('2024-01-01 00:00:00') 
      else ld.last_measurement_time end + toIntervalMinute(step * 15)  AS measurement_time,
    ami.ami as device_id,
    (coalesce(ld.energy_active_total, 0.) + (step * 0.75) + (randCanonical(1) * 0.1)) AS energy_active_total,
    round((rand(1) % 250) / 100., 2) AS energy_active_l1,
    round((rand(2) % 250) / 100., 2) AS energy_active_l2,
    round((rand(3) % 250) / 100., 2) AS energy_active_l3
FROM ppe_ami_dict AS ami
ARRAY JOIN range(0, 3072) as step
LEFT JOIN last_data AS ld ON ami.ppe = ld.ppe
WHERE ami.ppe='PPE065221'
    )
SELECT 
format(
        '{{
          "message_header": {{
            "message_id": "{0}",
            "timestamp": "{1}",
            "source": "{2}"
          }},
          "device_details": {{
            "device_id": "{2}",
            "meter_type": "Electricity_3Phase",
            "firmware_version": "v2.4.1"
          }},
          "readings": [
            {{ "obis_code": "1.8.0", "value": {3} }},
            {{ "obis_code": "21.7.0", "value": {4} }},
            {{ "obis_code": "41.7.0", "value": {5} }},
            {{ "obis_code": "61.7.0", "value": {6} }}
          ]
        }}',
        message_id,
        measurement_time,
        device_id,
        energy_active_total,
        energy_active_l1,
        energy_active_l2,
        energy_active_l3
        )
FROM reads;


SELECT
    year,
    month,
    avg_l1  AS avg_energy_usage_l1,
    avg_l2 AS avg_energy_usage_l2,
    avg_l3 AS avg_energy_usage_l3
FROM vw_ppe_stats
WHERE ppe = 'PPE065221'
ORDER BY year DESC,month DESC
SETTINGS use_query_cache = false;


/* AVG USAGE L1 -ALL DATA*/
SELECT avg(energy_active_l1) AS avg_energy_active_l1
FROM ami_silver;

/*AVG USAGE L3 -ALL DATA*/
SELECT avg(energy_active_l3) AS avg_energy_active_l3
FROM ami_silver
SETTINGS 
    use_query_cache = 0,
    use_query_condition_cache = 0;

/* PLAN FOR AVG USAGE L1 -ALL DATA */
EXPLAIN indexes =1 
SELECT avg(energy_active_l1) AS avg_energy_active_l1
FROM ami_silver;

/* PLAN FOR AVG USAGE L1 -ALL DATA */
EXPLAIN indexes =1 
SELECT avg(energy_active_l3) AS avg_energy_active_l3
FROM ami_silver;


/*SHOW ami_silver*/
SHOW CREATE TABLE ami_silver


SELECT 
    table,
    sum(rows) AS projection_rows,
    formatReadableSize(sum(bytes_on_disk)) AS disk_size
FROM system.parts
WHERE database = 'SQLDay2026'
  AND table = 'ami_silver'
  AND active
  AND arrayExists(p -> p = 'avg_energy_active_l1_proj', projections)
GROUP BY table;
