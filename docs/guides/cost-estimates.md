# Production Cost Estimates

This page provides an initial monthly pricing estimate for the production environment of the Dashboards project. These figures are based on minimal production-ready configurations and low request volumes.

## Monthly Estimated Cost Breakdown

| Resource                     | Configuration                   | Estimated Monthly Cost |
| :--------------------------- | :------------------------------ | :--------------------- |
| **Cloud SQL (PostgreSQL)**   | 1 vCPU, 3.75 GB RAM, 100 GB SSD | $60 - $90              |
| **Cloud Run (Metabase/dbt)** | Min instances = 1, Low volume   | $10 - $30              |
| **Cloud Workflows**          | Serverless orchestration        | $1 - $5                |
| **BigQuery**                 | Minimal ingestion & storage     | $0 - $5                |
| **GCS Storage**              | < 1 GB total                    | $0 - $1                |
| **Total Estimated Monthly**  |                                 | **$71 - $131**         |

## Key Assumptions & Notes

- **Cloud SQL**: Sized for a small team (approx. 20 users) to ensure smooth performance for Metabase metadata operations.
- **Cloud Run**: Includes a minimum of 1 instance to eliminate "cold start" delays for users.
- **Cloud Workflows**: Replaced Cloud Composer to provide a serverless, pay-per-execution model, significantly reducing the baseline infrastructure cost.
- **Data Costs**: Based on current dataset sizes (~333 KB/month). Costs are expected to remain negligible until data volume scales significantly.
- **Variability**: These are estimates. Actual costs may fluctuate based on specific usage patterns and GCP pricing updates in the `us-west1` region.
