variable "domain_name" {
  default     = "compiler.la"
  description = "The base domain for the dashboards."
  type        = string
}

variable "subdomain" {
  default     = "dashboards"
  description = "The subdomain for the dashboard."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The ID of the Cloudflare zone."
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
