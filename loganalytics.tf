# create log analytics workspace
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "acs-loganalytics"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name
  sku                 = var.loganalytics_sku
  retention_in_days   = var.loganalytics_retention_in_days

  tags = var.tags
}
