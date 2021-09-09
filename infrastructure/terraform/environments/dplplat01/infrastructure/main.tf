data "azurerm_client_config" "current" {}

module "environment" {
  source                 = "../../../modules/dpl-platform-environment"
  environment_name       = "dplplat01"
  random_seed            = "LahYegheePhohGeew9Fa"
  node_pool_system_count = 2
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
