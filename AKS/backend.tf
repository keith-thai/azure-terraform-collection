# You may create the storage account and a blobs inside with `Azure web portal`

terraform {
  backend "azurerm" {
    resource_group_name  = "YOUR_RG_NAME"
    storage_account_name = "YOUR_STORAGE_ACCOUNT_NAME"
    container_name       = "YOUR_STORAGE_ACCOUNT_BLOBS_NAME"
    key                  = "wherever/you/want/to/place/the/terraform.tfstate"
  }
}
