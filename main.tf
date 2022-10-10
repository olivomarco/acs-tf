terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.25.0"
    }
  }
  # uncomment and fill to use a remote backend for Terraform state
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "<storage_account_name>"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {
}

#####################################################################
### NOTE: ALL LOGIC HAPPENS INSIDE SPECIFIC .tf FILES IN THIS FOLDER
#####################################################################
