# Troubleshooting Guide

## Containers Not Starting

**Symptom:** `docker compose up` fails or containers exit immediately.

**Solutions:**
1. Check Docker is running: `docker info`
2. Check port conflicts: `netstat -tlnp | grep -E '3000|9090|9100|9115|3100'`
3. Check .env file: `cat .env` (must exist, copy from .env.example)
4. Check data directory permissions:
   ```bash
   ls -la grafana-data/
   chmod 777 grafana-data/
   ```
5. View container logs: `docker compose logs <service-name>`

## Prometheus Cannot Scrape Targets

**Symptom:** Targets show as DOWN in Prometheus UI (`http://localhost:9090/targets`)

**Solutions:**
1. Verify DNS resolution within Docker network:
   ```bash
   docker exec prometheus ping demo-01
   ```
2. Check if target is listening:
   ```bash
   docker exec prometheus wget -qO- http://demo-01:3000/metrics
   ```
3. Verify prometheus.yml syntax:
   ```bash
   docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
   ```
4. Reload config without restart: `curl -X POST http://localhost:9090/-/reload`

## Grafana Shows "No Data"

**Symptom:** Panels are empty, "No data" message in Grafana.

**Solutions:**
1. Check datasource connectivity: Grafana > Configuration > Data Sources > Test
2. Verify Prometheus is collecting data: `http://localhost:9090/graph`
3. Check time range in Grafana (top right) - set to "Last 15 minutes"
4. Verify dashboard is using the correct datasource name (`Prometheus`)
5. Check for query errors: click the panel title > Edit > inspect the query

## Scenario Scripts Not Working

**Symptom:** `./scenarios/http-error.sh` returns curl errors.

**Solutions:**
1. Ensure services are running: `./scripts/status.sh`
2. Check script permissions: `chmod +x scenarios/*.sh`
3. Verify correct port: demo-01=8081, demo-02=8082, demo-03=8083
4. Test manually:
   ```bash
   curl -X POST http://localhost:8081/control \
     -H "Content-Type: application/json" \
     -d '{"status": 500}'
   ```

## Node Exporter Not Collecting Host Metrics

**Symptom:** `node_cpu_seconds_total` returns no data.

**Solutions:**
1. Node Exporter uses `network_mode: host` - verify it started: `docker ps | grep node-exporter`
2. Check if accessible: `curl http://localhost:9100/metrics | head -20`
3. On Linux, verify /proc and /sys mounts are available
4. On macOS/Windows: node-exporter shows container-level metrics, not host metrics

## Loki Not Receiving Logs

**Symptom:** Loki datasource shows no log streams in Grafana.

**Solutions:**
1. Check Loki is ready: `curl http://localhost:3100/ready`
2. Check Alloy status: `docker compose logs alloy`
3. Verify Alloy config mounts: `docker exec alloy cat /etc/alloy/config.alloy`
4. Check for log files in the configured paths