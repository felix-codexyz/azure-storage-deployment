terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
  }

  cloud {
    organization = "SuccPinnSolutions"
    workspaces {
      name = "azure-storage-deploy-workspace"
    }
  }
}

provider "azurerm" {
  features {}
}