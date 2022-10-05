# create Azure Communication Service instance
resource "azurerm_communication_service" "acs" {
  name                = "acs-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg[0].name
  data_location       = var.data_location

  tags = var.tags
}

# diagnostic settings
data "azurerm_monitor_diagnostic_categories" "acs_categories" {
  count       = var.enable_acs_logs_to_loganalytics ? 1 : 0
  resource_id = azurerm_communication_service.acs.id
}

resource "azurerm_monitor_diagnostic_setting" "acs-log" {
  count = var.enable_acs_logs_to_loganalytics ? 1 : 0

  name                       = "acs-log"
  target_resource_id         = azurerm_communication_service.acs.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytics.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.acs_categories.0.log_category_types
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.loganalytics_retention_in_days
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.loganalytics_retention_in_days
    }

  }
}
