# Using AI Agents with this Observability Lab

This lab is designed to integrate with AI agents for intelligent monitoring and incident response.

## Patterns

### 1. Analyzing Prometheus Query Results with Claude

Use the Claude API to analyze PromQL query results and generate human-readable summaries:

```python
import anthropic
import requests

client = anthropic.Anthropic()

def analyze_metrics(promql_query: str) -> str:
    # Query Prometheus
    response = requests.get(
        "http://localhost:9090/api/v1/query",
        params={"query": promql_query}
    )
    data = response.json()

    # Ask Claude to analyze
    message = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"Analyze these Prometheus metrics and explain what they indicate about system health:\n\n{data}"
        }]
    )
    return message.content[0].text

# Example usage
analysis = analyze_metrics('rate(http_requests_total{status=~"5.."}[5m])')
print(analysis)
```

### 2. Generating PromQL Queries via AI

Let Claude help you write complex PromQL queries:

```python
def generate_promql(description: str) -> str:
    message = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        messages=[{
            "role": "user",
            "content": f"""Generate a PromQL query for: {description}

Available metrics from this lab:
- node_cpu_seconds_total (labels: mode, cpu)
- node_memory_MemAvailable_bytes, node_memory_MemTotal_bytes
- node_filesystem_avail_bytes, node_filesystem_size_bytes (labels: mountpoint)
- http_requests_total (labels: method, path, status, service)
- http_request_duration_seconds (histogram)
- probe_success (labels: job, instance)
- probe_duration_seconds (labels: job, instance)

Return only the PromQL expression, no explanation."""
        }]
    )
    return message.content[0].text

query = generate_promql("CPU usage percentage averaged over 5 minutes")
print(query)
```

### 3. MCP Server for Prometheus

Connect Prometheus to Claude Code via MCP:

```json
// .claude/mcp.json
{
  "mcpServers": {
    "prometheus": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-prometheus"],
      "env": {
        "PROMETHEUS_URL": "http://localhost:9090"
      }
    }
  }
}
```

Then in Claude Code:
```
Query Prometheus for the current error rate on demo-01
```

### 4. MCP Server for Grafana

```json
{
  "mcpServers": {
    "grafana": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-grafana"],
      "env": {
        "GRAFANA_URL": "http://localhost:3000",
        "GRAFANA_TOKEN": "your-service-account-token"
      }
    }
  }
}
```

### 5. Alert Correlation with LLMs

When multiple alerts fire simultaneously, use AI to identify the root cause:

```python
def correlate_alerts(firing_alerts: list[dict]) -> str:
    alert_summary = "\n".join([
        f"- {a['labels']['alertname']}: {a['annotations'].get('description', '')}"
        for a in firing_alerts
    ])

    message = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"""Multiple alerts fired at the same time. Identify the likely root cause:

{alert_summary}

Provide:
1. Most likely root cause
2. Recommended investigation steps
3. Suggested remediation"""
        }]
    )
    return message.content[0].text
```

### 6. Automated Incident Reports

Generate incident reports from Grafana and Loki data:

```python
def generate_incident_report(service: str, start_time: str, end_time: str) -> str:
    # Fetch metrics during incident window
    metrics = requests.get(
        "http://localhost:9090/api/v1/query_range",
        params={
            "query": f'http_requests_total{{service="{service}"}}',
            "start": start_time,
            "end": end_time,
            "step": "60"
        }
    ).json()

    message = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": f"Generate a formal incident report for service {service} based on these metrics: {metrics}"
        }]
    )
    return message.content[0].text
```

## Resources

- [Anthropic API Docs](https://docs.anthropic.com)
- [Claude Code MCP Guide](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Grafana Incident AI](https://grafana.com/docs/grafana-cloud/incident/)
- [Prometheus HTTP API](https://prometheus.io/docs/prometheus/latest/querying/api/)