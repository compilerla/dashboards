# Infrastructure Reference

This section contains technical details about the infrastructure.

## GCP Resources

### Cloud Run

- Service: `metabase`
- Image: `ghcr.io/compilerla/dashboards/metabase` (tagged per-commit SHA, set via `TF_VAR_metabase_image_tag` in GitHub Actions)
- Region: `us-west1`
- Scaling: min 1, max 3 instances
- CPU/Memory: 1 vCPU / 4 GiB RAM (limits)
- Ingress: `INGRESS_TRAFFIC_ALL`
- Service Account: `metabase-runner@data-warehouse-492522.iam.gserviceaccount.com`
- Public Access: `allUsers` granted `roles/run.invoker`

### Cloud SQL

- Instance: `metabase-db-{suffix}` (random hex suffix, e.g. `metabase-db-cba276d9`)
- Version: PostgreSQL 18
- Tier: `db-perf-optimized-N-2`
- Disk: 10 GB PD_SSD, auto-resize enabled
- Availability: Zonal
- Backup: enabled (point-in-time recovery, 7-day retention)
- Database: `metabase`
- User: `metabase`

### BigQuery

- Datasets (all in `data-warehouse-492522`, location: `US`):
  - `raw` — Data as-ingested from source systems by Airflow pipelines
  - `staging` — Intermediate transformation tables used between raw ingestion and analytics
  - `analytics` — Cleaned, transformed, and reporting-ready tables and views queried by Metabase

### GCS

- Bucket: `compiler-data-lake`
- Location: `us-west1`
- Access: uniform bucket-level access enabled

### Secret Manager

- `metabase-db-password` — PostgreSQL password for the `metabase` user
- `metabase-encryption-secret-key` — 32-character Metabase encryption key

### IAM Service Accounts

- **metabase-runner** (`metabase-runner@data-warehouse-492522.iam.gserviceaccount.com`)
  - `roles/bigquery.jobUser`
  - `roles/cloudsql.client`
  - `roles/secretmanager.secretAccessor`

- **github-actions-runner** (`github-actions-runner@data-warehouse-492522.iam.gserviceaccount.com`)
  - `roles/editor`
  - `roles/resourcemanager.projectIamAdmin`
  - `roles/iam.serviceAccountTokenCreator`

### Workload Identity Federation (WIF)

- Pool: `github-actions-pool`
- Provider: `github-actions-provider`
- OIDC Issuer: `https://token.actions.githubusercontent.com`
- Condition: `assertion.repository == 'compilerla/dashboards'`
- Binding: `github-actions-runner` service account granted `roles/iam.workloadIdentityUser` via the WIF pool

### Enabled APIs

- `bigquery.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `iam.googleapis.com`
- `run.googleapis.com`
- `secretmanager.googleapis.com`
- `sqladmin.googleapis.com`
- `sql-component.googleapis.com`
- `vpcaccess.googleapis.com`
