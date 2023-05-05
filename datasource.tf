
data "azurerm_storage_account_sas" "backup_storage_sas" {
  connection_string = azurerm_storage_account.ifm_backup_storage.primary_connection_string
  https_only        = true
  signed_version    = "2023-03-03"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-03-21T00:00:00Z"
  expiry = "2024-03-21T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

data "azurerm_virtual_network" "remote_virtual_network" {
  name                = var.remote_vnet_name
  resource_group_name = var.remote_vnet_resource_group
}

data "azurerm_subnet" "remote_subnet_webapp" {
  name                 = var.remote_subnet_webapp
  resource_group_name  = var.remote_vnet_resource_group
  virtual_network_name = data.azurerm_virtual_network.remote_virtual_network.name
}

data "azurerm_subnet" "remote_subnet_private_endpoint" {
  name                 = var.remote_subnet_private_endpoint
  resource_group_name  = var.remote_vnet_resource_group
  virtual_network_name = data.azurerm_virtual_network.remote_virtual_network.name
}


data "azurerm_subnet" "remote_subnet_storage_account" {
  name                 = var.remote_subnet_storage_account
  resource_group_name  = var.remote_vnet_resource_group
  virtual_network_name = data.azurerm_virtual_network.remote_virtual_network.name
}