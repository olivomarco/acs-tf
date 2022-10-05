# create user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  name                = "acs-identity"
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = var.location

  tags = var.tags
}