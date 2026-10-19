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
├── plan.md                          # Full architectural design & implementation plan
├── terraform/                       # Infrastructure as Code (GCP Cloud Run & Cloud SQL)
└── README.md
```
