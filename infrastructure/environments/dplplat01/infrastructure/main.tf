data "azurerm_client_config" "current" {}

module "environment" {
  source           = "../../../terraform/modules/dpl-platform-environment/"
  environment_name = "dplplat01"
  # This variable current _has_ to match the pattern
  # <environment_name>.dpl.reload.dk
  lagoon_domain_base = "dplplat01.dpl.reload.dk"
  random_seed        = "LahYegheePhohGeew9Fa"
  node_pools = {
    "app4" : { min : 7, max : 20, vm : "Standard_E4s_v3", max_pods : 70 },
    "admin5" : { count : 1, vm : "Standard_E4s_v3", max_pods : 70 },
  }
  node_pool_system_count = 2
  # We've increased this quite a bit to test performance. The ideal starting-
  # point seems to be in the range 102400 - 204800 to get enough IOPS to
  # maintain performance during a Drupal site-install.
  # When copying this value, consider leaving it out and falling back to the
  # default of 102400.
  sql_storage_mb        = 409600
  control_plane_version = "1.27.9"
}

# Outputs, for values that comes straight from the dpl-platform-environment
# module, please refer to its documentation in the module.
output "backup_blob_storage_container_name" {
  value = module.environment.backup_blob_storage_container_name
}

output "backup_storage_account_name" {
  value = module.environment.backup_storage_account_name
}

output "backup_blob_storage_client_access_key_name" {
  value = module.environment.backup_blob_storage_client_access_key_name
}

output "backup_blob_storage_client_secret_key_name" {
  value = module.environment.backup_blob_storage_client_secret_key_name
}

output "backup_primary_access_key_name" {
  value = module.environment.backup_primary_access_key_name
}

output "backup_secondary_access_key_name" {
  value = module.environment.backup_secondary_access_key_name
}

output "cluster_api_url" {
  value = module.environment.cluster_api_url
}

output "cluster_name" {
  value = module.environment.cluster_name
}

output "harbor_admin_pass_key_name" {
  value = module.environment.harbor_admin_pass_key_name
}

output "harbor_blob_storage_container_name" {
  value = module.environment.harbor_blob_storage_container_name
}

output "harbor_storage_account_name" {
  value = module.environment.harbor_storage_account_name
}

output "harbor_blob_storage_client_access_key_name" {
  value = module.environment.harbor_blob_storage_client_access_key_name
}

output "harbor_blob_storage_client_secret_key_name" {
  value = module.environment.harbor_blob_storage_client_secret_key_name
}

output "harbor_primary_access_key_name" {
  value = module.environment.harbor_primary_access_key_name
}

output "harbor_secondary_access_key_name" {
  value = module.environment.harbor_secondary_access_key_name
}

output "ingress_ip" {
  value = module.environment.ingress_ip
}

output "ingress_hostname" {
  value = module.environment.ingress_hostname
}

output "keyvault_name" {
  value = module.environment.keyvault_name
}

output "control_plane_version" {
  value = module.environment.control_plane_version
}

output "keycloak_admin_pass_key_name" {
  value = module.environment.keycloak_admin_pass_key_name
}

output "lagoon_domain_base" {
  value = module.environment.lagoon_domain_base
}

output "lagoon_files_storage_account_name" {
  value = module.environment.lagoon_files_storage_account_name
}

output "lagoon_files_primary_access_key_name" {
  value = module.environment.lagoon_files_primary_access_key_name
}

output "lagoon_files_secondary_access_key_name" {
  value = module.environment.lagoon_files_secondary_access_key_name
}

output "lagoon_files_blob_storage_container_name" {
  value = module.environment.lagoon_files_blob_storage_container_name
}

output "lagoon_files_blob_storage_client_access_key_name" {
  value = module.environment.lagoon_files_blob_storage_client_access_key_name
}

output "lagoon_files_blob_storage_client_secret_key_name" {
  value = module.environment.lagoon_files_blob_storage_client_secret_key_name
}

output "lagoon_hostname_api" {
  value = module.environment.lagoon_hostname_api
}

output "monitoring_storage_account_name" {
  value = module.environment.monitoring_storage_account_name
}

output "monitoring_primary_access_key_name" {
  value = module.environment.monitoring_primary_access_key_name
}

output "monitoring_secondary_access_key_name" {
  value = module.environment.monitoring_secondary_access_key_name
}

output "monitoring_blob_storage_container_name" {
  value = module.environment.monitoring_blob_storage_container_name
}

output "resourcegroup_name" {
  value = module.environment.resourcegroup_name
}

output "storage_account_name" {
  value = module.environment.storage_account_name
}
output "storage_primary_access_key_name" {
  value = module.environment.storage_primary_access_key_name
}
output "storage_secondary_access_key_name" {
  value = module.environment.storage_secondary_access_key_name
}

output "sql_user" {
  value = module.environment.sql_user
}

output "sql_hostname" {
  value = module.environment.sql_hostname
}

output "sql_servername" {
  value = module.environment.sql_servername
}

output "sql_password_key_name" {
  value = module.environment.sql_password_key_name
}
