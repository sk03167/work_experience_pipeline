# Storage Module: ADLS Gen2 with Hierarchical Namespace
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "storage_account_name" { type = string }

resource "azurerm_storage_account" "lakehouse" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Critical: Enables Azure Data Lake Storage Gen2 hierarchical namespace

  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  tags = {
    Environment = var.environment
    Project     = "ratecard-pipeline"
  }
}

# Containers representing the Medallion Architecture
resource "azurerm_storage_data_lake_gen2_filesystem" "containers" {
  for_each           = toset(["bronze", "silver", "gold", "checkpoints"])
  name               = each.key
  storage_account_id = azurerm_storage_account.lakehouse.id
}

output "storage_account_id" {
  value = azurerm_storage_account.lakehouse.id
}

output "storage_account_name" {
  value = azurerm_storage_account.lakehouse.name
}

output "primary_dfs_endpoint" {
  value = azurerm_storage_account.lakehouse.primary_dfs_endpoint
}

