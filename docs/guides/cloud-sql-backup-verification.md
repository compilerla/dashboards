# Cloud SQL Backup Verification

This runbook covers how to verify, test, and troubleshoot automated backups for the Cloud SQL PostgreSQL instance used by Metabase.

## Backup Configuration

| Setting                   | Value                            |
| ------------------------- | -------------------------------- |
| Automated backups         | Enabled                          |
| Backup window             | 04:00 UTC daily                  |
| Point-in-Time Recovery    | Enabled                          |
| Transaction log retention | 7 days                           |
| Backup retention          | 15 most recent automated backups |
| Replication log archiving | Enabled                          |

## Verify Backups Are Running

### List Recent Backups

```bash
gcloud sql backups list --project=data-warehouse-492522 --filter='instance:metabase-db-'
```

This lists all backups for the Metabase instance, including automated and ad-hoc backups.

### Check Latest Backup

To verify the most recent backup succeeded, check the `STATE` column in the output. It should show `SUCCESSFUL`.

### Verify Backup Retention

The Cloud SQL instance retains the **15 most recent** automated backups. You can verify by checking the count:

```bash
gcloud sql backups list --project=data-warehouse-492522 --filter='instance:metabase-db- AND TYPE:AUTOMATED' --format='value(NAME)' | wc -l
```

## Trigger an Ad-Hoc Backup

To create an on-demand backup (useful before major changes):

```bash
gcloud sql backups create --instance=metabase-db-<instance-suffix> --project=data-warehouse-492522
```

The `<instance-suffix>` is the random hex suffix appended to the instance name (e.g., `40ee866c`). You can find it from the Terraform outputs or by listing instances:

```bash
gcloud sql instances list --project=data-warehouse-492522 --filter='name:metabase-db-' --format='value(NAME)'
```

## Scheduled Backup Window

Automated backups start at **04:00 UTC** each day. The backup window is approximately 1 hour.

- To check when the next backup is scheduled, review the `WINDOW_START_TIME` from the `gcloud sql backups list` output.
- Backups run outside of the backup window are ad-hoc backups.

## Restore Procedure

Point-in-Time Recovery (PITR) is enabled with a **7-day** transaction log retention window. You can restore the database to **any point in the last 7 days** using either a specific backup or a point-in-time timestamp.

> **Important:** The restore procedure creates a **new Cloud SQL instance** (a clone). The original instance is not modified.

### Step 1: Identify the Target Backup

List recent backups to find the one you want to restore from:

```bash
gcloud sql backups list --project=data-warehouse-492522 --filter='instance:metabase-db-' --format='table(NAME, WINDOW_START_TIME, TYPE, STATE)'
```

Note the backup name and `WINDOW_START_TIME`.

### Step 2: Create a Clone Instance

Create a clone of the Metabase instance from the chosen backup:

```bash
gcloud sql instances clone metabase-db-40ee866c metabase-restore-<date> \
  --project=data-warehouse-492522 \
  --point-in-time="2026-11-09T05:16:30.131Z"
```

Or clone from a specific backup by using the backup name as the `--restorable-disk-backup` flag:

```bash
gcloud sql instances clone metabase-db-40ee866c metabase-restore-<date> \
  --project=data-warehouse-492522 \
  --restorable-disk-backup=projects/data-warehouse-492522/backups/<backup-id>
```

The clone takes a few minutes to provision. Monitor progress:

```bash
gcloud sql instances describe metabase-restore-<date> --project=data-warehouse-492522 --format='value(status)'
```

### Step 3: Verify the Restore

Connect to the clone instance and verify the data:

```bash
# Get the clone IP address
gcloud sql instances describe metabase-restore-<date> --project=data-warehouse-492522 --format='value(ipAddresses[].ipAddress)'

# Connect via psql
psql "host=<clone-ip> dbname=metabase user=metabase"
```

Check key data:

```sql
-- Verify the Metabase schema version
SELECT * FROM metababase_databasefield LIMIT 10;

-- Check recent dashboard entries
SELECT dashboard_id, title, position FROM metababase_dashboard ORDER BY id DESC LIMIT 5;

-- Verify user count matches expectations
SELECT COUNT(*) FROM metababase_user;
```

### Step 4: Clean Up the Clone

After verification, delete the clone to avoid unnecessary costs:

```bash
gcloud sql instances delete metabase-restore-<date> --project=data-warehouse-492522
```
