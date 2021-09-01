output "mariadb_user" {
  description = "Username for the administrative mariadb user"
  value       = azurerm_mariadb_server.sql.administrator_login
}

output "mariadb_password" {
  description = "Password for the administrative mariadb user"
  value       = azurerm_mariadb_server.sql.administrator_login_password
  sensitive   = true
}

output "mariadb_hostname" {
  description = "Fully qualified MariaDB Hostname"
  value       = azurerm_mariadb_server.sql.fqdn
}

output "mariadb_servername" {
  description = "MariaDB Servername (used as a part of the username when logging in)"
  value       = azurerm_mariadb_server.sql.name
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.keyvault.name
}
output "ingress_ip" {
  description = "IP adresse to use for inbound traffic"
  value       = azurerm_public_ip.aks_ingress.ip_address
}

output "egress_ip" {
  description = "IP address outbound traffic from AKS wil origin from"
  value       = azurerm_public_ip.aks_egress.ip_address
}

output "ingress_hostname" {
  description = "DNS wildcard domain that points at the ingress ip"
  value       = dnsimple_record.aks_ingress.hostname
}

output "resourcegroup_name" {
  description = "Name of the environments main Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "storage_share_name" {
  description = "Name of the lagoon bulk storage share"
  value       = azurerm_storage_share.bulk.name
}
