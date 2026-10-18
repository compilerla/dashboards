variable "database_name" {
  default     = "metabase"
  description = "The name of the application database for Metabase."
  type        = string
}

variable "database_password" {
  description = "The password for the Metabase PostgreSQL user."
  sensitive   = true
  type        = string
}

variable "database_tier" {
  default     = "db-f1-micro"
  description = "The machine tier for the Cloud SQL PostgreSQL instance (e.g. db-f1-micro, db-g1-small, db-custom-1-3840)."
  type        = string
}

variable "database_user" {
  default     = "metabase"
  description = "The username for the Metabase PostgreSQL user."
  type        = string
}

variable "database_version" {
  default     = "POSTGRES_18"
  description = "The database engine version for Cloud SQL."
  type        = string
}

variable "deletion_protection" {
  default     = true
  description = "Whether deletion protection is enabled on the Cloud SQL instance to prevent accidental teardown."
  type        = bool
}

variable "project_id" {
  description = "The GCP project ID in which to create the Cloud SQL instance."
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance."
  type        = string
}
