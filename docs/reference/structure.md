# Repository Structure

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
├── docs/                            # MkDocs documentation site
│   ├── index.md                     # Documentation index
│   ├── explanation/                 # Architecture & design rationale
│   ├── guides/                      # How-to guides
│   ├── reference/                   # Technical reference docs
│   └── tutorials/                   # Step-by-step tutorials
├── metabase/                        # Custom Metabase Docker image (Cloud SQL via socat)
│   ├── Dockerfile                   # Adds socat, sets custom entrypoint
│   └── entrypoint.sh                # Bridges Cloud SQL Unix socket → TCP 5432
├── plan.md                          # Full architectural design & implementation plan
├── terraform/                       # Infrastructure as Code (GCP Cloud Run & Cloud SQL)
│   ├── modules/                     # Reusable Terraform modules
│   │   ├── apis/                    # GCP API enablement
│   │   ├── bigquery/                # BigQuery datasets & IAM
│   │   ├── database/                # Cloud SQL PostgreSQL
│   │   ├── iam/                     # IAM service accounts & roles
│   │   ├── metabase/                # Cloud Run Metabase service
│   │   ├── secrets/                 # Secret Manager secrets
│   │   ├── storage/                 # GCS bucket
│   │   └── wif/                     # Workload Identity Federation
│   ├── main.tf                      # Root module (module assembly)
│   ├── variables.tf                 # Root variables
│   ├── outputs.tf                   # Root outputs
│   ├── providers.tf                 # Terraform provider config & GCS backend
│   └── terraform.tfvars             # Default variable values
└── README.md
```
