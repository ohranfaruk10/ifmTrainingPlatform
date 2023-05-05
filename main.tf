locals {
  project_location      = var.project_location
  resource_group_name   = var.resource_group_name
}


resource "azurerm_resource_group" "ifm_training_platform" {
  name     = local.resource_group_name
  location = local.project_location
}

resource "azurerm_management_lock" "resource-group-level" {
  name       = "resource-group-delete-lock"
  scope      = azurerm_resource_group.ifm_training_platform.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group can not be deleted"
}

############# WEB APP ##################

resource "azurerm_service_plan" "ifm_service_plan" {
  name                = var.app_service_plan_name
  location            = local.project_location
  resource_group_name = local.resource_group_name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "ifm_web_app" {
  name                = var.web_app_name
  resource_group_name = local.resource_group_name
  location            = local.project_location
  service_plan_id     = azurerm_service_plan.ifm_service_plan.id
  https_only          = true


  site_config {
    ftps_state = "FtpsOnly"

    application_stack {
      php_version = "8.1"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "ifm-mysql-connection"
    type  = "MySql"
    value = "Server=${azurerm_mysql_server.ifm_mysql_server.fqdn};Database=${azurerm_mysql_database.ifm_mysql_database.name};Uid=${azurerm_mysql_server.ifm_mysql_server.administrator_login}@${azurerm_mysql_server.ifm_mysql_server.name};Pwd=${azurerm_mysql_server.ifm_mysql_server.administrator_login_password}"
  }

  backup {
    name                = "ifm-linux-web-app-backup"
    storage_account_url = "https://${azurerm_storage_account.ifm_backup_storage.name}.blob.core.windows.net/${azurerm_storage_container.ifm_backup_container.name}${data.azurerm_storage_account_sas.backup_storage_sas.sas}&sr=b"
    schedule {
      frequency_interval = "7"
      frequency_unit     = "Day"
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_webapp_peering" {
  app_service_id = azurerm_linux_web_app.ifm_web_app.id
  subnet_id      = data.azurerm_subnet.remote_subnet_webapp.id
}

resource "azurerm_private_endpoint" "private_endpoint_webapp" {
  name                = "private-endpoint-webapp-privatelink"
  location            = local.project_location
  resource_group_name = local.resource_group_name
  subnet_id           = data.azurerm_subnet.remote_subnet_private_endpoint.id

  private_service_connection {
    name                           = "webappconnection"
    private_connection_resource_id = azurerm_linux_web_app.ifm_web_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

############# DATABASE #############
resource "azurerm_mysql_server" "ifm_mysql_server" {
  name                         = var.mysql_server_name
  location                     = local.project_location
  resource_group_name          = local.resource_group_name
  sku_name                     = "B_Gen5_1"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  backup_retention_days        = 7
  version                      = "5.7"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mysql_database" "ifm_mysql_database" {
  name                = var.mysql_database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.ifm_mysql_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mysql_firewall_rule" "azure_access_rule" {
  name                = "FireWallRule"
  server_name         = azurerm_mysql_server.ifm_mysql_server.name
  resource_group_name = local.resource_group_name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}


################ BACKUP STORAGE ##############
resource "azurerm_storage_account" "ifm_backup_storage" {
  name                     = var.backup_storage_name
  resource_group_name      = local.resource_group_name
  location                 = local.project_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ifm_backup_container" {
  name                  = var.backup_container_name
  storage_account_name  = azurerm_storage_account.ifm_backup_storage.name
  container_access_type = "private"
}

#backup is not working when global access is denied
# resource "azurerm_storage_account_network_rules" "deny_global_network_rule" {
#   storage_account_id = azurerm_storage_account.ifm_backup_storage.id
#   default_action             = "Deny"
#   virtual_network_subnet_ids = [data.azurerm_subnet.remote_subnet_storage_account.id]
# }

############# NETWORKING ############

resource "azurerm_virtual_network" "ifm_local_vnet" {
  name                = var.vnet_local_name
  address_space       = var.local_vnet_address_space
  location            = local.project_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "ifm_local_subnet" {
  name                 = var.subnet_local_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.ifm_local_vnet.name
  address_prefixes     = var.local_subnet_address_prefixes
}

resource "azurerm_virtual_network_peering" "ifm_vnet_peering" {
  name                         = var.vnet_peering
  resource_group_name          = local.resource_group_name
  virtual_network_name         = azurerm_virtual_network.ifm_local_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote_virtual_network.id
  allow_virtual_network_access = true
}