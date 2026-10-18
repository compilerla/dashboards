output "bucket_url" {
  description = "The URL of the GCS bucket"
  value       = "gs://${google_storage_bucket.data.name}"
}

output "bucket_name" {
  description = "The name of the created bucket"
  value       = google_storage_bucket.data.name
}
