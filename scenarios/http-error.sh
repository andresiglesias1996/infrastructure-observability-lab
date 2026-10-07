#!/bin/bash
SERVICE=${1:-demo-01}
STATUS=${2:-500}
DURATION=${3:-60}

declare -A PORT_MAP=([demo-01]=8081 [demo-02]=8082 [demo-03]=8083)
PORT=${PORT_MAP[$SERVICE]:-8081}

echo "Setting $SERVICE to return HTTP $STATUS for ${DURATION}s..."

curl -s -X POST http://localhost:$PORT/control \
  -H "Content-Type: application/json" \
  -d "{\"status\": $STATUS}" > /dev/null

sleep $DURATION

curl -s -X POST http://localhost:$PORT/control \
  -H "Content-Type: application/json" \
  -d '{"status": 200}' > /dev/null

echo "$SERVICE restored to 200 -- alert should resolve"
