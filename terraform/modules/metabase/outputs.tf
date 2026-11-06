output "encryption_secret_key_secret_id" {
  description = "The Secret Manager secret ID for the Metabase encryption key."
  value       = google_secret_manager_secret.metabase_encryption_key.secret_id
}

output "session_secret_key_secret_id" {
  description = "The Secret Manager secret ID for the Metabase session secret key."
  value       = google_secret_manager_secret.metabase_session_key.secret_id
}

output "service_id" {
  description = "The fully qualified ID of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.id
}

output "service_name" {
  description = "The name of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.name
}

output "service_uri" {
  description = "The default *.a.run.app URI of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.uri
}
