terraform {
  backend "azurerm" {
    resource_group_name  = "FOH-ifm"
    storage_account_name = "fohifmstorage"
    container_name = "states"
    key            = "ifm.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "7720a471-c22a-402a-be7d-11da11a08e9b"
}
