# resource "azurerm_key_vault_secret" "azurerm_communication_service_connection_string" {
#   name         = "azurerm-communication-service-connection-string"
#   value        = azurerm_communication_service.acs.primary_connection_string
#   key_vault_id = azurerm_key_vault.keyvault.id
# }
provider "azurerm" {
  features {}
  subscription_id = "8ac8a259-5bb3-4799-bd1e-455145b12550"
}

resource "random_id" "acs" {
  byte_length = 2
}

resource "azurerm_communication_service" "communications-services" {
  name                = "communication-services${random_id.acs.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = "Germany"
}

resource "azurerm_email_communication_service" "email-service" {
  name                = "email-service${random_id.acs.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = "Germany"
}
