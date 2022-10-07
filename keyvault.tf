# create keyvault for BYOK, generate a key
resource "azurerm_key_vault" "kv" {
  name                     = "kv-${random_string.random.result}"
  location                 = var.location
  resource_group_name      = var.create_rg ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard" # no need for anything else here
  purge_protection_enabled = true

  # MI access policy - restricted operations
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.mi.principal_id

    secret_permissions  = []
    key_permissions     = ["Backup", "Create", "Decrypt", "Encrypt", "Get", "Import", "List", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
    storage_permissions = []
  }

  # current user access policy - full access
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
    key_permissions    = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  }

  tags = var.tags
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

module "kv-diagnosticsettings" {
  source = "./modules/diagnosticsettings"

  send_logs_to_loganalytics = var.enable_kv_logs_to_loganalytics
  arm_resource_id           = azurerm_key_vault.kv.id
  log_analytics_id          = azurerm_log_analytics_workspace.loganalytics.id
  log_name                  = "kv-log"
}
