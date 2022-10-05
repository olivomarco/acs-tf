# create an eventhub namespace and eventhub
resource "azurerm_eventhub_namespace" "eh" {
  name                = "acs-eventhub"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name

  sku            = var.eventhub_sku
  capacity       = var.eventhub_capacity
  zone_redundant = var.eventhub_zone_redundant

  tags = var.tags
}

resource "azurerm_eventhub" "eventhub" {
  for_each = var.eventhubs

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = azurerm_resource_group.rg[0].name

  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention
}

# diagnostic settings
data "azurerm_monitor_diagnostic_categories" "eventhub_categories" {
  count       = var.enable_eventhub_logs_to_loganalytics ? 1 : 0
  resource_id = azurerm_eventhub_namespace.eh.id
}

resource "azurerm_monitor_diagnostic_setting" "eventhub-log" {
  count = var.enable_eventhub_logs_to_loganalytics ? 1 : 0

  name                       = "eventhub-log"
  target_resource_id         = azurerm_eventhub_namespace.eh.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalytics.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.eventhub_categories.0.log_category_types
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
