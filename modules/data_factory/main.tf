# Azure Data Factory Module with Managed Identity
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "data_factory_name" {
  type = string
}

variable "github_account_name" {
  type    = string
  default = ""
}

variable "github_repo_name" {
  type    = string
  default = ""
}

variable "github_branch_name" {
  type    = string
  default = "dev"
}

resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Enable System-Assigned Managed Identity (SAMI)
  identity {
    type = "SystemAssigned"
  }

  # Optional Native Git Integration for Dev environment
  dynamic "github_configuration" {
    for_each = var.github_repo_name != "" ? [1] : []
    content {
      account_name    = var.github_account_name
      repository_name = var.github_repo_name
      branch_name     = var.github_branch_name
      root_folder     = "/ratecard_pipeline/adf"
      git_url         = "https://github.com"
    }
  }

  tags = {
    Environment = var.environment
    Project     = "ratecard-pipeline"
  }

  # Prevent Terraform CI/CD runs from unlinking ADF Git integration
  lifecycle {
    ignore_changes = [
      github_configuration,
      vsts_configuration
    ]
  }
}

output "data_factory_id" {
  value = azurerm_data_factory.adf.id
}

output "data_factory_name" {
  value = azurerm_data_factory.adf.name
}

output "principal_id" {
  value = azurerm_data_factory.adf.identity[0].principal_id
}
