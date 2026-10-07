#!/bin/bash
# Simulate high CPU usage on the host
echo "Starting CPU stress test (60 seconds)..."
echo "   Watch Grafana: CPU usage will spike to ~95%"

if command -v stress-ng &>/dev/null; then
  stress-ng --cpu $(nproc) --timeout 60s
elif command -v stress &>/dev/null; then
  stress --cpu $(nproc) --timeout 60
else
  echo "   Using bash CPU burn (install stress-ng for better results)"
  end=$((SECONDS + 60))
  while [ $SECONDS -lt $end ]; do
    :
  done
fi

echo "CPU stress test finished -- alert should resolve in ~1 minute"
