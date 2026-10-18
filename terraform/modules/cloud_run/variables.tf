variable "subdomain" {
  description = "The subdomain for the dashboard (e.g., 'dashboards')."
  type        = string
}

variable "domain_name" {
  description = "The base domain name (e.g., 'compiler.la')."
  type        = string
}

variable "custom_domain_enabled" {
  description = "Whether to enable custom domain mapping. Set to false to skip."
  type        = bool
  default     = true
}

variable "cloud_sql_connection_name" {
  description = "The Cloud SQL instance connection name (project:region:instance)."
  type        = string
}

variable "container_image" {
  default     = "metabase/metabase:v0.65.x"
  description = "Docker image tag for Metabase."
  type        = string
}

variable "cpu_limit" {
  default     = "1"
  description = "CPU limit for the Cloud Run container."
  type        = string
}

variable "database_name" {
  description = "Name of the PostgreSQL database for Metabase."
  type        = string
}

variable "database_user" {
  description = "Username of the PostgreSQL database user."
  type        = string
}

variable "db_password_secret_id" {
  description = "Secret Manager secret ID containing the database password."
  type        = string
}

variable "encryption_secret_key_secret_id" {
  description = "Secret Manager secret ID containing the Metabase encryption secret key."
  type        = string
}

variable "java_opts" {
  default     = "-Xmx1536m -Xms512m -XX:+UseG1GC"
  description = "JVM tuning flags for the Metabase container."
  type        = string
}

variable "max_instances" {
  default     = 3
  description = "Maximum number of container instances for Cloud Run."
  type        = number
}

variable "memory_limit" {
  default     = "2Gi"
  description = "Memory limit for the Cloud Run container."
  type        = string
}

variable "min_instances" {
  default     = 1
  description = "Minimum number of container instances (keeps instance warm and runs scheduled tasks/pulses)."
  type        = number
}

variable "project_id" {
  description = "The GCP project ID in which to deploy Cloud Run."
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud Run service."
  type        = string
}

variable "service_account_email" {
  description = "Email of the IAM service account attached to Cloud Run."
  type        = string
}

variable "service_name" {
  default     = "metabase"
  description = "Name of the Cloud Run service."
  type        = string
}
