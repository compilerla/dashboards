output "bigquery_dataset_ids" {
  description = "Map of created BigQuery dataset IDs. Use these when configuring Metabase's BigQuery connection."
  value       = module.bigquery.dataset_ids
}

output "bigquery_project_id" {
  description = "The GCP project ID containing the BigQuery datasets. Use this when adding BigQuery as a database in the Metabase UI."
  value       = var.project_id
}

output "metabase_service_url" {
  description = "The default *.a.run.app URL of the Metabase Cloud Run service."
  value       = module.metabase.service_uri
}

output "cloud_sql_connection_name" {
  description = "The connection name of the Cloud SQL PostgreSQL instance."
  value       = module.database.connection_name
}

output "metabase_service_account_email" {
  description = "The email address of the Metabase Cloud Run runtime service account."
  value       = module.iam.metabase_service_account_email

}
