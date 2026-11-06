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

variable "google_client_id" {
  description = "Google OAuth 2.0 Client ID for Google Sign-In."
  type        = string
}
