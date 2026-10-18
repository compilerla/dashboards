variable "dataset_default_partition_expiration_ms" {
  default     = null
  description = "Default partition expiration in milliseconds for all datasets. Null means no expiration."
  type        = number
}

variable "datasets" {
  description = "Map of BigQuery datasets to create. Key is the dataset ID."
  type = map(object({
    description                     = string
    default_partition_expiration_ms = optional(number)
    delete_contents_on_destroy      = optional(bool, false)
  }))
  default = {
    analytics = {
      description                = "Cleaned, transformed, and reporting-ready tables and views queried by Metabase."
      delete_contents_on_destroy = false
    }
    raw = {
      description                = "Data as-ingested from source systems by Airflow pipelines."
      delete_contents_on_destroy = false
    }
    staging = {
      description                = "Intermediate transformation tables used between raw ingestion and analytics."
      delete_contents_on_destroy = false
    }
  }
}

variable "location" {
  description = "The BigQuery geographic location for all datasets (e.g. US, EU, us-west1)."
  type        = string
  default     = "US"
}

variable "metabase_service_account_email" {
  description = "The email of the Metabase Cloud Run service account, granted read access to all datasets."
  type        = string
}

variable "project_id" {
  description = "The GCP project ID in which to create BigQuery datasets."
  type        = string
}
