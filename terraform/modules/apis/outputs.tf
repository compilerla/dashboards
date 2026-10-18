output "enabled_services" {
  description = "The set of GCP service APIs enabled by this module."
  value       = { for k, v in google_project_service.required : k => v.service }
}
