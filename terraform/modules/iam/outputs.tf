output "github_actions_service_account_id" {
  value = google_service_account.github_actions.id
}

output "metabase_service_account_email" {
  value = google_service_account.metabase.email
}
