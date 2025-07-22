module "storage" {
  source               = "./modules/storage_account"
  storage_account_name = "azurestoragespz123456"
  location             = "australiaeast"  # Hardcoded for testing
}