# Data source for pre-existing app service plan
data "azurerm_service_plan" "existing" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_resource_group
}

data "azurerm_log_analytics_workspace" "existing" {
  name = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group
}

data "azurerm_mysql_flexible_server" "existing" {
  name = var.mysql_server_name
  resource_group_name = var.mysql_server_resource_group_name
}

# Create new resource group for app
resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-rg" # Naming convention for the new resource group
  location = data.azurerm_service_plan.existing.location

  tags = {
    Environment = "shared"
    Project     = "almaitemchecks"
  }
}

# Create new storage account for app
resource "azurerm_storage_account" "main" {
  name                     = replace("${ var.app_name }sa", "-", "")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "shared"
    Project     = "almaitemchecks"
  }
}

# Storage resources to create
locals {
  fetch_queue_name                  = "fetch-queue"
  update_queue_name                 = "update-queue"
  notification_queue_name           = "notification-queue"
  queues_to_create                  = toset([
    local.fetch_queue_name,
    "${local.fetch_queue_name}-stage",
    local.update_queue_name,
    "${local.update_queue_name}-stage",
    local.notification_queue_name,
    "${local.notification_queue_name}-stage"
  ])
  updated_items_container_name      = "updated-items-container"
  reports_container_name            = "reports-container"
  containers_to_create              = toset([
    local.updated_items_container_name,
    "${local.updated_items_container_name}-stage",
    local.reports_container_name,
    "${local.reports_container_name}-stage"
  ])
  scf_no_row_tray_stage_table_name  = "scfnorowtraystagetable"
  scf_no_row_tray_report_table_name = "scfnorowtrayreporttable"
  iznorowtraystagetable             = "iznorowtraystagetable"
  tables_to_create                  = toset([
    local.scf_no_row_tray_stage_table_name,
    "${local.scf_no_row_tray_stage_table_name}stage",
    local.scf_no_row_tray_report_table_name,
    "${local.scf_no_row_tray_report_table_name}stage",
    local.iznorowtraystagetable,
    "${local.iznorowtraystagetable}stage"
  ])
}

# Create storage queues for app
resource "azurerm_storage_queue" "main" {
  for_each             = local.queues_to_create
  name                 = each.key
  storage_account_name = azurerm_storage_account.main.name
}

# Create storage containers for app
resource "azurerm_storage_container" "main" {
  for_each           = local.containers_to_create
  name               = each.key
  storage_account_id = azurerm_storage_account.main.id
}

# Create storage tables for app
resource "azurerm_storage_table" "main" {
  for_each             = local.tables_to_create
  name                 = each.key
  storage_account_name = azurerm_storage_account.main.name
}