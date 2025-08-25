output "app_service_plan_name" {
  description = "Name of the existing app service plan"
  value       = data.azurerm_service_plan.existing.name
}

output "app_service_plan_id" {
  description = "ID of the existing app service plan"
  value       = data.azurerm_service_plan.existing.id
}

output "app_service_plan_resource_group" {
  description = "Resource group of the existing app service plan"
  value       = data.azurerm_service_plan.existing.resource_group_name
}

output "log_analytics_workspace_name" {
  description = "Name of the shared log analytics workspace"
  value = data.azurerm_log_analytics_workspace.existing.name
}

output "log_analytics_workspace_resource_group_name" {
  description = "Resource group of the shared log analytics workspace"
  value = data.azurerm_log_analytics_workspace.existing.resource_group_name
}

output "mysql_server_name" {
  description = "Name of the shared MySQL Flexible Server"
  value = data.azurerm_mysql_flexible_server.existing.name
}

output "mysql_server_resource_group_name" {
  description = "Resource group of the shared MySQL Flexible Server"
  value = data.azurerm_mysql_flexible_server.existing.resource_group_name
}

output "resource_group_name" {
  description = "Name of the shared resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the shared resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

output "storage_account_name" {
  description = "Name of the shared storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "ID of the shared storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_queues" {
  description = "Map of storage queue names"
  value       = { for k, v in azurerm_storage_queue.main : k => v.name }
}

output "storage_tables" {
  description = "Map of storage table names"
  value       = { for k, v in azurerm_storage_table.main : k => v.name }
}

output "queue_names" {
  description = "List of all queue names"
  value       = values(azurerm_storage_queue.main)[*].name
}

output "table_names" {
  description = "List of all table names"
  value       = values(azurerm_storage_table.main)[*].name
}