# Custom Metabase Docker Image

This explains how the Metabase image connects to Cloud SQL PostgreSQL via Cloud Run's built-in Cloud SQL proxy, using `socat` to bridge a Unix socket to TCP.

## Why a custom image?

Metabase ships with an embedded H2 database by default. For production on Cloud Run we need it to use Cloud SQL PostgreSQL. Cloud Run mounts the Cloud SQL proxy as a Unix socket under `/cloudsql/`, but Metabase expects a TCP connection, so we need a bridge.

## How it works

### Image layers

`metabase/Dockerfile` starts from the official `metabase/metabase` image and adds only `socat`. No socket factory JAR, no classpath manipulation, no entrypoint patching.

### Entrypoint behavior

`metabase/entrypoint.sh` runs before the official Metabase entrypoint and performs these steps:

1. Reads `CLOUD_SQL_INSTANCE_CONNECTION_NAME` from the environment. If unset, it auto-detects the instance name from the `/cloudsql/` directory.
2. Symlinks the Cloud SQL Unix socket into a known path inside the container.
3. Spawns `socat` in the background to forward TCP port 5432 to the Unix socket.
4. `exec`s the official Metabase entrypoint so Metabase connects to `127.0.0.1:5432` as a normal PostgreSQL client.

If no Cloud SQL socket is present (e.g. local development via Docker Compose), the entrypoint skips all of the above and runs the official Metabase entrypoint unmodified.

### Terraform environment variables

Terraform injects the following environment variables into the Cloud Run service:

| Variable | Value | Purpose |
|----------|-------|---------|
| `CLOUD_SQL_INSTANCE_CONNECTION_NAME` | e.g. `data-warehouse-492522:us-west1:metabase-db-40ee866c` | Tells the entrypoint which instance to bridge |
| `MB_DB_TYPE` | `postgres` | Tells Metabase to use PostgreSQL |
| `MB_DB_HOST` | `127.0.0.1` | Socat listens on localhost:5432 |
| `MB_DB_DBNAME` | `metabase` | Database name |
| `MB_DB_USER` | `metabase` | Database user |
| `MB_DB_PASS` | Resolved from Secret Manager | Database password |

Cloud Run also mounts the Cloud SQL volume at `/cloudsql` so the proxy socket is available at container startup. This is configured in the Terraform `volume_mounts` block.

### Local vs. production

| Environment | Database config | Behavior |
|-------------|----------------|----------|
| **Cloud Run** | `MB_DB_HOST=127.0.0.1` + `CLOUD_SQL_INSTANCE_CONNECTION_NAME` | Socat bridges the Cloud SQL Unix socket to TCP 5432 |
| **Local (compose)** | `MB_DB_HOST=postgres` | No Cloud SQL proxy — Metabase connects directly to the local PostgreSQL container. The entrypoint skips socat setup |

## Upgrade path

When upgrading the Metabase version:

1. Update the base image tag in `metabase/Dockerfile`
2. Rebuild the image (`docker compose build metabase`)
3. Test locally: `docker compose up -d metabase` and check logs for `Successfully verified PostgreSQL`
4. Push a release tag to trigger CI/CD
