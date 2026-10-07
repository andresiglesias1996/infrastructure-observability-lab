#!/bin/bash
SERVICE=${1:-demo-01}
DURATION=${2:-60}

echo "Disconnecting $SERVICE from network for ${DURATION}s..."

NETWORK=$(docker inspect $SERVICE --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null | head -1)

if [ -z "$NETWORK" ]; then
  NETWORK="infrastructure-observability-lab_observability"
fi

docker network disconnect $NETWORK $SERVICE 2>/dev/null || \
  docker network disconnect observability $SERVICE 2>/dev/null

sleep $DURATION

docker network connect $NETWORK $SERVICE 2>/dev/null || \
  docker network connect observability $SERVICE 2>/dev/null

echo "$SERVICE reconnected to network"
