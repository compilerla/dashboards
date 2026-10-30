resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = var.pool_id
  description               = "Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.name
  workload_identity_pool_provider_id = var.provider_id
  attribute_condition                = var.attribute_condition
  description                        = "GitHub Actions Provider"
  oidc {
    issuer_uri = var.issuer_uri
  }
}

resource "google_service_account_iam_member" "binding" {
  service_account_id = var.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}//${google_iam_workload_identity_pool_provider.github_actions.name}"
}
