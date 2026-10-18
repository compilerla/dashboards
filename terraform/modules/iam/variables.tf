variable "project_id" {
  description = "The GCP project ID in which to create the IAM resources."
  type        = string
}

variable "service_account_id" {
  description = "The ID to give to the Metabase Cloud Run service account."
  type        = string
  default     = "metabase-runner"
}
