/**
 * Azure Logic App Scheduler for Container App Job Aggregation
 * Creates a Logic App workflow that triggers the container app job on a schedule
 * Disabled by default, can be enabled through the Azure portal or by setting enabled = true
 */

# Create Logic App Standard that will serve as our scheduler
resource "azurerm_logic_app_workflow" "aggregation_scheduler" {
  name                = "scheduler-aggregation-${var.unique_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Disable workflow until explicitly enabled
  enabled             = var.scheduler_enabled

  # Connect the identity to access the container app
  identity {
    type = "SystemAssigned"
  }
}

# Instead of using a data source, we'll build the endpoint URL
locals {
  # Format for Container App Job endpoint: https://{job-name}.{unique-string}.{region}.azurecontainerapps.io
  container_app_job_url = "https://${var.container_app_job_name}-${var.unique_id}.${var.location}.azurecontainerapps.io"
}

# Define the recurrence trigger
resource "azurerm_logic_app_trigger_recurrence" "daily_trigger" {
  name         = "daily-aggregation-trigger"
  logic_app_id = azurerm_logic_app_workflow.aggregation_scheduler.id
  frequency    = var.scheduler_frequency
  interval     = var.scheduler_interval
  # Use at_these_hours and at_these_minutes instead of a schedule block
  at_these_hours   = [var.scheduler_hour]
  at_these_minutes = [var.scheduler_minute]
  time_zone        = var.scheduler_timezone
}

# Define the HTTP action to trigger the job
resource "azurerm_logic_app_action_http" "trigger_job" {
  name         = "trigger-container-app-job"
  logic_app_id = azurerm_logic_app_workflow.aggregation_scheduler.id
  method       = "POST"
  uri          = "${local.container_app_job_url}/jobs"
  headers = {
    "Content-Type" = "application/json"
  }
  body = jsonencode({
    "properties": {}
  })
  depends_on = [
    azurerm_logic_app_trigger_recurrence.daily_trigger
  ]
}

# Grant permissions at resource group level instead of specific container app job
# This is simpler and avoids needing to know the exact job ARM ID
resource "azurerm_role_assignment" "logic_app_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.aggregation_scheduler.identity[0].principal_id
}
