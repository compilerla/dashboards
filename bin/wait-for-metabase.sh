#!/usr/bin/env bash
# wait-for-metabase.sh - Polls Metabase health endpoint until it is ready

set -euo pipefail

METABASE_HOST="${METABASE_URL:-http://metabase:3000}"
HEALTH_URL="${METABASE_HOST}/api/health"

echo "Waiting for Metabase to be ready at ${HEALTH_URL}..."

until curl -s -f "${HEALTH_URL}" > /dev/null 2>&1; do
    echo "Metabase is still initializing... waiting 5 seconds."
    sleep 5
done

echo "Metabase is up and healthy at ${METABASE_HOST}!"
