# ADD THIS OUTPUT AT THE TOP:
output "module_received_location" {
  value = var.location
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-demo-storage"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}