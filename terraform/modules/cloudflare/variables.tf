variable "zone_id" {
  description = "The ID of the Cloudflare zone."
  type        = string
}

variable "subdomain" {
  description = "The subdomain for the dashboard."
  type        = string
}

variable "domain_name" {
  description = "The base domain name."
  type        = string
}

variable "proxy_enabled" {
  description = "Whether to proxy the record through Cloudflare."
  type        = bool
  default     = true
}

variable "ttl" {
  description = "The TTL for the record."
  type        = number
  default     = 1
}
