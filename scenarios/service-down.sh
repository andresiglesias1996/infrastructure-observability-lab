#!/bin/bash
SERVICE=${1:-demo-01}
DURATION=${2:-60}

echo "Stopping $SERVICE for ${DURATION}s..."
echo "   Watch Grafana: Service will go DOWN, HTTP probe will fail"

docker compose stop $SERVICE

echo "   $SERVICE stopped. Waiting ${DURATION}s..."
sleep $DURATION

docker compose start $SERVICE
echo "$SERVICE restarted -- Grafana should show recovery"
