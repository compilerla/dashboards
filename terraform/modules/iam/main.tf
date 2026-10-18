resource "google_service_account" "metabase" {
  account_id   = var.service_account_id
  description  = "Dedicated runtime service account for Metabase on Cloud Run"
  display_name = "Metabase Cloud Run Service Account"
  project      = var.project_id
}

locals {
  # roles/bigquery.dataViewer is granted at the individual dataset level
  # by the bigquery module, so only jobUser is needed here at project level.
  metabase_roles = [
    "roles/bigquery.jobUser",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor"
  ]
}

resource "google_project_iam_member" "metabase_roles" {
  for_each = toset(local.metabase_roles)

  member  = "serviceAccount:${google_service_account.metabase.email}"
  project = var.project_id
  role    = each.value
}
