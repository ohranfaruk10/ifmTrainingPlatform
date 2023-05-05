terraform {
  backend "azurerm" {
    resource_group_name  = "group"
    storage_account_name = "storage"
    container_name       = "container"
    key                  = "states.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}
