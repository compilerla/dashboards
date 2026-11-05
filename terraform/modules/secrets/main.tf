# Google OAuth Client Secret (Conditional)
resource "google_secret_manager_secret" "google_client_secret" {
  count     = var.google_client_secret != "" ? 1 : 0
  project   = var.project_id
  secret_id = "metabase-google-client-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "google_client_secret" {
  count       = var.google_client_secret != "" ? 1 : 0
  secret      = google_secret_manager_secret.google_client_secret[0].id
  secret_data = var.google_client_secret
}

# SMTP Password Secret (Conditional)
resource "google_secret_manager_secret" "smtp_password" {
  count     = var.smtp_password != "" ? 1 : 0
  project   = var.project_id
  secret_id = "metabase-smtp-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "smtp_password" {
  count       = var.smtp_password != "" ? 1 : 0
  secret      = google_secret_manager_secret.smtp_password[0].id
  secret_data = var.smtp_password
}
