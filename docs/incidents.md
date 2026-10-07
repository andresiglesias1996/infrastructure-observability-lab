# Incident Runbooks

## Scenario 1: Website Unavailable (service-down)

### Symptoms
- Grafana shows HTTP probe `probe_success == 0` for affected service
- Alert fires: `HTTPEndpointDown`
- Users report 502/connection refused errors

### Detection
- Blackbox Exporter HTTP probe fails
- TCP probe also fails (service not listening)

### Investigation Steps
1. Check Docker containers: `docker compose ps`
2. Inspect container logs: `docker compose logs demo-01`
3. Verify network connectivity: `docker exec prometheus ping demo-01`
4. Check resource constraints: `docker stats`

### Root Cause
Service container crashed or was stopped intentionally (via `scenarios/service-down.sh`).

### Recovery
```bash
docker compose start demo-01
# Verify
curl http://localhost:8081/health
```

### Lessons Learned
- Implement health checks with auto-restart (`restart: unless-stopped`)
- Add liveness/readiness probes
- Set up PagerDuty/Slack alerting for immediate notification

---

## Scenario 2: API Latency Spike (latency-high)

### Symptoms
- Grafana shows `probe_duration_seconds > 2s` for demo service
- Alert fires: `HTTPLatencyHigh`
- Users report slow response times

### Detection
- Blackbox HTTP probe duration exceeds threshold
- Application `http_request_duration_seconds` histogram shows high p99

### Investigation Steps
1. Check current response time: `curl -w "%{time_total}" http://localhost:8081/api/status`
2. Check service state: `curl http://localhost:8081/api/status | jq .response_delay_ms`
3. Check host resources: Prometheus query `node_cpu_seconds_total`
4. Review application logs: `docker compose logs demo-01 --tail=50`

### Root Cause
Artificial delay injected via `/control` endpoint (simulates slow DB query, external API, etc.)

### Recovery
```bash
curl -X POST http://localhost:8081/control \
  -H "Content-Type: application/json" \
  -d '{"delay": 0}'
```

### Lessons Learned
- Set SLO-based alerts (p99 latency < 500ms)
- Implement circuit breakers
- Add distributed tracing to identify bottleneck

---

## Scenario 3: HTTP 500 Errors (http-error)

### Symptoms
- Grafana shows `probe_success == 0` or HTTP status != 200
- Alert fires: `HTTP5xxRateHigh`
- Error rate climbs in Prometheus metrics

### Detection
- Blackbox probe reports non-200 status code
- `http_requests_total{status="500"}` counter increasing

### Investigation Steps
1. Test endpoint manually: `curl -i http://localhost:8081/health`
2. Check error logs: `docker compose logs demo-01 | grep -i error`
3. Query error rate in Prometheus: `rate(http_requests_total{status=~"5.."}[5m])`
4. Check service health state: `curl http://localhost:8081/api/status`

### Root Cause
Health status changed to 500 (simulates application error, missing dependency, etc.)

### Recovery
```bash
curl -X POST http://localhost:8081/control \
  -H "Content-Type: application/json" \
  -d '{"status": 200}'
```

### Lessons Learned
- Implement proper error budgets and SLOs
- Add structured logging for easier root cause analysis
- Use Loki to correlate log spikes with metric anomalies