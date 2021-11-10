# A storage-account needs a globally unique name, so we add a random token
# to the name to ensure this.
resource "random_id" "storage_account" {
  byte_length = 4
}

# Setup a storage-account we can use to host file-shares needed by the platform-
# sites.
resource "azurerm_storage_account" "storage" {
  name                     = "stdpl${var.environment_name}${random_id.storage_account.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Bulk storage for workloads running on Lagoon.
resource "azurerm_storage_share" "bulk" {
  name                 = "bulk"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}

# We export the storage keys to keyvault so that we can inject them into
# Kubernetes secrets at a later point.
resource "azurerm_key_vault_secret" "storage_primary_access_key" {
  name         = "storage-primary-access-key"
  value        = azurerm_storage_account.storage.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}
resource "azurerm_key_vault_secret" "storage_secondary_access_key" {
  name         = "storage-secondary-access-key"
  value        = azurerm_storage_account.storage.secondary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}
