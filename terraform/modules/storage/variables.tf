variable "bucket_name" {
  default     = "compiler-data-lake"
  description = "The name of the GCS bucket"
  type        = string
}

variable "location" {
  description = "The GCP region for the bucket"
  type        = string
  default     = "us-west1"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}
