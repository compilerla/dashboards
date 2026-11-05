resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = var.pool_id
  description               = "Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  attribute_mapping                  = var.attribute_mapping
  attribute_condition                = var.attribute_condition
  description                        = "GitHub Actions Provider"
  oidc {
    issuer_uri = var.issuer_uri
  }

  lifecycle {
    ignore_changes = [attribute_condition]
  }
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "binding" {
  service_account_id = var.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/*"
}
