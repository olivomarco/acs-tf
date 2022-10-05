# create an eventgrid system topic
resource "azurerm_eventgrid_system_topic" "eg" {
  name                   = "acs-eventgrid"
  resource_group_name    = azurerm_resource_group.rg[0].name
  location               = "Global"
  source_arm_resource_id = azurerm_communication_service.acs.id
  topic_type             = "Microsoft.Communication.CommunicationServices"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.mi.id,
    ]
  }

  tags = var.tags
}

# link eventgrid subscription to eventhub for ACS events
resource "azurerm_eventgrid_system_topic_event_subscription" "egs" {
  name                = "acs-interactions"
  resource_group_name = azurerm_resource_group.rg[0].name

  included_event_types = [
    "Microsoft.Communication.ChatThreadCreated",
    "Microsoft.Communication.ChatThreadPropertiesUpdated",
    "Microsoft.Communication.ChatThreadDeleted",
    "Microsoft.Communication.CallStarted",
    "Microsoft.Communication.CallEnded",
    "Microsoft.Communication.ChatMessageReceived",
    "Microsoft.Communication.ChatMessageEdited",
    "Microsoft.Communication.ChatThreadCreatedWithUser",
    "Microsoft.Communication.ChatMessageDeleted",
    "Microsoft.Communication.ChatThreadWithUserDeleted",
    "Microsoft.Communication.ChatThreadPropertiesUpdatedPerUser",
    "Microsoft.Communication.RecordingFileStatusUpdated",
    "Microsoft.Communication.ChatParticipantAddedToThreadWithUser",
    "Microsoft.Communication.ChatParticipantRemovedFromThreadWithUser",
    "Microsoft.Communication.ChatMessageDeletedInThread",
    "Microsoft.Communication.ChatMessageEditedInThread",
    "Microsoft.Communication.ChatMessageReceivedInThread",
    "Microsoft.Communication.ChatThreadParticipantRemoved",
    "Microsoft.Communication.ChatThreadParticipantAdded",
    "Microsoft.Communication.UserDisconnected",
    "Microsoft.Communication.CallParticipantAdded",
    "Microsoft.Communication.CallParticipantRemoved",
    #"Microsoft.Communication.SMSDeliveryReportReceived",
    #"Microsoft.Communication.SMSReceived"
  ]

  system_topic          = azurerm_eventgrid_system_topic.eg.name
  eventhub_endpoint_id  = azurerm_eventhub.eventhub["interactions"].id
  event_delivery_schema = "EventGridSchema"

  # dead letter
  dead_letter_identity {
    type                   = "UserAssigned"
    user_assigned_identity = azurerm_user_assigned_identity.mi.id
  }
  storage_blob_dead_letter_destination {
    storage_account_id          = azurerm_storage_account.sa.id
    storage_blob_container_name = azurerm_storage_container.sc.name
  }
}