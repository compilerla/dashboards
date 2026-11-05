output "metabase_google_client_secret_id" {
  description = "The Secret Manager secret ID for Google OAuth client secret, if created."
  value       = try(google_secret_manager_secret.google_client_secret[0].secret_id, null)
}

output "metabase_smtp_password_secret_id" {
  description = "The Secret Manager secret ID for SMTP password, if created."
  value       = try(google_secret_manager_secret.smtp_password[0].secret_id, null)
}
