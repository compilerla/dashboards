variable "db_password" {
  default     = ""
  description = "Optional pre-defined PostgreSQL password. If left empty, a secure random password is generated."
  sensitive   = true
  type        = string
}

variable "encryption_secret_key" {
  default     = ""
  description = "Optional pre-defined 32+ character Metabase encryption key. If left empty, a secure random key is generated."
  sensitive   = true
  type        = string
}

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
