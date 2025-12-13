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
}

resource "azurerm_public_ip" "pip" {
  name                = "az-ritika-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}