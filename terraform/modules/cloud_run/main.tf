resource "google_cloud_run_v2_service" "metabase" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.region
  name     = var.service_name
  project  = var.project_id

  template {
    service_account = var.service_account_email

    scaling {
      max_instance_count = var.max_instances
      min_instance_count = var.min_instances
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_connection_name]
      }
    }

    containers {
      image = var.container_image

      ports {
        container_port = 3000
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      volume_mounts {
        mount_path = "/cloudsql"
        name       = "cloudsql"
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
        name  = "MB_DB_USER"
        value = var.database_user
      }

      env {
        name  = "MB_DB_HOST"
        value = "/cloudsql/${var.cloud_sql_connection_name}"
      }

      env {
        name  = "MB_SITE_URL"
        value = "https://${var.custom_domain}"
      }

      env {
        name  = "JAVA_OPTS"
        value = var.java_opts
      }

      env {
        name = "MB_DB_PASS"
        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MB_ENCRYPTION_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = var.encryption_secret_key_secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = var.region
  member   = "allUsers"
  name     = google_cloud_run_v2_service.metabase.name
  project  = var.project_id
  role     = "roles/run.invoker"
}

resource "google_cloud_run_domain_mapping" "custom_domain" {
  count    = var.custom_domain != "" ? 1 : 0
  location = var.region
  name     = var.custom_domain
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.metabase.name
  }
}
