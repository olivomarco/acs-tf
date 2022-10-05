# create dead-letter storage account and storage container, for eventgrid subscription
resource "azurerm_storage_account" "sa" {
  name                     = "deadletter${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg[0].name
  location                 = var.location
  account_tier             = var.sa_tier
  account_replication_type = var.sa_replication_type
  account_kind             = "StorageV2" # must be StorageV2 in order to configure BYOK
  access_tier              = "Hot"

  shared_access_key_enabled = false
  enable_https_traffic_only = true

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
