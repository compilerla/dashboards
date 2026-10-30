output "db_password" {
  description = "The resolved database password value."
  sensitive   = true
  value       = local.resolved_db_password
}

output "db_password_secret_id" {
  description = "The Secret Manager secret ID for the database password."
  value       = google_secret_manager_secret.db_password.secret_id
}

output "metabase_encryption_secret_key" {
  description = "The resolved Metabase encryption key value."
  sensitive   = true
  value       = local.resolved_metabase_encryption_key
}

output "metabase_encryption_secret_key_secret_id" {
  description = "The Secret Manager secret ID for the Metabase encryption key."
  value       = google_secret_manager_secret.metabase_encryption_key.secret_id
}

output "metabase_google_client_secret_id" {
  description = "The Secret Manager secret ID for Google OAuth client secret, if created."
  value       = try(google_secret_manager_secret.google_client_secret[0].secret_id, null)
}

output "metabase_smtp_password_secret_id" {
  description = "The Secret Manager secret ID for SMTP password, if created."
  value       = try(google_secret_manager_secret.smtp_password[0].secret_id, null)
}
