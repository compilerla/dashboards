variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account to bind to the provider"
  type        = string
}

variable "pool_id" {
  description = "The ID of the Workload Identity Pool"
  type        = string
  default     = "github-actions-pool"
}

variable "provider_id" {
  description = "The ID of the Workload Identity Provider"
  type        = string
  default     = "github-actions-provider"
}

variable "issuer_uri" {
  description = "The OIDC issuer URI"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "attribute_mapping" {
  description = "Mapping of claims to Google attributes"
  type        = map(string)
  default = {
    "google.subject" = "assertion.sub"
  }
}

variable "attribute_condition" {
  description = "Condition for the provider"
  type        = string
  default     = "assertion.repository == 'compilerla/warehouse'"
}
