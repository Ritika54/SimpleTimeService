resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-hybrid"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Public Subnets (for the Load Balancer frontend and potentially Bastion)
resource "azurerm_subnet" "public_subnets" {
  count                = 2
  name                 = "subnet-public-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index + 1}.0/24"]
}

# Private Subnets (for AKS Nodes/Pods)
resource "azurerm_subnet" "private_subnets" {
  count                = 2
  name                 = "subnet-private-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index + 3}.0/24"]
  default_outbound_access_enabled = false
  
  # Delegate the subnet to the AKS service
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# NAT Gateway for outbound access from private subnets
resource "azurerm_public_ip" "nat_gw_pip" {
  name                = "nat-gw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gw" {
  name                 = "nat-gw"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  sku_name             = "Standard"
  idle_timeout_in_minutes = 10
}

# Associate the private subnets with the NAT Gateway for outbound internet access
resource "azurerm_subnet_nat_gateway_association" "private_subnet_associations" {
  count          = 2
  subnet_id      = azurerm_subnet.private_subnets[count.index].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

resource "azurerm_route_table" "aks_node_rt" {
  name                = "aks-node-routetable"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "DefaultRouteToInternet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "private_subnet_associations" {
  count          = 2
  subnet_id      = azurerm_subnet.private_subnets[count.index].id
  route_table_id = azurerm_route_table.aks_node_rt.id
}