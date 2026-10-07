# Architecture

## Stack Overview

```
                    +------------------+
                    |     Grafana      |
                    |   :3000          |
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
    +---------+--------+        +-----------+------+
    |   Prometheus     |        |      Loki        |
    |   :9090          |        |      :3100       |
    +---------+--------+        +-----------+------+
              |                             |
    +---------+--------+        +-----------+------+
    | Scrape targets:  |        |  Grafana Alloy   |
    | - node-exporter  |        |  (log collector) |
    | - demo-01/02/03  |        +------------------+
    | - blackbox-exp.  |
    +------------------+
```

## Data Flows

### Metrics (Prometheus)
1. Prometheus scrapes `/metrics` endpoints every 15s
2. Node Exporter exposes host-level metrics (CPU, RAM, disk, network)
3. Demo services expose application metrics via prom-client
4. Blackbox Exporter probes HTTP/TCP endpoints on demand
5. Prometheus stores TSDB data; Grafana queries via PromQL

### Logs (Loki)
1. Grafana Alloy tails log files from containers/host
2. Alloy pushes log streams to Loki via push API
3. Grafana queries Loki using LogQL

### Traces (Roadmap)
1. Apps instrument with OpenTelemetry SDK
2. OTel Collector batches and forwards spans
3. Grafana Tempo stores traces
4. Grafana links traces to metrics/logs

## Components

| Component | Image | Port | Role |
|-----------|-------|------|------|
| Prometheus | prom/prometheus | 9090 | Metrics storage & alerting |
| Grafana | grafana/grafana | 3000 | Visualization & dashboards |
| Node Exporter | prom/node-exporter | 9100 | Host metrics |
| Blackbox Exporter | prom/blackbox-exporter | 9115 | Endpoint probing |
| Demo Service x3 | custom Node.js | 8081-8083 | Application under observation |
| Loki | grafana/loki | 3100 | Log aggregation |
| Alloy | grafana/alloy | - | Log collection agent |

## Lab Phases

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Host monitoring (CPU, RAM, disk, network) | Done |
| 2 | Availability probing (HTTP/TCP via Blackbox) | Done |
| 3 | Alerting rules + notification channels | Roadmap |
| 4 | Incident simulation with scenario scripts | Done |
| 5 | Log aggregation (Loki + Alloy) | Done |
| 6 | Distributed tracing (Tempo + OTel) | Roadmap |