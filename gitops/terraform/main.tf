resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  location            = azurerm_resource_group.rg.location
  name                = var.azurerm_kubernetes_cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.azurerm_kubernetes_cluster_dns_prefix
  sku_tier            = "Standard"

  default_node_pool {
    name           = "systempool"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.private_subnets[0].id 
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard" 
    outbound_type      = "loadBalancer"
  }

  identity {
    type = "SystemAssigned"
  }
}