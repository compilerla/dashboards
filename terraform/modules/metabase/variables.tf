variable "cloud_sql_connection_name" {
  description = "The Cloud SQL instance connection name (project:region:instance)."
  type        = string
}

variable "container_image_tag" {
  description = "Docker image tag for the Metabase Cloud Run service."
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
  default     = "4Gi"
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

variable "google_client_id" {
  description = "Google OAuth 2.0 Client ID for Google Sign-In."
  type        = string
}

variable "smtp_password" {
  default     = ""
  description = "Password for Google Workspace SMTP relay."
  sensitive   = true
  type        = string
}
