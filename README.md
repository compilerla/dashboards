# Dashboards

Compiler's analytics and business intelligence workspace, powered by open-source [Metabase](https://www.metabase.com/).

---

## Local Development (VS Code Dev Containers)

This repository follows Compiler's cross-platform [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) standard to ensure consistent development environments across macOS, Linux, and Windows.

### Prerequisites

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine running locally.
2. [Visual Studio Code](https://code.visualstudio.com/).
3. VS Code [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

### Getting Started

1. Copy the sample environment file:

   ```bash
   cp .env.example .env
   ```

2. Open this folder in VS Code.
3. When prompted, click **"Reopen in Container"** (or press `F1` / `Ctrl+Shift+P` / `Cmd+Shift+P` and run `Dev Containers: Reopen in Container`).
4. VS Code will build the dev container and launch all three services:
   - **`dev`**: Your development shell containing `terraform`, `gcloud`, `pre-commit`, and Postgres client tools.
   - **`postgres`**: Local PostgreSQL 16 database storing Metabase application state.
   - **`metabase`**: Official Metabase application available at [http://localhost:3000](http://localhost:3000).

### Helper Scripts (`bin/`)

The following helper scripts are available to run inside the dev container:

- **Wait for Metabase to initialize**:

  ```bash
  ./bin/wait-for-metabase.sh
  ```

- **Connect to the local Postgres metadata database**:

  ```bash
  ./bin/psql.sh
  ```

---

## Architecture Overview

Production is deployed on **Google Cloud Platform (GCP)**:

- **Cloud Run**: Runs the Metabase container image (`metabase/metabase:vX.Y.Z`) with minimum 1 instance to support background tasks and scheduled pulses.
- **Cloud SQL (PostgreSQL)**: Stores Metabase application metadata (dashboards, questions, users, permissions).
- **BigQuery**: Analytics warehouse in project `data-warehouse-492522`, queried via native IAM Service Account credentials.
- **Cloudflare**: DNS management and SSL termination for `dashboards.compiler.la`.

For the complete technical specification, see [plan.md](plan.md).

---

## Repository Structure

```text
.
├── .devcontainer/
│   ├── devcontainer.json            # VS Code dev container definition
│   ├── Dockerfile                   # Dev container image (Terraform, gcloud, pre-commit)
│   └── postCreate.sh                # Container initialization & hook setup
├── .github/
│   └── workflows/                   # GitHub Actions for Terraform automation
├── bin/                             # Helper bash scripts for inside the dev container
│   ├── psql.sh                      # Connect to local PostgreSQL
│   └── wait-for-metabase.sh         # Health check waiter
├── compose.yml                      # Dev container service + local Metabase & Postgres
├── .env.example                     # Sample local environment variables
├── .pre-commit-config.yaml          # Conventional commits & file hygiene hooks
├── plan.md                          # Full architectural design & implementation plan
├── terraform/                       # Infrastructure as Code (GCP Cloud Run & Cloud SQL)
└── README.md
```
