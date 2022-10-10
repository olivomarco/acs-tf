# create resource group - optional
resource "azurerm_resource_group" "rg" {
  count = var.create_rg ? 1 : 0

  name     = var.rg_name
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "rg" {
  count = var.create_rg ? 0 : 1

  name = var.rg_name
}
