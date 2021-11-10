# A storage-account needs a globally unique name, so we add a random token
# to the name to ensure this.
resource "random_id" "lagoon_files_storage_account" {
  byte_length = 2
}

# Setup a storage-account we can use to host lagoon-files.
resource "azurerm_storage_account" "lagoon_files" {
  name                     = "st${var.environment_name}lagfil${random_id.lagoon_files_storage_account.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

# Blob container for lagoon-files.
resource "azurerm_storage_container" "lagoon_files" {
  name                  = "lagoon-files"
  storage_account_name  = azurerm_storage_account.lagoon_files.name
  container_access_type = "blob"
}

resource "azurerm_key_vault_secret" "lagoon_files_primary_access_key" {
  name         = "lagoon-files-primary-access-key"
  value        = azurerm_storage_account.lagoon_files.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "lagoon_files_secondary_access_key" {
  name         = "lagoon-files-secondary-access-key"
  value        = azurerm_storage_account.lagoon_files.secondary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "random_id" "lagoon_files_blob_storage_client_access_key" {
  byte_length = 16
}

resource "random_id" "lagoon_files_blob_storage_client_secret_key" {
  byte_length = 16
}

resource "azurerm_key_vault_secret" "lagoon_files_blob_storage_client_access_key" {
  name         = "lagoon-files-blob-storage-client-access-key"
  value        = random_id.lagoon_files_blob_storage_client_access_key.b64_url
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "lagoon_files_blob_storage_client_secret_key" {
  name         = "lagoon-files-blob-storage-client-secret-key"
  value        = random_id.lagoon_files_blob_storage_client_secret_key.b64_url
  key_vault_id = azurerm_key_vault.keyvault.id
}
