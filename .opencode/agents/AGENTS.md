# AGENTS.md

## How to investigate

- Primary sources: `terraform/`, `compose.yml`, `.devcontainer/`, `terraform/terraform.tfvars`.
- Infrastructure logic is primarily in `terraform/modules/`.
- Trust `compose.yml` and `terraform/init.sh` over prose for execution flow.

## What to extract

- **Terraform Execution**: ALWAYS run terraform commands via `exec` against the existing, running `dev` compose service. Do not run them directly on the host and do not run them in a new ephemeral `dev` service. This is where GCP credentials will be configured.
- **Verification**: Run `terraform fmt` and `terraform validate` after every terraform file addition, modification, etc.
- **Pre-commit**: Hooks are installed automatically via `.devcontainer/postCreate.sh`. Run `pre-commit run --all --all-files` after making file modifications.
- **GitHub Actions**: ALWAYS use the latest full commit SHA reference for external steps, with a comment of the current version number.
- **Docs**: When making changes, the docs should be checked and updated accordingly if necessary.

## GitHub Issues: Epic & Sub-Issue Structure

```bash
# Create the epic
docker exec dev gh issue create --title "Phase X: Epic Title" --body "..." --label "epic"

# results in e.g. epic issue #15

# Create sub-issues and link to epic in one step
docker exec dev gh issue create --title "Phase X.1: Sub-issue Title" --body "..." --parent 15
docker exec dev gh issue create --title "Phase X.2: Sub-issue Title" --body "..." --parent 15
```

The `--parent` flag on `gh issue create` is the only reliable way to link sub-issues. Do **not** use comments, labels, or the REST API `relationships` field — they do not work. Verify with `gh issue view <epic-number>` and check the `sub-issues:` line.

## Constraints & Gotchas

- **Auth Error**: `terraform` and `gcloud` may fail if not run as `exec` against the existing, running `dev` compose service.
- **No Apply**: Do not run `terraform apply` unless explicitly instructed.
