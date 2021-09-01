# Setup a single cluster in a single availabillity zone.
resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "aks-${var.environment_name}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.environment_name

  # We use a single manually scaled node pool in a single availabillity zone.
  default_node_pool {
    name = "system"

    # We control the size of the cluster manually, this may switch to auto-
    # scaling in the future.
    node_count = var.node_pool_system_count
    vm_size    = var.node_pool_system_vm_sku

    # Attach the cluster to our private network.
    vnet_subnet_id = azurerm_subnet.aks.id

    # High Avaiabillity is not a high enough priority to warrent the extra
    # complexity and cost of having a multi-zonal cluster.
    availability_zones = ["1"]
  }


  network_profile {
    # Use Azure CNI over kubenet.
    network_plugin = "azure"

    # The Azure Network Policy handling is not mature enough as pr
    # september 2021.
    network_policy = "calico"

    # The Standard load balancer provides all the feature we need at this point.
    load_balancer_sku = "Standard"
    load_balancer_profile {
      # We specifiy a pre-provisoned egress-ip which allows us to reprovision
      # the cluster without loosing the outbound ip.
      outbound_ip_address_ids = [azurerm_public_ip.aks_egress.id]
    }
  }

  # We let AKS create its own identity. An alternative approach in the future
  # could be to pre-provision this identity like we do with the egress-ip to
  # make sure we can re-use an identity for a recreated cluster. This would
  # amogst other things allow us to have a seperat Terraform setup that runs
  # with higher privileges to be able to setup RBAC grants and leave things
  # like cluster provisioning to a seperat setup with more moderate permissions.
  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    # We do not plan to use the azure monitoring as of right now. This may
    # change but until then we disable the feature to free up resources.
    oms_agent {
      enabled = false
    }
  }
}
