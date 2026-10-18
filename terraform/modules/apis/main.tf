locals {
  required_apis = [
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "vpcaccess.googleapis.com",
  ]
}

resource "google_project_service" "required" {
  for_each = toset(local.required_apis)

  project = var.project_id
  service = each.value

  # Do not disable the API when this resource is destroyed, as other
  # resources outside this Terraform config may depend on it.
  disable_on_destroy = false
}
