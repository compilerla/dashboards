locals {
  region_suffix = replace(var.region, "-", "_")
}

resource "google_cloud_run_v2_service" "metabase" {
  name        = var.service_name
  location    = var.region
  project     = var.project_id
  description = "Metabase OSS Container"
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.service_account_email
    containers {
      image = "ghcr.io/compilerla/dashboards/metabase:${var.container_image_tag}"
      ports {
        container_port = 3000
      }
      env {
        name  = "JAVA_OPTS"
        value = var.java_opts
      }
      env {
        name  = "CLOUD_SQL_INSTANCE_CONNECTION_NAME"
        value = var.cloud_sql_connection_name
      }

      env {
        name  = "MB_DB_TYPE"
        value = "postgres"
      }

      env {
        name  = "MB_DB_DBNAME"
        value = var.database_name
      }

      env {
        name  = "MB_DB_HOST"
        value = "127.0.0.1"
      }

      env {
        name  = "MB_DB_USER"
        value = var.database_user
      }

      env {
        name = "MB_DB_PASS"
        value_source {
          secret_key_ref {
            secret  = "metabase-db-password"
            version = "latest"
          }
        }
      }
      env {
        name = "MB_ENCRYPTION_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = "metabase-encryption-secret-key"
            version = "latest"
          }
        }
      }
      env {
        name = "MB_SESSION_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = "metabase-session-secret-key"
            version = "latest"
          }
        }
      }
      env {
        name  = "MB_SITE_URL"
        value = "https://${var.service_name}.${local.region_suffix}.a.run.app"
      }
      env {
        name  = "MB_GOOGLE_AUTH_ENABLED"
        value = "true"
      }
      env {
        name  = "MB_GOOGLE_AUTH_CLIENT_ID"
        value = var.google_client_id
      }
      env {
        name  = "MB_GOOGLE_AUTH_AUTO_CREATE_ACCOUNTS_DOMAIN"
        value = "compiler.la"
      }
      env {
        name  = "MB_ENABLE_PASSWORD_LOGIN"
        value = "true"
      }
      env {
        name  = "MB_EMAIL_SMTP_HOST"
        value = "smtp.gmail.com"
      }
      env {
        name  = "MB_EMAIL_SMTP_PORT"
        value = "465"
      }
      env {
        name  = "MB_EMAIL_SMTP_SECURITY"
        value = "ssl"
      }
      env {
        name  = "MB_EMAIL_SMTP_USERNAME"
        value = "bot@compiler.la"
      }
      env {
        name = "MB_EMAIL_SMTP_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = "metabase-smtp-password"
            version = "latest"
          }
        }
      }
      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      startup_probe {
        http_get {
          path = "/api/health"
          port = 3000
        }
        initial_delay_seconds = 30
        period_seconds        = 10
        timeout_seconds       = 5
        failure_threshold     = 60
      }

      volume_mounts {
        mount_path = "/cloudsql"
        name       = "cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_connection_name]
      }
    }

    scaling {
      max_instance_count = var.max_instances
      min_instance_count = var.min_instances
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = var.region
  name     = google_cloud_run_v2_service.metabase.name
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
