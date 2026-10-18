output "connection_name" {
  description = "The connection name of the Cloud SQL instance to be used in Cloud Run (format: project:region:instance)."
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_name" {
  description = "The name of the provisioned Metabase database."
  value       = google_sql_database.metabase.name
}

output "database_user" {
  description = "The username for the Metabase database user."
  value       = google_sql_user.metabase.name
}

output "instance_name" {
  description = "The name of the provisioned Cloud SQL instance."
  value       = google_sql_database_instance.postgres.name
}
