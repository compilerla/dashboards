resource "google_bigquery_dataset" "datasets" {
  for_each = var.datasets

  dataset_id                      = each.key
  description                     = each.value.description
  default_partition_expiration_ms = each.value.default_partition_expiration_ms
  delete_contents_on_destroy      = each.value.delete_contents_on_destroy
  location                        = var.location
  project                         = var.project_id
}

# Grant the Metabase service account read access to every dataset.
# Metabase only needs to read data; writes are handled by Airflow pipelines.
resource "google_bigquery_dataset_iam_member" "metabase_viewer" {
  for_each = var.datasets

  dataset_id = google_bigquery_dataset.datasets[each.key].dataset_id
  member     = "serviceAccount:${var.metabase_service_account_email}"
  project    = var.project_id
  role       = "roles/bigquery.dataViewer"
}
