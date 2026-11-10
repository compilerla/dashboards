# Container Image Upgrade Procedure

This runbook covers how to upgrade the Metabase container image on Cloud Run via GitHub Actions CI/CD.

## Current Configuration

| Setting        | Value                                          |
| -------------- | ---------------------------------------------- |
| Service name   | metabase                                       |
| Region         | us-west1                                       |
| Image          | `ghcr.io/compilerla/dashboards/metabase:<sha>` |
| CPU limit      | 1 vCPU                                         |
| Memory limit   | 4 GiB                                          |
| Min instances  | 1                                              |
| Max instances  | 3                                              |
| Container port | 3000                                           |
| Cloud Run URL  | `https://metabase-2xhfhhdfxq-uw.a.run.app`     |

## Prerequisites

- Push access to the `compilerla/dashboards` repository
- Write access to the `metabase/` directory (Dockerfile and entrypoint)

## Upgrade Procedure

### 1. Update the Metabase Image

Edit `metabase/Dockerfile` to change the base image version:

```dockerfile
FROM metabase/metabase:vX.XX.X
```

### 2. Push a Release Tag

Push a tag following the date format `YYYY.MM.N` to trigger the deployment:

```bash
git tag -a 2026.11.1
git push origin 2026.11.1
```

This triggers the `Deploy` GitHub Actions workflow:

1. **Build**: The Dockerfile is built and pushed to GHCR (`ghcr.io/compilerla/dashboards/metabase:<sha>`)
2. **Terraform**: The new image tag is injected via `TF_VAR_metabase_image_tag` and applied
3. **Cloud Run**: The new revision is rolled out automatically

### 3. Verify the Deployment

After the workflow completes, verify the deployment:

```bash
# Check the Cloud Run revision
gcloud run services describe metabase --project=data-warehouse-492522 \
  --region=us-west1 --format='value(status.url)'

# Verify the running image
gcloud run services describe metabase --project=data-warehouse-492522 \
  --region=us-west1 --format='value(spec.template.spec.containers[0].image)'

# Test the health endpoint
curl -f https://metabase-2xhfhhdfxq-uw.a.run.app/api/health
```

## Rollback Procedure

If a new version has issues, revert the tag and push a new one pointing to the previous version:

1. **Revert the Dockerfile** to the previous Metabase version (or the previous git commit).
2. **Push a new tag** to trigger a fresh deployment:

   ```bash
   git checkout <previous-working-commit>
   git tag -a 2026.11.2
   git push origin 2026.11.2
   ```

### Revert to Previous Cloud Run Revision

If Terraform changes need to be reverted, you can also roll back to a previous Cloud Run revision:

```bash
# List revisions
gcloud run revisions list --service=metabase --project=data-warehouse-492522 --region=us-west1

# Route traffic back to a previous revision
gcloud run services update-traffic metabase --project=data-warehouse-492522 \
  --region=us-west1 --to-revisions=<previous-revision-name>=100
```

## Database Migration Considerations

Metabase may include database migrations with new versions. Be aware of the following:

- Migrations run automatically on startup when the container starts.
- Rolling updates ensure the previous version handles requests while the new version starts.
- If a migration fails, the previous revision can be rolled back quickly.

### Pre-Upgrade Checklist

- [ ] Review the Metabase release notes (https://github.com/metabase/metabase/releases) for any database migration requirements
- [ ] Ensure the Cloud SQL backup is recent and healthy (run a backup manually if needed — see [Cloud SQL Backup Verification](cloud-sql-backup-verification.md))
- [ ] Ensure you can rollback to the previous version

### Post-Upgrade Checklist

- [ ] Verify Cloud Run revision is running the new image
- [ ] Test the `/api/health` endpoint returns `200 OK`
- [ ] Log in as an admin and verify dashboards load correctly
- [ ] Check that scheduled tasks (pulses, alerts) are running
