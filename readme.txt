In order to execute the script run the following commands:
terraform init
terraform plan -target=”azurerm_resource_group.ifm_training_platform”
terraform apply -target=”azurerm_resource_group.ifm_training_platform”
terraform plan
terraform apply