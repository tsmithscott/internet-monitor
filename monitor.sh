#!/bin/sh

# Check if CONTAINERS is set
if [ -z "$CONTAINERS" ]; then
  echo "Error: CONTAINERS environment variable not set."
  echo "Set it to a space-separated list of container names to restart."
  exit 1
fi

# Strip quotes that docker compose keeps literally in list-style environment entries,
# e.g. - CONTAINERS="a b" arrives as the value "a b" including the quotes
CONTAINERS=$(printf '%s' "$CONTAINERS" | tr -d "\"'")

# Configuration (all optional)
INTERVAL="${INTERVAL:-30}"                     # Seconds between checks
CHECK_URL="${CHECK_URL:-https://www.google.com}" # URL used to test connectivity
CHECK_TIMEOUT="${CHECK_TIMEOUT:-5}"            # Seconds before a single check times out
FAIL_THRESHOLD="${FAIL_THRESHOLD:-3}"          # Consecutive failed checks before the internet is declared down
RESTART_DELAY="${RESTART_DELAY:-0}"            # Seconds to wait after the internet returns before restarting
RESTART_RETRIES="${RESTART_RETRIES:-3}"        # Attempts per container if docker restart fails
RESTART_RETRY_DELAY="${RESTART_RETRY_DELAY:-10}" # Seconds between restart attempts

# Validate numeric settings
for var in INTERVAL CHECK_TIMEOUT FAIL_THRESHOLD RESTART_DELAY RESTART_RETRIES RESTART_RETRY_DELAY; do
  eval "value=\$$var"
  case "$value" in
    ''|*[!0-9]*)
      echo "Error: $var must be a non-negative integer (got '$value')."
      exit 1
      ;;
  esac
done

if [ "$FAIL_THRESHOLD" -lt 1 ] || [ "$INTERVAL" -lt 1 ] || [ "$CHECK_TIMEOUT" -lt 1 ] || [ "$RESTART_RETRIES" -lt 1 ]; then
  echo "Error: INTERVAL, CHECK_TIMEOUT, FAIL_THRESHOLD and RESTART_RETRIES must be at least 1."
  exit 1
fi

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

restart_container() {
  attempt=1
  while [ "$attempt" -le "$RESTART_RETRIES" ]; do
    log "Restarting $1 (attempt $attempt/$RESTART_RETRIES)..."
    if docker restart "$1" > /dev/null; then
      log "Restarted $1."
      return 0
    fi
    attempt=$((attempt + 1))
    [ "$attempt" -le "$RESTART_RETRIES" ] && sleep "$RESTART_RETRY_DELAY"
  done
  log "Failed to restart $1 after $RESTART_RETRIES attempts."
  return 1
}

log "Monitoring $CHECK_URL every ${INTERVAL}s (timeout ${CHECK_TIMEOUT}s, down after $FAIL_THRESHOLD consecutive failures). Will restart: $CONTAINERS"

failures=0
offline=false

while true; do
  if curl -s -o /dev/null --max-time "$CHECK_TIMEOUT" "$CHECK_URL"; then
    if [ "$offline" = true ]; then
      log "Internet restored."
      if [ "$RESTART_DELAY" -gt 0 ]; then
        log "Waiting ${RESTART_DELAY}s before restarting containers..."
        sleep "$RESTART_DELAY"
      fi
      for container in $CONTAINERS; do
        restart_container "$container"
      done
      offline=false
    elif [ "$failures" -gt 0 ]; then
      log "Check succeeded after $failures failed check(s); outage threshold not reached."
    fi
    failures=0
  else
    failures=$((failures + 1))
    if [ "$offline" = false ]; then
      if [ "$failures" -ge "$FAIL_THRESHOLD" ]; then
        log "Internet offline ($failures consecutive failed checks)."
        offline=true
      else
        log "Check failed ($failures/$FAIL_THRESHOLD)."
      fi
    fi
  fi
  sleep "$INTERVAL"
done
