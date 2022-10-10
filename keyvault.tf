# create keyvault for BYOK, generate a key
resource "azurerm_key_vault" "kv" {
  count = var.create_kv ? 1 : 0

  name                     = var.kv_name
  location                 = var.location
  resource_group_name      = var.kv_rg_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard" # no need for anything else here
  purge_protection_enabled = true

  # MI access policy - restricted operations
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = var.create_mi ? azurerm_user_assigned_identity.mi[0].principal_id : data.azurerm_user_assigned_identity.mi[0].principal_id

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

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_key_vault_key" "byok" {
  count = var.create_kv ? 1 : 0

  name         = var.byok_name
  key_vault_id = azurerm_key_vault.kv[0].id
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
  count = var.create_kv ? 1 : 0

  source = "./modules/diagnosticsettings"

  send_logs_to_loganalytics = var.enable_kv_logs_to_loganalytics
  arm_resource_id           = azurerm_key_vault.kv[0].id
  log_analytics_id          = azurerm_log_analytics_workspace.loganalytics.id
  log_name                  = "kv-log"
}

data "azurerm_key_vault" "kv" {
  count = var.create_kv ? 0 : 1

  name = var.kv_name
  resource_group_name = var.kv_rg_name
}

data "azurerm_key_vault_key" "byok" {
  count = var.create_kv ? 0 : 1

  name         = var.byok_name
  key_vault_id = data.azurerm_key_vault.kv[0].id
}
