terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.25.0"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {
}

resource "random_string" "random" {
  length  = 4
  special = false
}

#####################################################################
### NOTE: ALL LOGIC HAPPENS INSIDE SPECIFIC .tf FILES IN THIS FOLDER
#####################################################################
