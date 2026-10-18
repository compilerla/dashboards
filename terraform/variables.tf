variable "custom_domain" {
  default     = "dashboards.compiler.la"
  description = "Custom domain to map to Cloud Run. Set to empty string to skip domain mapping."
  type        = string
}

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
