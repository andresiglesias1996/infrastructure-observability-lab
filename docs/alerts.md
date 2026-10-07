# Alert Rules

## Overview

Alerts are defined as Prometheus recording/alerting rules in `config/prometheus/rules/`.

## Alert Definitions

### Infrastructure Alerts

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| HighCPUUsage | `(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100 > 90` | 5m | critical |
| HighMemoryUsage | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 90` | 5m | critical |
| HighDiskUsage | `(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 > 85` | 5m | warning |
| HostDown | `up{job="node"} == 0` | 1m | critical |

### Service Availability Alerts

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| HTTPEndpointDown | `probe_success{job="blackbox-http"} == 0` | 1m | critical |
| HTTP5xxRateHigh | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05` | 5m | warning |
| HTTPLatencyHigh | `probe_duration_seconds{job="blackbox-http"} > 2` | 5m | warning |
| TCPUnreachable | `probe_success{job="blackbox-tcp"} == 0` | 1m | critical |
| ServiceDown | `up{job="demo-services"} == 0` | 1m | critical |

## Example Rule File

```yaml
# config/prometheus/rules/alerts.yml
groups:
  - name: infrastructure
    rules:
      - alert: HighCPUUsage
        expr: (1 - avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is {{ $value | printf \"%.1f\" }}%"

      - alert: HTTPEndpointDown
        expr: probe_success{job="blackbox-http"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "HTTP endpoint down: {{ $labels.instance }}"
          description: "The endpoint {{ $labels.instance }} is not responding."
```