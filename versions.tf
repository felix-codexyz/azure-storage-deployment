terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }

  cloud {
    organization = "felfun-spz-technologies-azure-platform"
    workspaces {
      name = "azure-storage-workspace"
    }
  }
}

provider "azurerm" {
  features {}
}