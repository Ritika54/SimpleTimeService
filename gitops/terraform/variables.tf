variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-ritika-test"
  description = "Name of the resource group."
}

variable "azurerm_kubernetes_cluster_name" {
  type        = string
  default     = "aks-ritika-test"
  description = "name of aks cluster"
}

variable "azurerm_kubernetes_cluster_dns_prefix" {
  type        = string
  default     = "dns-ritika-test"
  description = "DNS prefix of cluster"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}

variable "ssh_key_name" {
  type    = string
  default = "ssh-key-ritika-test"
}