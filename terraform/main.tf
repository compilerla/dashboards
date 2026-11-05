module "apis" {
  source = "./modules/apis"

  project_id = var.project_id
}

module "iam" {
  source = "./modules/iam"

  project_id = var.project_id

  depends_on = [module.apis]
}

module "wif" {
  source = "./modules/wif"

  project_id         = var.project_id
  service_account_id = module.iam.github_actions_service_account_id
  pool_id            = "github-actions-pool-01"
  provider_id        = "github-actions-provider-01"

  depends_on = [module.iam]
}

module "bigquery" {
  source = "./modules/bigquery"

  metabase_service_account_email = module.iam.metabase_service_account_email
  project_id                     = var.project_id

  depends_on = [module.apis, module.iam]
}

module "secrets" {
  source = "./modules/secrets"

  project_id = var.project_id

  depends_on = [module.apis]
}

module "database" {
  source = "./modules/database"

  database_password = module.secrets.db_password
  project_id        = var.project_id
  region            = var.region

  depends_on = [module.apis]
}

module "storage" {
  source = "./modules/storage"

  project_id = var.project_id
  location   = var.region
}

module "metabase" {
  source = "./modules/metabase"

  cloud_sql_connection_name       = module.database.connection_name
  database_name                   = module.database.database_name
  database_user                   = module.database.database_user
  db_password_secret_id           = module.secrets.db_password_secret_id
  encryption_secret_key_secret_id = module.secrets.metabase_encryption_secret_key_secret_id
  project_id                      = var.project_id
  region                          = var.region
  secret_key_secret_id            = module.secrets.metabase_secret_key_secret_id
  service_account_email           = module.iam.metabase_service_account_email

  depends_on = [module.apis, module.iam, module.secrets, module.database]
}
