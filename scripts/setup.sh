#!/bin/bash
set -e
echo "Setting up Infrastructure Observability Lab..."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "   Created .env from .env.example"
fi

mkdir -p grafana-data prometheus-data loki-data
chmod 777 grafana-data
chmod +x scripts/*.sh scenarios/*.sh

echo ""
echo "Setup complete. Run: ./scripts/start.sh"