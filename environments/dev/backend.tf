terraform {
  backend "azurerm" {
    resource_group_name  = "rg-platform-tfstate"
    storage_account_name = "stplatformtfstate11307"
    container_name       = "tfstate"
    key                  = "ratecard-dev.terraform.tfstate"
  }
}

