variable "google_client_secret" {
  default     = ""
  description = "Google Workspace OAuth Client Secret for Metabase authentication."
  sensitive   = true
  type        = string
}

variable "project_id" {
  description = "The GCP project ID in which to store secrets."
  type        = string
}

variable "smtp_password" {
  default     = ""
  description = "Password for Google Workspace SMTP relay or transactional email provider."
  sensitive   = true
  type        = string
}
