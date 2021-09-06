data "azurerm_client_config" "current" {}

module "environment" {
  source           = "../../modules/dpl-platform-environment"
  environment_name = "dplplat01"
  random_seed      = "LahYegheePhohGeew9Fa"
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
