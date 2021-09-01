# Data providers that are used throughout the module.

# Get a reference to our current Azure Resource Manager client
# This reference is then used to eg. get the id of our current tenant
data "azurerm_client_config" "current" {}
