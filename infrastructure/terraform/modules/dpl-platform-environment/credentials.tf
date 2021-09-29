# Generate a number of credentials that projects we'll install at a later
# point will need.
#
# The credentials are insert into keyvault to be used later.
resource "random_password" "keycloak_admin_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    login_seed = var.random_seed
  }
}

resource "random_password" "harbor_admin_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    login_seed = var.random_seed
  }
}

# We export the storage keys to keyvault so that we can inject them into
# Kubernetes secrets at a later point.
resource "azurerm_key_vault_secret" "harbor_admin_pass" {
  name         = "harbor-admin-pass"
  value        = random_password.harbor_admin_pass.result
  key_vault_id = azurerm_key_vault.keyvault.id
}
resource "azurerm_key_vault_secret" "keycloak_admin_pass" {
  name         = "keycloak-admin-pass"
  value        = random_password.keycloak_admin_pass.result
  key_vault_id = azurerm_key_vault.keyvault.id
}
