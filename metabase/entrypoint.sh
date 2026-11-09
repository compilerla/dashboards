#!/bin/bash
set -euo pipefail

# Cloud Run mounts the Cloud SQL proxy at /cloudsql/
# The directory is not listable on Cloud Run even though the socket is connectable,
# so CLOUD_SQL_INSTANCE_CONNECTION_NAME must be set explicitly.
if [[ -z "${CLOUD_SQL_INSTANCE_CONNECTION_NAME:-}" ]]; then
  detected=$(ls /cloudsql 2>/dev/null | head -1 || true)
  if [[ -n "$detected" ]]; then
    CLOUD_SQL_INSTANCE_CONNECTION_NAME="$detected"
  fi
fi

if [[ -n "${CLOUD_SQL_INSTANCE_CONNECTION_NAME:-}" ]]; then
  SOCK_PATH="/cloudsql/${CLOUD_SQL_INSTANCE_CONNECTION_NAME}/.s.PGSQL.5432"
  if [[ -S "$SOCK_PATH" ]]; then
    ln -sf "$SOCK_PATH" /app/pg.sock
    nohup socat -d -d TCP4-LISTEN:5432,fork UNIX-CONNECT:/app/pg.sock &
  fi
fi

# Run the official Metabase entrypoint
exec /app/run_metabase.sh
