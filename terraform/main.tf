module "apis" {
  source = "./modules/apis"

  project_id = var.project_id
}

module "iam" {
  source = "./modules/iam"

  project_id = var.project_id

  depends_on = [module.apis]
}

module "bigquery" {
  source = "./modules/bigquery"

  metabase_service_account_email = module.iam.service_account_email
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

module "cloud_run" {
  source = "./modules/cloud_run"

  cloud_sql_connection_name       = module.database.connection_name
  subdomain                       = var.subdomain
  domain_name                     = var.domain_name
  database_name                   = module.database.database_name
  database_user                   = module.database.database_user
  db_password_secret_id           = module.secrets.db_password_secret_id
  encryption_secret_key_secret_id = module.secrets.encryption_secret_key_secret_id
  project_id                      = var.project_id
  region                          = var.region
  service_account_email           = module.iam.service_account_email

  depends_on = [module.apis, module.iam, module.secrets, module.database]
}
