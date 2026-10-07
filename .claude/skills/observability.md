# Observability Lab — AI Integration Patterns

Patterns for using Claude and LLMs to interact with this lab's Prometheus, Grafana, and Loki stack.

## Analyze Prometheus metrics

```python
import anthropic
import requests

client = anthropic.Anthropic()

def analyze_metrics(promql_query: str) -> str:
    response = requests.get(
        "http://localhost:9090/api/v1/query",
        params={"query": promql_query}
    )
    data = response.json()

    message = client.messages.create(
        model="claude-sonnet-5-5",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": f"Analyze these Prometheus metrics and explain what they indicate about system health:\n\n{data}"
        }]
    )
    return message.content[0].text

analysis = analyze_metrics('rate(http_requests_total{status=~"5.."}[5m])')
print(analysis)
```

## Generate PromQL queries

```python
def generate_promql(description: str) -> str:
    message = client.messages.create(
        model="claude-sonnet-5-5",
        max_tokens=512,
        messages=[{
            "role": "user",
            "content": f"""Generate a PromQL query for: {description}

Available metrics:
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
```

## Correlate alerts (root cause analysis)

```python
def correlate_alerts(firing_alerts: list[dict]) -> str:
    alert_summary = "\n".join([
        f"- {a['labels']['alertname']}: {a['annotations'].get('description', '')}"
        for a in firing_alerts
    ])

    message = client.messages.create(
        model="claude-sonnet-5-5",
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

## Generate incident report

```python
def generate_incident_report(service: str, start_time: str, end_time: str) -> str:
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
        model="claude-sonnet-5-5",
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
- [Prometheus HTTP API](https://prometheus.io/docs/prometheus/latest/querying/api/)
