resource "google_storage_bucket" "data" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true
}
