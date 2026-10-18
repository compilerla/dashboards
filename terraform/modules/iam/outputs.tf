output "service_account_email" {
  description = "The email address of the Metabase Cloud Run service account."
  value       = google_service_account.metabase.email
}

output "service_account_id" {
  description = "The fully qualified ID of the Metabase Cloud Run service account."
  value       = google_service_account.metabase.id
}
