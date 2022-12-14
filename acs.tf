# create Azure Communication Service instance
resource "azurerm_communication_service" "acs" {
  name                = var.acs_name
  resource_group_name = var.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  data_location       = var.data_location

  tags = var.tags
}

module "acs-diagnosticsettings" {
  source = "./modules/diagnosticsettings"

  send_logs_to_loganalytics = var.enable_acs_logs_to_loganalytics
  arm_resource_id           = azurerm_communication_service.acs.id
  log_analytics_id          = azurerm_log_analytics_workspace.loganalytics.id
  log_name                  = "acs-log"
}
