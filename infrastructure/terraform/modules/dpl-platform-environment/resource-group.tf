resource "azurerm_resource_group" "rg" {
  name     = "rg-env-${var.environment_name}"
  location = var.location
}

output "resourcegroup_name" {
  value = azurerm_resource_group.rg.name
}

