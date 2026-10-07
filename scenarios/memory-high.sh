#!/bin/bash
echo "Starting memory stress test (60 seconds)..."
echo "   Watch Grafana: Memory usage will spike"

if command -v stress-ng &>/dev/null; then
  stress-ng --vm 2 --vm-bytes 80% --timeout 60s
elif command -v stress &>/dev/null; then
  TOTAL_MEM=$(awk '/MemTotal/{print int($2 * 0.8)}' /proc/meminfo)
  stress --vm 2 --vm-bytes ${TOTAL_MEM}k --timeout 60
else
  echo "   stress-ng not found. Install: sudo apt-get install stress-ng"
  exit 1
fi

echo "Memory stress finished -- alert should resolve in ~1 minute"
