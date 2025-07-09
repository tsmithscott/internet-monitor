#!/bin/sh

# Check if CONTAINERS is set
if [ -z "$CONTAINERS" ]; then
  echo "Error: CONTAINERS environment variable not set."
  echo "Set it to a space-separated list of container names to restart."
  exit 1
fi

# Use INTERVAL variable if set, otherwise default to 10 seconds
INTERVAL="${INTERVAL:-10}"

echo "Monitoring internet connection every $INTERVAL seconds. Will restart: $CONTAINERS"

while true; do
  if curl -s https://www.google.com --max-time 5 > /dev/null; then
    if [ -f /tmp/offline ]; then
      echo 'Internet restored. Restarting containers...'
      for container in $CONTAINERS; do
        echo "Restarting $container..."
        docker restart "$container"
      done
      rm /tmp/offline
    fi
  else
    echo 'Internet offline'
    touch /tmp/offline
  fi
  sleep "$INTERVAL"
done
