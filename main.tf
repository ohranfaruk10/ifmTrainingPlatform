locals {
 app_service_plan_name  = "ifm-training-service-plan"
 project_location       = "westeurope"
 resource_group_name    = var.resource_group_name
 backup_storage_name    = "ifmbackuptraining"
 backup_container_name  = "ifm-training-backup-container"
 web_app_name           = "ifm-training-web-app"
 mysql_server_name      = "ifm-training-mysql-server"
 mysql_database_name    = "ifm-training-mysql-database"
 vnet_local_name        = "ifm-training-local-vnet"
 subnet_local_name      = "ifm-training-local-subnet"
 vnet_peering           = "ifm_vnet_peering"
}

resource "azurerm_resource_group" "ifm_training_platform" {
  name     = local.resource_group_name
  location = local.project_location
}

resource "azurerm_service_plan" "ifm_service_plan" {
  name                = local.app_service_plan_name
  location            = local.project_location
  resource_group_name = local.resource_group_name
  os_type             = "Linux"             
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "ifm_web_app" {
  name                = local.web_app_name
  resource_group_name = local.resource_group_name
  location            = local.project_location
  service_plan_id     = azurerm_service_plan.ifm_service_plan.id

   site_config { 
    ftps_state = "AllAllowed"

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
  name =  "ifm-linux-web-app-backup"
  storage_account_url        = "https://${azurerm_storage_account.ifm_backup_storage.name}.blob.core.windows.net/${azurerm_storage_container.ifm_backup_container.name}${data.azurerm_storage_account_sas.backup_storage_sas.sas}&sr=b"
  schedule {
    frequency_interval = "7"
    frequency_unit = "Day"
    }
  }
}

############# DATABASE #############
resource "azurerm_mysql_server" "ifm_mysql_server" {
  name                          =  local.mysql_server_name
  location                      =  local.project_location
  resource_group_name           =  local.resource_group_name
  sku_name                      = "B_Gen5_1"
  administrator_login           = "adminIFM"
  administrator_login_password  = "P@ssw0rd1234!"
  backup_retention_days         = 7
  version                       = "5.7"
  ssl_enforcement_enabled       = true
}

resource "azurerm_mysql_database" "ifm_mysql_database" {
  name                = local.mysql_database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.ifm_mysql_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}


################ BACKUP STORAGE ##############
resource "azurerm_storage_account" "ifm_backup_storage" {
  name                     = local.backup_storage_name
  resource_group_name      = local.resource_group_name
  location                 = local.project_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ifm_backup_container" {
  name                  = local.backup_container_name
  storage_account_name  = azurerm_storage_account.ifm_backup_storage.name
  container_access_type = "private"
}

# # ######### NETWORKING ############

resource "azurerm_virtual_network" "ifm_local_vnet" {
  name                = local.resource_group_name
  address_space       = ["10.0.0.0/16"]
  location            = local.project_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "ifm_local_subnet" {
  name                 = local.subnet_local_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.ifm_local_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network_peering" "ifm_vnet_peering" {
  name                         = local.vnet_peering
  resource_group_name          = local.resource_group_name
  virtual_network_name         = azurerm_virtual_network.ifm_local_vnet.name
  remote_virtual_network_id    = var.remote_vnet_network_id
  allow_virtual_network_access = true
}

