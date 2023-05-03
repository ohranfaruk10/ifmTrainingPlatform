terraform {
  backend "azurerm" {
    resource_group_name  = "FOH-ifm-storage"
    storage_account_name = "fohifmstorage1"
    container_name = "states"
    key            = "ifm.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "afb9bde0-9ac1-446d-95c9-7d30bd18cc99"
}
