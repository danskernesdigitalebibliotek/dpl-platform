output "cluster_name" {
  description = "Name of the provisioned AKS cluster"
  value       = azurerm_kubernetes_cluster.cluster.name
}

output "cluster_api_url" {
  description = "URL of the AKS api server"
  value       = azurerm_kubernetes_cluster.cluster.fqdn
}

output "egress_ip" {
  description = "IP address outbound traffic from AKS wil origin from"
  value       = azurerm_public_ip.aks_egress.ip_address
}

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

output "harbor_admin_pass_key_name" {
  description = "Name under which the admin password for harbor is stored in keyvault"
  value       = azurerm_key_vault_secret.harbor_admin_pass.name
}

output "ingress_ip" {
  description = "IP adresse to use for inbound traffic"
  value       = azurerm_public_ip.aks_ingress.ip_address
}

output "ingress_hostname" {
  description = "DNS wildcard domain that points at the ingress ip"
  value       = dnsimple_record.aks_ingress.hostname
}

output "keycloak_admin_pass_key_name" {
  description = "Name under which the admin password for keycloak is stored in keyvault"
  value       = azurerm_key_vault_secret.keycloak_admin_pass.name
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.keyvault.name
}

output "lagoon_hostname_api" {
  description = "Hostname for the lagoon API server"
  value       = "api.lagoon.${var.lagoon_domain_base}"
}

output "lagoon_domain_base" {
  description = "Domain base"
  value       = var.lagoon_domain_base
}

output "resourcegroup_name" {
  description = "Name of the environments main Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "sql_user" {
  description = "Username of the administrative MariaDB user"
  value       = azurerm_mariadb_server.sql.administrator_login
}

output "sql_hostname" {
  description = "Fully qualified hostname for the MariaDB server"
  value       = azurerm_mariadb_server.sql.fqdn
}

output "sql_servername" {
  description = "value"
  value       = azurerm_mariadb_server.sql.name
}

output "sql_password_key_name" {
  description = "Name under which the administrative sql users passwqord is stored in keyvault"
  value       = azurerm_key_vault_secret.sql_pass.name
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "storage_primary_access_key_name" {
  description = "Name under which the primary storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.storage_primary_access_key.name
}

output "storage_secondary_access_key_name" {
  description = "Name under which the secondary storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.storage_secondary_access_key.name
}

output "storage_share_name" {
  description = "Name of the lagoon bulk storage share"
  value       = azurerm_storage_share.bulk.name
}

output "monitoring_storage_account_name" {
  description = "Name of the monitoring Azure Storage Account"
  value       = azurerm_storage_account.monitoring.name
}

output "monitoring_primary_access_key_name" {
  description = "Name under which the primary monitoring storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.monitoring_primary_access_key.name
}

output "monitoring_secondary_access_key_name" {
  description = "Name under which the secondary monitoring storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.monitoring_secondary_access_key.name
}

output "monitoring_blob_storage_container_name" {
  description = "Name of the storage-container to be used for loki logs"
  value       = azurerm_storage_container.logging.name
}
