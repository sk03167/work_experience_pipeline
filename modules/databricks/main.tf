# Azure Databricks Workspace Module with Unity Catalog Access Connector
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
  default = "trial"
}

# 1. Databricks Workspace
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

# 2. Access Connector for Azure Databricks (Unity Catalog Managed Identity)
resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "access-connector-databricks-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }

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

output "access_connector_id" {
  value = azurerm_databricks_access_connector.unity_catalog.id
}

output "access_connector_principal_id" {
  value = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}
