resource "random_password" "database_password" {
  length  = 24
  special = false
}

# Database Password Secret
resource "google_secret_manager_secret" "database_password" {
  project   = var.project_id
  secret_id = "metabase-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = random_password.database_password.result
}
