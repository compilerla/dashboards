output "custom_domain_resource_records" {
  description = "DNS resource records required to map the custom domain in Cloudflare."
  value       = try(google_cloud_run_domain_mapping.custom_domain[0].status[0].resource_records, [])
}

output "service_id" {
  description = "The fully qualified ID of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.id
}

output "service_name" {
  description = "The name of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.name
}

output "service_uri" {
  description = "The default *.a.run.app URI of the Cloud Run service."
  value       = google_cloud_run_v2_service.metabase.uri
}
