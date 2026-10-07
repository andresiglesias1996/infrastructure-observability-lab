#!/bin/bash
echo "Infrastructure Observability Lab -- Status"
echo "============================================"

check_service() {
  local name=$1
  local url=$2
  if curl -sf "$url" > /dev/null 2>&1; then
    echo "  UP   $name"
  else
    echo "  DOWN $name  ($url)"
  fi
}

check_service "Prometheus   " "http://localhost:9090/-/ready"
check_service "Grafana      " "http://localhost:3000/api/health"
check_service "Loki         " "http://localhost:3100/ready"
check_service "Blackbox     " "http://localhost:9115/health"
check_service "Node Exporter" "http://localhost:9100/metrics"
check_service "Demo-01      " "http://localhost:8081/health"
check_service "Demo-02      " "http://localhost:8082/health"
check_service "Demo-03      " "http://localhost:8083/health"

echo ""
echo "Run: docker compose ps  -- for detailed container status"