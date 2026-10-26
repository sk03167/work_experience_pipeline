terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "ratecard-pipeline"
  }
}

# 2. ADLS Gen2 Storage Account
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  environment          = var.environment
  storage_account_name = var.storage_account_name
}

# 3. Azure Key Vault
module "key_vault" {
  source              = "../../modules/key_vault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  environment         = var.environment
  key_vault_name      = var.key_vault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

# 4. Azure Data Factory
module "data_factory" {
  source              = "../../modules/data_factory"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  environment         = var.environment
  data_factory_name   = var.data_factory_name
  github_account_name = var.github_account_name
  github_repo_name    = var.github_repo_name
  github_branch_name  = "dev"
}

# 5. Azure Databricks Workspace (Trial SKU - 14-Day Free Evaluation)
module "databricks" {
  source                    = "../../modules/databricks"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  environment               = var.environment
  databricks_workspace_name = var.databricks_workspace_name
  sku                       = "trial"
}

# ==============================================================================
# 6. Enterprise IAM / RBAC Role Assignments (Least Privilege)
# ==============================================================================

# Role A: ADF Managed Identity -> Key Vault Secrets User
# Allows ADF to retrieve the Neon DB password dynamically
resource "azurerm_role_assignment" "adf_kv_secrets_user" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.data_factory.principal_id
}

# Role B: ADF Managed Identity -> Storage Blob Data Contributor on ADLS Gen2
# Allows ADF to write Bronze staging Delta/Parquet directly to storage
resource "azurerm_role_assignment" "adf_storage_contributor" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.data_factory.principal_id
}

# Role C: ADF Managed Identity -> Contributor on Databricks Workspace
# Allows ADF to orchestrate and execute notebook runs on Databricks clusters
resource "azurerm_role_assignment" "adf_databricks_contributor" {
  scope                = module.databricks.databricks_workspace_id
  role_definition_name = "Contributor"
  principal_id         = module.data_factory.principal_id
}

