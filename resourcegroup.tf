# create resource group - optional
resource "azurerm_resource_group" "rg" {
  count = var.create_rg ? 1 : 0

  name     = var.rg
  location = var.location

  tags = var.tags
}
