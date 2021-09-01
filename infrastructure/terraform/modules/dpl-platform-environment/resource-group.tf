# Create a resource-group that will contain all resources we provision for the
# environment.
# Be aware that AKS also creates its own MC_<cluster-name>-<region> resource-
# group for its resources.
resource "azurerm_resource_group" "rg" {
  name     = "rg-env-${var.environment_name}"
  location = var.location
}

