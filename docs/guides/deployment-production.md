# Deploying to Production

This guide explains how to deploy the dashboards to production.

## Automated Deployment (Tag Push)

Production deployments are triggered automatically by pushing a release tag to the repository. The tag pattern `2024.11.08` (date format) triggers a prod deployment.

### Workflow

1. A release tag is pushed (e.g., `git push origin 2024.11.08`).
2. GitHub Actions runs `deploy.yml`:
    - Builds the custom Metabase Docker image from `./metabase/Dockerfile` and pushes it to GHCR (`ghcr.io/compilerla/dashboards/metabase:<sha>`).
    - Terraform applies infrastructure changes, injecting the new image reference via `TF_VAR_container_image`.
    - Cloud Run rolls out the new Metabase container, which uses `socat` to bridge Cloud Run's Cloud SQL Unix socket to TCP 5432 for standard PostgreSQL JDBC.
3. If it's a final release tag (no `-rc` suffix), a GitHub release is created with generated release notes.

### Required Inputs (workflow_dispatch)

When triggering manually via `workflow_dispatch`, you must provide:

- **`metabase_image`**: The full GHCR image reference to deploy (e.g., `ghcr.io/compilerla/dashboards/metabase:<sha>`).

## Manual Steps (Dev/Test)

For non-production environments, the same workflow runs via `workflow_dispatch` with the `metabase_image` input, or automatically via `-rc` release candidate tags.

## Cost Estimates

For a detailed breakdown of the initial monthly production costs, see the [Cost Estimates](cost-estimates.md) page.
