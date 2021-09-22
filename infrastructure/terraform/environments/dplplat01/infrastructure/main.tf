data "azurerm_client_config" "current" {}

module "environment" {
  source           = "../../../modules/dpl-platform-environment"
  environment_name = "dplplat01"
  # This variable current _has_ to match the pattern
  # <environment_name>.dpl.reload.dk
  lagoon_domain_base          = "dplplat01.dpl.reload.dk"
  random_seed                 = "LahYegheePhohGeew9Fa"
  node_pool_system_count      = 1
  node_pool_default_count_min = 1
  node_pool_default_count_max = 5
}

# Outputs, the dpl-platform-environment for documentation.
output "cluster_name" {
  value = module.environment.cluster_name
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

output "harbor_admin_pass_key_name" {
  value = module.environment.harbor_admin_pass_key_name
}

output "keycloak_admin_pass_key_name" {
  value = module.environment.keycloak_admin_pass_key_name
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

output "lagoon_hostname_api" {
  value = module.environment.lagoon_hostname_api
}

output "cluster_api_url" {
  value = module.environment.cluster_api_url
}

output "lagoon_domain_base" {
  value = module.environment.lagoon_domain_base
}
