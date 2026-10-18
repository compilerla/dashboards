resource "google_cloud_run_v2_service" "metabase" {
  name        = var.service_name
  location    = var.region
  project     = var.project_id
  description = "Metabase OSS Container"
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.service_account_email
    containers {
      image = var.container_image
      env {
        name  = "JAVA_OPTS"
        value = var.java_opts
      }
      env {
        name  = "MB_DB_DBNAME"
        value = var.database_name
      }
      env {
        name  = "MB_DB_HOST"
        value = "/cloudsql/data-warehouse-492522:us-west1:metabase-db"
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
        name  = "MB_DB_TYPE"
        value = "postgres"
      }
      env {
        name  = "MB_DB_USER"
        value = var.database_user
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
        name  = "MB_SITE_URL"
        value = "https://${var.subdomain}.${var.domain_name}"
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

resource "google_cloud_run_domain_mapping" "custom_domain" {
  count    = var.custom_domain_enabled ? 1 : 0
  location = var.region
  name     = "${var.subdomain}.${var.domain_name}"
  project  = var.project_id

  spec {
    certificate_mode = "AUTOMATIC"
    route_name       = var.service_name
  }
}
