output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "primary_dfs_endpoint" {
  value = module.storage.primary_dfs_endpoint
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "data_factory_name" {
  value = module.data_factory.data_factory_name
}

output "adf_principal_id" {
  value = module.data_factory.principal_id
}

output "databricks_workspace_url" {
  value = module.databricks.databricks_workspace_url
}

