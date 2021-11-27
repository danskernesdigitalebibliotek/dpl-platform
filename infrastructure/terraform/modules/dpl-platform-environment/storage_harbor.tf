# A storage-account needs a globally unique name, so we add a random token
# to the name to ensure this.
resource "random_id" "harbor_storage_account" {
  byte_length = 2
}

# Setup a storage-account we can use to host container images.
resource "azurerm_storage_account" "harbor" {
  name                     = "st${var.environment_name}harbor${random_id.harbor_storage_account.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

# Blob container for harbor.
resource "azurerm_storage_container" "harbor" {
  name                  = "harbor"
  storage_account_name  = azurerm_storage_account.harbor.name
  container_access_type = "blob"
}

resource "azurerm_key_vault_secret" "harbor_primary_access_key" {
  name         = "harbor-primary-access-key"
  value        = azurerm_storage_account.harbor.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "harbor_secondary_access_key" {
  name         = "harbor-secondary-access-key"
  value        = azurerm_storage_account.harbor.secondary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "random_id" "harbor_blob_storage_client_access_key" {
  byte_length = 16
}

resource "random_id" "harbor_blob_storage_client_secret_key" {
  byte_length = 16
}

resource "azurerm_key_vault_secret" "harbor_blob_storage_client_access_key" {
  name         = "harbor-blob-storage-client-access-key"
  value        = random_id.harbor_blob_storage_client_access_key.b64_url
  key_vault_id = azurerm_key_vault.keyvault.id
}
resource "azurerm_key_vault_secret" "harbor_blob_storage_client_secret_key" {
  name         = "harbor-blob-storage-client-secret-key"
  value        = random_id.harbor_blob_storage_client_secret_key.b64_url
  key_vault_id = azurerm_key_vault.keyvault.id
}
