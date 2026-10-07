#!/bin/bash
SERVICE=${1:-demo-01}
DELAY_MS=${2:-3000}
DURATION=${3:-60}

declare -A PORT_MAP=([demo-01]=8081 [demo-02]=8082 [demo-03]=8083)
PORT=${PORT_MAP[$SERVICE]:-8081}

echo "Adding ${DELAY_MS}ms latency to $SERVICE for ${DURATION}s..."

curl -s -X POST http://localhost:$PORT/control \
  -H "Content-Type: application/json" \
  -d "{\"delay\": $DELAY_MS}" > /dev/null

sleep $DURATION

curl -s -X POST http://localhost:$PORT/control \
  -H "Content-Type: application/json" \
  -d '{"delay": 0}' > /dev/null

echo "Latency removed from $SERVICE"
