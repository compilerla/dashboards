resource "random_id" "instance_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  database_version    = var.database_version
  deletion_protection = var.deletion_protection
  name                = "metabase-db-${random_id.instance_suffix.hex}"
  project             = var.project_id
  region              = var.region

  settings {
    availability_type = "ZONAL"
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "PD_SSD"
    tier              = var.database_tier

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "04:00"
      transaction_log_retention_days = 7
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "metabase" {
  instance = google_sql_database_instance.postgres.name
  name     = var.database_name
  project  = var.project_id
}

resource "google_sql_user" "metabase" {
  instance = google_sql_database_instance.postgres.name
  name     = var.database_user
  password = var.database_password
  project  = var.project_id
}
