resource "random_id" "keyvault" {
  byte_length = 2
}

# Setup a keyvault we can use to store administrative credentials.
resource "azurerm_key_vault" "keyvault" {
  # Keyvaults has a public hostname, and as such their names must be unique.
  # We achive this by adding in a random token when building the name.
  name                       = "kv-${var.environment_name}-${random_id.keyvault.hex}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  # We control access to the keyvault data-plane via RBAC
  # We could use access policies instead, but that would require us to tie us
  # to a specific tenant.
  enable_rbac_authorization = true
}

