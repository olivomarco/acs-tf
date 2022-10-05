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
