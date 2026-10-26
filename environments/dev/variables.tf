variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "resource_group_name" {
  type    = string
  default = "rg-ratecard-lakehouse-dev"
}

variable "storage_account_name" {
  type        = string
  description = "Must be globally unique, 3-24 lowercase letters/numbers"
  default     = "stlakehousedevsk01"
}

variable "key_vault_name" {
  type        = string
  description = "Must be globally unique, 3-24 alphanumeric and hyphens"
  default     = "kv-ratecard-dev-sk01"
}

variable "data_factory_name" {
  type    = string
  default = "adf-ratecard-dev-001"
}

variable "databricks_workspace_name" {
  type    = string
  default = "adb-ratecard-dev-001"
}

variable "github_account_name" {
  type        = string
  description = "GitHub account or org hosting the repository"
  default     = ""
}

variable "github_repo_name" {
  type        = string
  description = "Repository name (e.g. work_experience_pipeline)"
  default     = ""
}

