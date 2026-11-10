# Metabase Encryption Secret Key (for encrypting data source credentials)
resource "random_password" "metabase_encryption_secret_key" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "metabase_encryption_key" {
  project   = var.project_id
  secret_id = "metabase-encryption-secret-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "metabase_encryption_key" {
  secret      = google_secret_manager_secret.metabase_encryption_key.id
  secret_data = random_password.metabase_encryption_secret_key.result
}

# Metabase Session Secret Key (signs stored session-key hashes)
resource "random_password" "metabase_session_secret_key" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "metabase_session_key" {
  project   = var.project_id
  secret_id = "metabase-session-secret-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "metabase_session_key" {
  secret      = google_secret_manager_secret.metabase_session_key.id
  secret_data = random_password.metabase_session_secret_key.result
}

# SMTP Password Secret
resource "google_secret_manager_secret" "smtp_password" {
  project   = var.project_id
  secret_id = "metabase-smtp-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "smtp_password" {
  count = var.smtp_password != "" ? 1 : 0

  secret      = google_secret_manager_secret.smtp_password.id
  secret_data = var.smtp_password
}
