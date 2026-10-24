# Azure Databricks Workspace Module
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "databricks_workspace_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "premium"
}

resource "azurerm_databricks_workspace" "adb" {
  name                = var.databricks_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  tags = {
    Environment = var.environment
    Project     = "ratecard-pipeline"
  }
}

output "databricks_workspace_id" {
  value = azurerm_databricks_workspace.adb.id
}

output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.adb.workspace_url
}
