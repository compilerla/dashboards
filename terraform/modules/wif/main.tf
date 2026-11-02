resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = var.pool_id
  description               = "Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  attribute_condition                = var.attribute_condition
  attribute_mapping                  = var.attribute_mapping
  description                        = "GitHub Actions Provider"
  oidc {
    issuer_uri = var.issuer_uri
  }
}

resource "google_service_account_iam_member" "binding" {
  service_account_id = var.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_actions.workload_identity_pool_provider_id}"
}
