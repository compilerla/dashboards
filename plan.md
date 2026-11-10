# Compiler's Warehouse Implementation Plan: GCP Cloud Run & Docker

This document outlines the end-to-end architecture, repository structure, and phased implementation plan for deploying an open-source **Metabase** instance on **Google Cloud Platform (GCP)** without Kubernetes overhead.

---

## 1. System Architecture

Refer to [docs/explanation/architecture.md](docs/explanation/architecture.md) for the detailed system architecture and data flow diagrams.

---

## 2. Key Architecture Decisions

| Component                | Selected Configuration                 | Rationale                                                                                                                                      |
| :----------------------- | :------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| **GCP Project**          | `data-warehouse-492522`                | Host project containing BigQuery analytics warehouse and infrastructure.                                                                       |
| **GCP Region**           | `us-west1` (Oregon)                    | Optimal low-latency to California; standard Tier 1 GCP pricing (matches `us-central1` costs).                                                  |
| **Domain & Ingress**     | `*.run.app` (Cloud Run default)        | GCP-managed HTTPS via default Cloud Run domain; no custom domain or DNS configuration required.                                                |
| **Container Runtime**    | **GCP Cloud Run**                      | Zero Kubernetes overhead; fully managed container lifecycle; integrated Cloud SQL proxy; native HTTPS.                                         |
| **Instance Policy**      | **Min Instances: 1**                   | Prevents cold-start delays and ensures Metabase background syncs, alerts, and scheduled pulses run continuously.                               |
| **Application Database** | **Cloud SQL PostgreSQL**               | Production-ready state store for Metabase (dashboards, queries, users, permissions). Never use the default embedded H2 database in production. |
| **Analytics Warehouse**  | **Google BigQuery**                    | Native driver built into Metabase. Authenticated via the Cloud Run attached Service Account (no JSON key rotation needed).                     |
| **Data Orchestration**   | **Google Cloud Workflows**             | Serverless orchestration for API and file ingestion. Low-cost and scales to zero.                                                              |
| **Data Modeling**        | **dbt Core**                           | Open-source analytics modeling; run as containerized jobs on Cloud Run to avoid dedicated VMs.                                                 |
| **Ingestion Method**     | **Python Scripts**                     | Leverage existing Python libraries (e.g., Toggl access) to land raw data into GCS.                                                             |
| **Authentication**       | **Dual Auth: Google OAuth + Password** | Google Workspace OAuth restricted to `@compiler.la` for internal staff, plus password invites enabled for external stakeholders.               |
| **Outbound Email**       | **Google Workspace SMTP Relay**        | Reliable delivery of user invitations, password resets, and automated dashboard subscriptions.                                                 |
| **Secrets Management**   | **GCP Secret Manager**                 | Securely injects database passwords, encryption keys, and client secrets directly into container environment variables.                        |
| **IaC & Automation**     | **Terraform + GitHub Actions**         | Fully reproducible infrastructure; automated `terraform plan` on Pull Requests and `terraform apply` on merge to `main`.                       |
| **Local Development**    | **VS Code Dev Containers**             | Cross-platform consistency across Linux, macOS, and Windows matching `compilerla` Dev Container standards.                                     |

---

## 3. Recommended Repository Structure

Refer to [docs/reference/structure.md](docs/reference/structure.md) for the detailed repository structure.

---

## 4. Production Configuration Details

### 4.1 Cloud Run Sizing & Environment Variables

- **CPU & Memory**: 1 vCPU, 4 GiB RAM (can scale to 2 vCPU / 4 GiB if user concurrency grows).
- **Scaling Rules**: `min_instances = 1`, `max_instances = 3`.
- **Container Concurrency**: 80 concurrent requests.
- **Essential Environment Variables**:
  - `MB_DB_TYPE`: `postgres`
  - `MB_DB_HOST`: `127.0.0.1` (socat bridges Cloud SQL Unix socket to TCP 5432)
  - `MB_DB_DBNAME`: `metabase`
  - `MB_DB_USER`: `metabase`
  - `MB_DB_PASS`: Secret reference from Secret Manager.
  - `MB_ENCRYPTION_SECRET_KEY`: 32+ character key from Secret Manager (used to encrypt data source credentials stored in Metabase).
  - `JAVA_OPTS`: `"-Xmx1536m -Xms512m -XX:+UseG1GC"` (Allocates appropriate JVM heap within the 4 GiB container limit).

### 4.2 BigQuery Authentication

- Dedicated Service Account: `metabase-runner@data-warehouse-492522.iam.gserviceaccount.com`.
- IAM roles granted:
  - `roles/bigquery.jobUser` (permits executing queries).
  - `roles/bigquery.dataViewer` (permits reading analytical datasets/tables, granted at dataset level).
  - `roles/cloudsql.client` (permits connecting to Cloud SQL via unix domain socket).
  - `roles/secretmanager.secretAccessor` (permits reading secrets from Secret Manager).

### 4.3 Workload Identity Federation (WIF)

- **Pool**: `github-actions-pool`
- **Provider**: `github-actions-provider`
- **OIDC Issuer**: `https://token.actions.githubusercontent.com`
- **Condition**: `assertion.repository == 'compilerla/warehouse'`
- **Binding**: `github-actions-runner` service account granted `roles/iam.workloadIdentityUser` via the WIF pool
- **Purpose**: Allows GitHub Actions to assume the `github-actions-runner` service account without using long-lived service account keys.

---

## 5. Phased Implementation Roadmap

1. **Phase 1: Dev Container & Local Development**:
   - Set up `.devcontainer/devcontainer.json`, `.devcontainer/Dockerfile`, `compose.yml`, and `.env.example`.
   - Verify Metabase runs locally on port 3000 backed by Postgres.
2. **Phase 2: Terraform Infrastructure**:
   - Define Cloud SQL PostgreSQL, Secret Manager, IAM roles, and Cloud Run service in `us-west1`.
3. **Phase 3: CI/CD**:
   - Set up GitHub Actions with GCP Workload Identity Federation (WIF).
4. **Phase 4: Metabase App Setup**:
   - Configure Google Workspace OAuth and SMTP relay.
   - Connect BigQuery datasets and establish permission groups.
5. **Phase 5: Backup & Upgrade Runbooks**:
   - Document automated backup verification: [Cloud SQL Backup Verification](docs/guides/cloud-sql-backup-verification.md)
   - Document container image upgrade procedure via GitHub Actions CI/CD: [Container Image Upgrade](docs/guides/container-image-upgrade.md)
   - Add Cloud Run health check job to GitHub Actions (periodic + post-deploy): [.github/workflows/health-check.yml](.github/workflows/health-check.yml)
6. **Phase 6: Data Ingestion (Workflows & GCS)**:
   - Set up Cloud Workflows and Cloud Run jobs.
   - Implement Python-based logic for API and CSV ingestion.
   - Verify raw data landing in `compiler-data-lake` GCS bucket.
7. **Phase 7: Analytics Warehouse (dbt & BigQuery)**:
   - Initialize dbt Core project in the repository.
   - Deploy dbt transformation jobs to Cloud Run.
   - Map dbt models to BigQuery and verify in Metabase.
