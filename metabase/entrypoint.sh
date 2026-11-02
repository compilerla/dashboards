#!/bin/bash
set -e

# Only start socat bridge if CLOUD_SQL_CONNECTION_NAME is set
if [ -n "$CLOUD_SQL_CONNECTION_NAME" ]; then
  echo "Starting socat bridge: localhost:5432 → /cloudsql/$CLOUD_SQL_CONNECTION_NAME"
  socat TCP-LISTEN:5432,fork,reuseaddr UNIX-CONNECT:/cloudsql/$CLOUD_SQL_CONNECTION_NAME &
  sleep 1
else
  echo "CLOUD_SQL_CONNECTION_NAME not set, skipping socat bridge"
fi

# Execute the original command (Metabase startup)
exec /app/run_metabase.sh "$@"
