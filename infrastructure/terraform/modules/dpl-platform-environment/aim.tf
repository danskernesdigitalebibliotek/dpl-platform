# Grant the AKS managed identity acccess to Azure Resources it needs to be
# able to access or administer.

# Grant AKS Virtual Machine Contributor to be able to join the private network.
# This will also grant it enough access to use the egress ip.
resource "azurerm_role_assignment" "aks_vm_contributor_main_rg" {
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
}

# Allow AKS to administer the blob storage we keep in the storage account.
resource "azurerm_role_assignment" "aks_vm_storage_contributor_main_rg" {
  principal_id = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
  # TODO, see if we can narrow this scope.
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Storage Account Contributor"
}

# Allow AKS to bind the ingress IP to its load-balancer.
resource "azurerm_role_assignment" "aks_network_contributor_main_rg" {
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
  scope                = azurerm_public_ip.aks_ingress.id
  role_definition_name = "Network Contributor"
}
