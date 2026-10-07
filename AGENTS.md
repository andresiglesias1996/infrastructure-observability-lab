# Infrastructure Observability Lab — Agent Instructions

Guidelines for AI agents working in this repository.

## What this repo is

A Docker-based observability lab with Prometheus, Grafana, Loki, Blackbox Exporter, Node Exporter, and three instrumented Node.js demo services. Used to practice monitoring, alerting, and incident response.

## Stack

- **Prometheus** → `config/prometheus/prometheus.yml` and `config/prometheus/rules/`
- **Grafana** → `config/grafana/provisioning/`
- **Loki + Alloy** → `config/alloy/config.alloy`
- **Blackbox Exporter** → `config/blackbox/blackbox.yml`
- **Demo services** → `app/demo-service/` (shared image, 3 instances)
- **Incident scenarios** → `scenarios/`
- **Management scripts** → `scripts/`

## Running the lab

```bash
docker compose up -d        # start everything
docker compose ps           # check status
docker compose logs -f      # follow logs
docker compose down         # stop (preserves volumes)
docker compose down -v      # stop and wipe data
```

Services need Docker Desktop running. Check with `docker ps` before assuming anything is up.

## Key endpoints (when running)

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 (admin / observability) |
| Prometheus | http://localhost:9090 |
| Demo-01/02/03 | http://localhost:8081-8083 |
| Blackbox | http://localhost:9115 |
| Node Exporter | http://localhost:9100 |
| Loki | http://localhost:3100 |

## Demo service control API

```bash
# Inject 500 errors + 2s latency
curl -X POST http://localhost:8081/control \
  -H "Content-Type: application/json" \
  -d '{"status": 500, "delay": 2000}'

# Restore normal behavior
curl -X POST http://localhost:8081/control \
  -H "Content-Type: application/json" \
  -d '{"status": 200, "delay": 0}'
```

## MCP servers

Prometheus and Grafana MCP servers are configured in `.claude/mcp.json`. When the lab is running you can query Prometheus and Grafana directly from Claude Code.

## LLM integration patterns

See `.claude/skills/observability.md` for Python patterns: metric analysis, PromQL generation, alert correlation, and incident report generation.

## Docs

- `docs/architecture.md` — data flow diagrams
- `docs/alerts.md` — all configured alert rules with PromQL
- `docs/incidents.md` — incident runbooks
- `docs/troubleshooting.md` — common issues
- `docs/llm-integrations.md` — LLM/Claude integration reference
