# create log analytics workspace
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = var.loganalytics_name
  location            = var.location
  resource_group_name = var.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  sku                 = var.loganalytics_sku
  retention_in_days   = var.loganalytics_retention_in_days

  tags = var.tags
}
