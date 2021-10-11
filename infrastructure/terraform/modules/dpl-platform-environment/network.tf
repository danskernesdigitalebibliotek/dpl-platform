# The IP-address we'll assign to AKS to use a egress-ip, that is, the IP-address
# traffic initiated from the cluster will appear to come from.
resource "azurerm_public_ip" "aks_egress" {
  name                = "pip-aks-egress"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.environment_name}eg"
}

# The inbound ip-adress that is used for all sites on the platform. This IP
# will be assigned to the Ingressses created in the AKS cluster.
resource "azurerm_public_ip" "aks_ingress" {
  name                = "pip-aks-ingress"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.environment_name}ing"
}

# The private vnet used to host AKS.
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/12"]
}

resource "azurerm_subnet" "aks" {
  name                = "subnet-aks"
  resource_group_name = azurerm_resource_group.rg.name

  address_prefixes            = ["10.1.0.0/16"]
  virtual_network_name        = azurerm_virtual_network.aks.name
  service_endpoints           = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry"]
  service_endpoint_policy_ids = [azurerm_subnet_service_endpoint_storage_policy.storage.id]
}

resource "azurerm_subnet_service_endpoint_storage_policy" "storage" {
  name                = "policy-storage"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  definition {
    name        = "aks-access"
    description = "Grant AKS access to the storage account"
    service_resources = [
      azurerm_resource_group.rg.id,
      azurerm_storage_account.storage.id
    ]
  }
}
