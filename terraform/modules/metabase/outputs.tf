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
