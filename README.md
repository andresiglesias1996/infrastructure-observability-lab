# Infrastructure Observability Lab

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=flat&logo=docker&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)

A production-style observability environment with Prometheus, Grafana, Loki, Blackbox Exporter, and Node Exporter — featuring reproducible failure scenarios and automated alerting.

## Quick Start

```bash
git clone https://github.com/andresiglesias1996/infrastructure-observability-lab.git
cd infrastructure-observability-lab
./scripts/setup.sh
./scripts/start.sh
```

Open Grafana at **http://localhost:3000** (admin / observability)

## Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Prometheus | latest | Metrics collection & alerting |
| Grafana | latest | Visualization & dashboards |
| Loki | latest | Log aggregation |
| Grafana Alloy | latest | Log collection agent |
| Node Exporter | latest | Host-level metrics |
| Blackbox Exporter | latest | HTTP/TCP endpoint probing |
| Demo Service x3 | Node.js 22 | Instrumented app under observation |

## Lab Phases

- [x] **Phase 1** — Host Monitoring (CPU, memory, disk, network via Node Exporter)
- [x] **Phase 2** — Availability Probing (HTTP/TCP via Blackbox Exporter)
- [ ] **Phase 3** — Alerting Rules + Notification Channels (Slack, PagerDuty)
- [x] **Phase 4** — Incident Simulation Scripts
- [x] **Phase 5** — Log Aggregation (Loki + Alloy)
- [ ] **Phase 6** — Distributed Tracing (Tempo + OpenTelemetry)

## Incident Scenarios

Run these scripts to simulate realistic failure conditions and observe the effects in Grafana:

| Scenario | Command | What happens |
|----------|---------|--------------|
| Service down | `./scenarios/service-down.sh demo-01 60` | demo-01 stops for 60s |
| HTTP 500 errors | `./scenarios/http-error.sh demo-01 500 60` | Returns 500 for 60s |
| High latency | `./scenarios/latency-high.sh demo-01 3000 60` | 3s delay for 60s |
| Network partition | `./scenarios/network-failure.sh demo-01 60` | Network disconnect |
| CPU spike | `./scenarios/cpu-high.sh` | Burns CPU for 60s |
| Memory pressure | `./scenarios/memory-high.sh` | Fills RAM for 60s |
| Disk fill | `./scenarios/disk-high.sh 1000` | Writes 1GB temp file |

## Architecture

```
  +--------------------------------------------------+
  |                   Grafana :3000                  |
  +------------------+-------------------------------+
                     |
        +------------+------------+
        |                         |
  +-----+------+           +------+-----+
  | Prometheus |           |    Loki    |
  |   :9090    |           |   :3100    |
  +-----+------+           +------+-----+
        |                         |
  +-----+------+           +------+-----+
  |  Scrapes:  |           |   Alloy    |
  | node-exp.  |           | (log ship) |
  | demo 1/2/3 |           +------------+
  | blackbox   |
  +------------+
```

## Service Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | Dashboards (admin/observability) |
| Prometheus | http://localhost:9090 | Metrics & alerting |
| Demo-01 | http://localhost:8081 | Demo service 1 |
| Demo-02 | http://localhost:8082 | Demo service 2 |
| Demo-03 | http://localhost:8083 | Demo service 3 |
| Blackbox | http://localhost:9115 | Probe exporter |
| Node Exporter | http://localhost:9100 | Host metrics |
| Loki | http://localhost:3100 | Log storage |

## Demo Service API

Each demo service exposes:

- `GET /health` — Health check (configurable status code)
- `GET /api/status` — Service info and current state
- `GET /metrics` — Prometheus metrics
- `POST /control` — Toggle failure mode: `{"status": 500, "delay": 2000}`

## Documentation

- [Architecture](docs/architecture.md) — Stack overview and data flows
- [Alert Rules](docs/alerts.md) — All configured alerts with PromQL
- [Incident Runbooks](docs/incidents.md) — Step-by-step incident guides
- [Troubleshooting](docs/troubleshooting.md) — Common issues and fixes
- [LLM Integrations](docs/llm-integrations.md) — Integrating Claude/LLMs with this lab

## Management Scripts

```bash
./scripts/setup.sh    # First-time setup
./scripts/start.sh    # Start all services
./scripts/stop.sh     # Stop all services (preserves data)
./scripts/reset.sh    # Wipe everything and start fresh
./scripts/status.sh   # Check health of all services
```