output "cluster_name" {
  description = "Name of the provisioned AKS cluster"
  value       = azurerm_kubernetes_cluster.cluster.name
}

output "control_plane_version" {
  description = "Kubernetes control-plane version in use"
  value       = azurerm_kubernetes_cluster.cluster.kubernetes_version
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
  value       = dnsimple_zone_record.aks_ingress.qualified_name
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

output "lagoon_files_blob_storage_container_name" {
  description = "Name of the storage-container to be used for internal Lagoon files"
  value       = azurerm_storage_container.lagoon_files.name
}

output "lagoon_files_storage_account_name" {
  description = "Name of the lagoon-files Azure Storage Account"
  value       = azurerm_storage_account.lagoon_files.name
}

output "lagoon_files_blob_storage_client_access_key_name" {
  description = "Name under which the client access key for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.lagoon_files_blob_storage_client_access_key.name
}

output "lagoon_files_blob_storage_client_secret_key_name" {
  description = "Name under which the client access secret for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.lagoon_files_blob_storage_client_secret_key.name
}

output "lagoon_files_primary_access_key_name" {
  description = "Name under which the primary lagoon-files storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.lagoon_files_primary_access_key.name
}

output "lagoon_files_secondary_access_key_name" {
  description = "Name under which the secondary lagoon-files storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.lagoon_files_secondary_access_key.name
}

output "backup_blob_storage_container_name" {
  description = "Name of the storage-container to be used for Lagoon project backups"
  value       = azurerm_storage_container.backup.name
}

output "backup_blob_storage_client_access_key_name" {
  description = "Name under which the access id for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.backup_blob_storage_client_access_key.name
}

output "backup_blob_storage_client_secret_key_name" {
  description = "Name under which the secret for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.backup_blob_storage_client_secret_key.name
}

output "backup_storage_account_name" {
  description = "Name of the backup Azure Storage Account"
  value       = azurerm_storage_account.backup.name
}

output "backup_primary_access_key_name" {
  description = "Name under which the primary backup storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.backup_primary_access_key.name
}

output "backup_secondary_access_key_name" {
  description = "Name under which the secondary backup storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.backup_secondary_access_key.name
}

output "harbor_blob_storage_container_name" {
  description = "Name of the storage-container to be used for Harbors container image storage"
  value       = azurerm_storage_container.harbor.name
}

output "harbor_blob_storage_client_access_key_name" {
  description = "Name under which the access id for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.harbor_blob_storage_client_access_key.name
}

output "harbor_blob_storage_client_secret_key_name" {
  description = "Name under which the secret for lagoon files is stored in keyvault"
  value       = azurerm_key_vault_secret.harbor_blob_storage_client_secret_key.name
}

output "harbor_storage_account_name" {
  description = "Name of the harbor Azure Storage Account"
  value       = azurerm_storage_account.harbor.name
}

output "harbor_primary_access_key_name" {
  description = "Name under which the primary harbor storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.harbor_primary_access_key.name
}

output "harbor_secondary_access_key_name" {
  description = "Name under which the secondary harbor storage account key is stored in keyvault"
  value       = azurerm_key_vault_secret.harbor_secondary_access_key.name
}

output "acs_connection_string" {
  description = "The conneciton string for Azure Communication Service"
  value       = azurerm_communication_service.communications-services.primary_connection_string
  sensitive   = true
}
