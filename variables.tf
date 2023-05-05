variable "app_service_plan_name" {
  type    = string
  default = "ifm-training-service-plan"
}

variable "project_location" {
  type    = string
  default = "westeurope"
}

variable "backup_storage_name" {
  type    = string
  default = "ifmbackuptraining"
}

variable "backup_container_name" {
  type    = string
  default = "ifm-training-backup-container"
}

variable "web_app_name" {
  type    = string
  default = "ifm-training-web-app"
}

variable "mysql_server_name" {
  type    = string
  default = "ifm-training-mysql-server"
}

variable "mysql_database_name" {
  type    = string
  default = "ifm-training-mysql-database"
}

variable "vnet_local_name" {
  type    = string
  default = "ifm-training-local-vnet"
}

variable "subnet_local_name" {
  type    = string
  default = "ifm-training-local-subnet"
}

variable "resource_group_name" {
  type    = string
  default = "ifm-training-group"
}

variable "remote_vnet_id" {
  type    = string
  default = "/subscriptions/group/providers/Microsoft.Network/virtualNetworks/vnet"
}

variable "remote_vnet_name" {
  type    = string
  default = "ifmVnet"
}

variable "vnet_peering" {
  type    = string
  default = "ifm-vnet-peering"
}

variable "remote_vnet_resource_group" {
  type    = string
  default = "ifm"
}

#subnet for web app -> vnet peerring needs to have Microsoft.Web/serverFarms delegation
variable "remote_subnet_webapp" {
  type    = string
  default = "subnet_webapp"
}

variable "remote_subnet_private_endpoint" {
  type    = string
  default = "subnet_private_endpoint"
}

variable "remote_subnet_storage_account" {
  type    = string
  default = "storage_account_subnet"
}

variable "administrator_login_password" {
  type = string
  default = "P@ssw0rd1234!"
}

variable "administrator_login" {
  type = string
  default = "adminIFM"
}

variable "local_vnet_address_space" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "local_subnet_address_prefixes"{
  type = list(string)
  default =  ["10.0.1.0/24"] 
}