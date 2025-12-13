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