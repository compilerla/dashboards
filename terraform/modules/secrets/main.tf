resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "random_password" "metabase_encryption_secret_key" {
  length  = 32
  special = false
}

resource "random_password" "metabase_secret_key" {
  length  = 48
  special = true
}

locals {
  resolved_db_password             = var.db_password != "" ? var.db_password : random_password.db_password.result
  resolved_metabase_encryption_key = var.metabase_encryption_secret_key != "" ? var.metabase_encryption_secret_key : random_password.metabase_encryption_secret_key.result
  resolved_metabase_secret_key     = var.metabase_secret_key != "" ? var.metabase_secret_key : random_password.metabase_secret_key.result
}

# Database Password Secret
resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "metabase-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = local.resolved_db_password
}

# Encryption Secret Key Secret
resource "google_secret_manager_secret" "metabase_encryption_key" {
  project   = var.project_id
  secret_id = "metabase-encryption-secret-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "metabase_encryption_key" {
  secret      = google_secret_manager_secret.metabase_encryption_key.id
  secret_data = local.resolved_metabase_encryption_key
}

# Metabase Secret Key (app-level session/token signing)
resource "google_secret_manager_secret" "metabase_secret_key" {
  project   = var.project_id
  secret_id = "metabase-secret-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "metabase_secret_key" {
  secret      = google_secret_manager_secret.metabase_secret_key.id
  secret_data = local.resolved_metabase_secret_key
}

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
