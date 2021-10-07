# A storage-account needs a globally unique name, so we add a random token
# to the name to ensure this.
resource "random_id" "monitoring_storage_account" {
  byte_length = 2
}

# Setup a storage-account we can use to host logs.
resource "azurerm_storage_account" "monitoring" {
  name                     = "st${var.environment_name}mon${random_id.monitoring_storage_account.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Blob container for logging.
resource "azurerm_storage_container" "logging" {
  name                  = "logging"
  storage_account_name  = azurerm_storage_account.monitoring.name
  container_access_type = "private"
}

resource "azurerm_key_vault_secret" "monitoring_primary_access_key" {
  name         = "monitoring-primary-access-key"
  value        = azurerm_storage_account.monitoring.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "monitoring_secondary_access_key" {
  name         = "monitoring-secondary-access-key"
  value        = azurerm_storage_account.monitoring.secondary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}
