# diagnostic settings
data "azurerm_monitor_diagnostic_categories" "categories" {
  count       = var.send_logs_to_loganalytics ? 1 : 0
  resource_id = var.arm_resource_id
}

resource "azurerm_monitor_diagnostic_setting" "eventgrid-log" {
  count = var.send_logs_to_loganalytics ? 1 : 0

  name                       = var.log_name
  target_resource_id         = var.arm_resource_id
  log_analytics_workspace_id = var.log_analytics_id

  dynamic log {
    for_each = data.azurerm_monitor_diagnostic_categories.categories.0.log_category_types
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = true
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
}
