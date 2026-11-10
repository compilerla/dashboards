variable "project_id" {
  default     = "data-warehouse-492522"
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  default     = "us-west1"
  description = "The GCP region to deploy resources into."
  type        = string
}

variable "metabase_image_tag" {
  description = "Docker image tag for the Metabase Cloud Run service."
  type        = string
}

variable "google_client_id" {
  description = "Google OAuth 2.0 Client ID for Google Sign-In."
  type        = string
}

variable "smtp_password" {
  default     = ""
  description = "App Password for Google Workspace SMTP relay."
  sensitive   = true
  type        = string
}

variable "deletion_protection" {
  default     = true
  description = "Whether to enable deletion protection for GCP services."
  type        = bool
}
