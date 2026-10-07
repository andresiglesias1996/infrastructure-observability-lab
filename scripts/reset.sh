#!/bin/bash
echo "Resetting Infrastructure Observability Lab..."
echo "   This will remove all containers and data."
read -p "   Are you sure? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker compose down -v
  rm -rf grafana-data prometheus-data loki-data
  echo "Lab reset. Run ./scripts/setup.sh to start fresh."
fi