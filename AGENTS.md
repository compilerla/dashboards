# AGENTS.md

## How to investigate

- Primary sources: `terraform/`, `compose.yml`, `.devcontainer/`, `terraform/terraform.tfvars`.
- Infrastructure logic is primarily in `terraform/modules/`.
- Trust `compose.yml` and `terraform/init.sh` over prose for execution flow.

## What to extract

- **Terraform Execution**: ALWAYS run terraform commands via `exec` against the existing, running `dev` compose service. Do not run them directly on the host and do not run them in a new ephemeral `dev` service. This is where GCP credentials will be configured.
- **Verification**: Run `terraform fmt` and `terraform validate` after every terraform file addition, modification, etc.
- **Pre-commit**: Hooks are installed automatically via `.devcontainer/postCreate.sh`. Run `pre-commit run --all --all-files` after making file modifications.

## Constraints & Gotchas

- **Auth Error**: `terraform` and `gcloud` may fail if not run as `exec` against the existing, running `dev` compose service.
- **No Apply**: Do not run `terraform apply` unless explicitly instructed.
