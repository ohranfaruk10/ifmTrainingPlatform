variable "resource_group_name" {
  type = string
  default = "FOH-ifm"
}

variable "remote_vnet_network_id" {
  type = string
  default = "/subscriptions/afb9bde0-9ac1-446d-95c9-7d30bd18cc99/resourceGroups/FOH-ifm/providers/Microsoft.Network/virtualNetworks/ifmVnet"
}
