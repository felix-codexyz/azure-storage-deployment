module "storage" {
  source                  = "./modules/storage_account"
  storage_account_name    = var.storage_account_name
  location                = var.location
}