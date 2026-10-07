#!/bin/bash
echo "Starting Infrastructure Observability Lab..."
docker compose up -d
echo ""
echo "Services:"
echo "  Grafana     -> http://localhost:3000  (admin/observability)"
echo "  Prometheus  -> http://localhost:9090"
echo "  Demo-01     -> http://localhost:8081/health"
echo "  Demo-02     -> http://localhost:8082/health"
echo "  Demo-03     -> http://localhost:8083/health"
echo ""
echo "Run ./scripts/status.sh to verify all services are up."