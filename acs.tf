# create Azure Communication Service instance
resource "azurerm_communication_service" "acs" {
  name                = "acs-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg[0].name
  data_location       = var.data_location

  tags = var.tags
}
