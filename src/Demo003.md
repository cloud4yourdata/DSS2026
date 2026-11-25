```sh
echo "SELECT * FROM SQLDay2026.ami_silver AS ami WHERE ami.device_id = (SELECT ami FROM SQLDay2026.ppe_ami_dict ORDER BY rand() LIMIT 1) ORDER BY measurement_time DESC LIMIT 10" | clickhouse-benchmark \
  --host=localhost \
  --port=9000 \
  --user=default\
  --password=****\
  --iterations=5000 \
  --concurrency=50
```

```sh
echo "SELECT * FROM SQLDay2026.vw_ppe_stats WHERE ppe = (SELECT ppe FROM SQLDay2026.ppe_ami_dict ORDER BY rand() LIMIT 1) ORDER BY year DESC, month DESC LIMIT 6" | clickhouse-benchmark \
  --host=localhost \
  --port=9000 \
  --user=default\
  --password=****\
  --iterations=5000\
  --concurrency=50
```