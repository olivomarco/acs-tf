provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "random_string" "random" {
  length  = 4
  special = false
}

# create resource group - optional
resource "azurerm_resource_group" "rg" {
  count = var.create_rg ? 1 : 0

  name     = var.rg
  location = var.location

  tags = var.tags
}

# create Azure Communication Service instance
resource "azurerm_communication_service" "acs" {
  name                = "acs-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg[0].name
  data_location       = var.data_location

  tags = var.tags
}

# create user managed identity
resource "azurerm_user_assigned_identity" "mi" {
  name                = "acs-identity"
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = var.location

  tags = var.tags
}

# create keyvault for BYOK, generate a key
resource "azurerm_key_vault" "kv" {
  name                     = "kv-${random_string.random.result}"
  location                 = azurerm_resource_group.rg[0].location
  resource_group_name      = azurerm_resource_group.rg[0].name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard" # no need for anything else here
  purge_protection_enabled = true

  # MI access policy
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.mi.principal_id

    secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
    key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
    storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
  }

  # current user access policy - full access
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
    key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
    storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
  }
}

resource "azurerm_key_vault_key" "generated" {
  name         = "generated-byok-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# create dead-letter storage account
resource "azurerm_storage_account" "sa" {
  name                     = "acsdeadletter${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg[0].name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2" # must be StorageV2 in order to configure BYOK

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.mi.id,
    ]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.generated.id
    user_assigned_identity_id = azurerm_user_assigned_identity.mi.id
  }

  tags = var.tags
  depends_on = [
    azurerm_key_vault.kv,
    azurerm_key_vault_key.generated,
  ]
}

resource "azurerm_storage_container" "sc" {
  name                  = "deadletter"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "sa_role_assignment" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.mi.principal_id
}

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
  name                = "acs"
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = azurerm_resource_group.rg[0].name

  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention
}

# link eventgrid subscription to eventhub for ACS events
resource "azurerm_eventgrid_system_topic_event_subscription" "egs" {
  name                = "acs-subscription"
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
    "Microsoft.Communication.SMSDeliveryReportReceived",
    "Microsoft.Communication.SMSReceived"
  ]

  system_topic          = azurerm_eventgrid_system_topic.eg.name
  eventhub_endpoint_id  = azurerm_eventhub.eventhub.id
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

  depends_on = [azurerm_eventhub.eventhub]
}
