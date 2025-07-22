module "storage" {
  source               = "./modules/storage_account"
  storage_account_name = var.storage_account_name
  location             = var.location
}

# ADD THESE DEBUG OUTPUTS:
output "root_location_var" {
  value = var.location
}

output "root_storage_name_var" {
  value = var.storage_account_name
}