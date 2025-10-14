# Setup a single cluster in a single availabillity zone.
resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "aks-${var.environment_name}-01"
  sku_tier            = "Standard"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.environment_name
  kubernetes_version  = var.control_plane_version

  # We use a single manually scaled node pool in a single availabillity zone.
  default_node_pool {
    name = "system"
    # This is the default. The value could be increased in the future if our
    # workloads are small enough.
    # Be aware that changing this value will destroy and recreate the nodepool.
    max_pods = 60
    # We control the size of the cluster manually, this may switch to auto-
    # scaling in the future.
    node_count = var.node_pool_system_count
    vm_size    = var.node_pool_system_vm_sku

    # Sync node version with control plane version of k8s
    orchestrator_version = var.control_plane_version

    # Attach the cluster to our private network.
    vnet_subnet_id = azurerm_subnet.aks.id

    # High Avaiabillity is not a high enough priority to warrent the extra
    # complexity and cost of having a multi-zonal cluster.
    zones = ["1"]

    node_labels = {
      "noderole.dplplatform" : "system"
    }
  }

  network_profile {
    # Use Azure CNI over kubenet.
    network_plugin = "azure"

    # The Azure Network Policy handling is not mature enough as pr
    # september 2021.
    network_policy     = "calico"
    dns_service_ip     = "10.10.0.10"
    service_cidr       = "10.10.0.0/16"
    # The Standard load balancer provides all the feature we need at this point.
    load_balancer_sku = "standard"
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
}

# Add a application default nodepool.
resource "azurerm_kubernetes_cluster_node_pool" "pool" {
  for_each              = var.node_pools
  name                  = each.key
  orchestrator_version  = var.control_plane_version
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  vnet_subnet_id        = azurerm_subnet.aks.id
  node_labels = {
    "noderole.dplplatform" : try(each.value.role, "application")
  }
  zones = [
    "1",
  ]

  # The default for AKS is 30 pods pr node. This can be a rather low number
  # of pods depending on the workload, but as we know Lagoon to run with quite
  # low resource requests, we're keeping the number of pods on a node low to
  # avoid running the nodes too hot.
  # Be aware that changing this value will destroy and recreate the nodepool.
  max_pods = try(each.value.max_pods, 30)

  vm_size = each.value.vm

  # Enable autoscaling.
  min_count           = try(each.value.min, null)
  max_count           = try(each.value.max, null)
  node_count          = try(each.value.count, null)
}
