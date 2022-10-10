# create user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  count = var.create_mi ? 1 : 0

  name                = var.mi_name
  resource_group_name = var.mi_rg_name
  location            = var.location

  tags = var.tags

  depends_on = [
    azurerm_resource_group.rg
  ]
}

data "azurerm_user_assigned_identity" "mi" {
  count = var.create_mi ? 0 : 1

  name                = var.mi_name
  resource_group_name = var.mi_rg_name
}
