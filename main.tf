# Data source for pre-existing app service plan
data "azurerm_service_plan" "existing" {
  name                = var.app_service_plan_name
  resource_group_name = var.asp_resource_group_name
}

# Create new resource group for app
resource "azurerm_resource_group" "project_rg" {
  name     = "${var.app_name}-rg" # Naming convention for the new resource group
  location = data.azurerm_service_plan.existing.location
}

# Create new storage account for app
resource "azurerm_storage_account" "storage_account" {
  name                     = replace("${ var.app_name }sa", "-", "")
  resource_group_name      = azurerm_resource_group.project_rg.name
  location                 = azurerm_resource_group.project_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage resources to create
locals {
  fetch_queue_name = "fetch-queue"
  queues_to_create = toset([
    local.fetch_queue_name,
    "${local.fetch_queue_name}-stage"
  ])
}

# Create storage queues for app
resource "azurerm_storage_queue" "queues" {
  for_each             = local.queues_to_create
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}