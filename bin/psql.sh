#!/usr/bin/env bash
# psql.sh - Connects to the local PostgreSQL container from inside the dev container

set -euo pipefail

DB_HOST="${MB_DB_HOST:-postgres}"
DB_PORT="${MB_DB_PORT:-5432}"
DB_USER="${MB_DB_USER:-metabase}"
DB_NAME="${MB_DB_DBNAME:-metabase}"

export PGPASSWORD="${POSTGRES_PASSWORD:-metabase}"

echo "Connecting to PostgreSQL at ${DB_HOST}:${DB_PORT}/${DB_NAME} as user ${DB_USER}..."
exec psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" "$@"
