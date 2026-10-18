output "dataset_ids" {
  description = "Map of dataset IDs to their fully qualified BigQuery dataset references."
  value       = { for k, v in google_bigquery_dataset.datasets : k => v.id }
}

output "dataset_locations" {
  description = "Map of dataset IDs to their geographic locations."
  value       = { for k, v in google_bigquery_dataset.datasets : k => v.location }
}
