data "azurerm_client_config" "current" {}

module "environment" {
  source           = "../../modules/dpl-platform-environment"
  environment_name = "dplplat01"
  location         = "West Europe"
  random_seed      = "LahYegheePhohGeew9Fa"
  sql_storage_mb   = 5120
}

# Outputs, the dpl-platform-environment for documentation.
output "ingress_ip" {
  value = module.environment.ingress_ip
}

output "ingress_hostname" {
  value = module.environment.ingress_hostname
}

output "keyvault_name" {
  value = module.environment.keyvault_name
}
