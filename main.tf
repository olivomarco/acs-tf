provider "azurerm" {
  features {}
}

# create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}

# create Azure Communication Service instance
resource "random_string" "random" {
  length  = 4
  special = false
}
resource "azurerm_communication_service" "acs" {
  name                = "acs-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = "${var.data_location}"
}

# create notification hub that can be used by ACS
resource "azurerm_notification_hub_namespace" "nhns" {
  name                = "acsnamespace${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  namespace_type      = "NotificationHub"
  sku_name            = "Basic"
}

resource "azurerm_notification_hub" "nh" {
  name                = "notificationhub"
  namespace_name      = azurerm_notification_hub_namespace.nhns.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# create an eventgrid system topic
resource "azurerm_eventgrid_system_topic" "eg" {
  name                   = "acs-eventgrid"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = "Global"
  source_arm_resource_id = azurerm_communication_service.acs.id
  topic_type             = "Microsoft.Communication.CommunicationServices"
}

# create an eventhub and link to eventgrid subscription of above ACS topics
resource "azurerm_eventhub_namespace" "eh" {
  name                = "acs-eventhub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "eventhub" {
  name                = "acs"
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

# resource "azurerm_eventgrid_system_topic_event_subscription" "egs" {
#     name                  = "acs-eventgrid-subscription"
#     system_topic          = azurerm_eventgrid_system_topic.eg.id
#     resource_group_name   = azurerm_resource_group.rg.name
#     event_delivery_schema = "EventGridSchema"
#     included_event_types  = [
#         "Microsoft.Communication.ChatThreadCreated",
#         "Microsoft.Communication.ChatThreadPropertiesUpdated",
#         "Microsoft.Communication.ChatThreadDeleted",
#         "Microsoft.Communication.CallStarted",
#         "Microsoft.Communication.CallEnded",
#         "Microsoft.Communication.ChatMessageReceived",
#         "Microsoft.Communication.ChatMessageEdited",
#         "Microsoft.Communication.ChatThreadCreatedWithUser",
#         "Microsoft.Communication.ChatMessageDeleted",
#         "Microsoft.Communication.ChatThreadWithUserDeleted",
#         "Microsoft.Communication.ChatThreadPropertiesUpdatedPerUser",
#         "Microsoft.Communication.RecordingFileStatusUpdated",
#         "Microsoft.Communication.ChatParticipantAddedToThreadWithUser",
#         "Microsoft.Communication.ChatParticipantRemovedFromThreadWithUser",
#         "Microsoft.Communication.ChatMessageDeletedInThread",
#         "Microsoft.Communication.ChatMessageEditedInThread",
#         "Microsoft.Communication.ChatMessageReceivedInThread",
#         "Microsoft.Communication.ChatThreadParticipantRemoved",
#         "Microsoft.Communication.ChatThreadParticipantAdded",
#         "Microsoft.Communication.UserDisconnected",
#         "Microsoft.Communication.CallParticipantAdded",
#         "Microsoft.Communication.CallParticipantRemoved",
#         "Microsoft.Communication.SMSDeliveryReportReceived",
#         "Microsoft.Communication.SMSReceived"
#     ]
#     eventhub_endpoint_id = azurerm_eventhub.eventhub.id
# }
