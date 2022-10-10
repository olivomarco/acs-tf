# create an eventhub namespace and eventhub
resource "azurerm_eventhub_namespace" "eh" {
  name                = var.eventhub_name
  location            = var.location
  resource_group_name = var.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name

  sku            = var.eventhub_sku
  capacity       = var.eventhub_capacity
  zone_redundant = var.eventhub_zone_redundant

  tags = var.tags
}

resource "azurerm_eventhub" "eventhub" {
  for_each = var.eventhubs

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = var.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name

  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention
}

module "eh-diagnosticsettings" {
  source = "./modules/diagnosticsettings"

  send_logs_to_loganalytics = var.enable_eventhub_logs_to_loganalytics
  arm_resource_id           = azurerm_eventhub_namespace.eh.id
  log_analytics_id          = azurerm_log_analytics_workspace.loganalytics.id
  log_name                  = "eventhub-log"
}
