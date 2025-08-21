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
  scf_no_x_queue_name = "scf-no-x-queue"
  scf_no_row_tray_queue_name = "scf-no-row-tray-queue"
  notification_queue_name = "notification-queue"
  queues_to_create = toset([
    local.fetch_queue_name,
    "${local.fetch_queue_name}-stage",
    local.scf_no_x_queue_name,
    "${local.scf_no_x_queue_name}-stage",
    local.scf_no_row_tray_queue_name,
    "${local.scf_no_row_tray_queue_name}-stage",
    local.notification_queue_name,
    "${local.notification_queue_name}-stage"
  ])
  scf_no_x_container_name = "scf-no-x-container"
  scf_no_row_tray_container_name = "scf-no-row-tray-container"
  containers_to_create = toset([
    local.scf_no_x_container_name,
    "${local.scf_no_x_container_name}-stage",
    local.scf_no_row_tray_container_name,
    "${local.scf_no_row_tray_container_name}-stage"
  ])
  scf_no_row_tray_stage_table_name = "scfnorowtraystagetable"
  scf_no_row_tray_report_table_name = "scfnorowtrayreporttable"
  tables_to_create = toset([
    local.scf_no_row_tray_stage_table_name,
    local.scf_no_row_tray_report_table_name,
    "${local.scf_no_row_tray_stage_table_name}stage",
    "${local.scf_no_row_tray_report_table_name}stage"
  ])
}

# Create storage queues for app
resource "azurerm_storage_queue" "queues" {
  for_each             = local.queues_to_create
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}

# Create storage containers for app
resource "azurerm_storage_container" "containers" {
  for_each           = local.containers_to_create
  name               = each.key
  storage_account_id = azurerm_storage_account.storage_account.id
}

# Create storage tables for app
resource "azurerm_storage_table" "tables" {
  for_each             = local.tables_to_create
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}