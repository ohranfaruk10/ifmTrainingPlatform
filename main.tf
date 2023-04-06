locals {
 app_service_plan_name  = "ifm-training-service-plan"
 project_location       = "westeurope"
 resource_group_name    = var.resource_group_name
 web_app_name           = "ifm-training-web-app"
 mysql_server_name      = "ifm-training-mysql-server"
 mysql_database_name    = "ifm-training-mysql-database"
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
  sku_name            = "S1"
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
}

resource "azurerm_mysql_server" "ifm_mysql_server" {
  name                          =  local.mysql_server_name
  location                      =  local.project_location
  resource_group_name           =  local.resource_group_name
  sku_name                      = "B_Gen5_1"
  administrator_login           = "adminIFM"
  administrator_login_password  = "P@ssw0rd1234!"
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
