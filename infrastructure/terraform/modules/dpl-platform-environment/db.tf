# Setup randoms for the administrative credentials and the name of the
# database.
resource "random_password" "sql_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    login_seed = var.random_seed
  }
}

resource "random_string" "sql_user" {
  length  = 10
  special = false
  keepers = {
    login_seed = var.random_seed
  }
}

resource "random_id" "mariadb" {
  byte_length = 2
}

# Provision the database.
resource "azurerm_mariadb_server" "sql" {
  name                = "db-${var.environment_name}-${random_id.mariadb.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # The username is required to begin with an alpha char.
  administrator_login          = "q${random_string.sql_user.result}"
  administrator_login_password = random_password.sql_pass.result

  sku_name   = var.sql_sku
  storage_mb = var.sql_storage_mb
  version    = var.sql_version

  # Allow the service to grow its storage as we go.
  auto_grow_enabled            = true
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  # We could consider using this feature, but be aware that it is not available
  # for all tiers: https://docs.microsoft.com/en-us/azure/mysql/concepts-data-access-security-private-link
  public_network_access_enabled = true

  # TODO, we need to verifiy whether this can be toggled on. We'll know it when
  # the first version of Lagoon is up and running.
  ssl_enforcement_enabled = false
}

# Allow any inbound connections
# TODO: verifiy that we actually need this during the initial installation of
# lagoon. It seems that the next rule should at the very least work.
resource "azurerm_mariadb_firewall_rule" "anyany" {
  name                = "any-any"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Grant connections to and from Azure IP's (the ips are matched by providing
# this somewhat strange range.).
resource "azurerm_mariadb_firewall_rule" "allowallwindowsazureips" {
  name                = "allowallwindowsazureips"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Place the admin-credentials for the database into the environments keyvault.
resource "azurerm_key_vault_secret" "sql_user" {
  name         = "sql-user"
  value        = random_string.sql_user.result
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "sql_pass" {
  name         = "sql-pass"
  value        = random_password.sql_pass.result
  key_vault_id = azurerm_key_vault.keyvault.id
}
