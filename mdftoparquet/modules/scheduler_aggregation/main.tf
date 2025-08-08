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

# Get the Container App Job details
data "azurerm_container_app_job" "aggregation_job" {
  name                = var.container_app_job_name
  resource_group_name = var.resource_group_name
}

# Define the recurrence trigger
resource "azurerm_logic_app_trigger_recurrence" "daily_trigger" {
  name         = "daily-aggregation-trigger"
  logic_app_id = azurerm_logic_app_workflow.aggregation_scheduler.id
  frequency    = var.scheduler_frequency
  interval     = var.scheduler_interval
  schedule {
    hours   = var.scheduler_hour
    minutes = var.scheduler_minute
  }
  time_zone   = var.scheduler_timezone
}

# Define the HTTP action to trigger the job
resource "azurerm_logic_app_action_http" "trigger_job" {
  name         = "trigger-container-app-job"
  logic_app_id = azurerm_logic_app_workflow.aggregation_scheduler.id
  method       = "POST"
  uri          = "${data.azurerm_container_app_job.aggregation_job.endpoint}/jobs"
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

# Grant the Logic App's managed identity permission to trigger the Container App Job
resource "azurerm_role_assignment" "logic_app_job_contributor" {
  scope                = data.azurerm_container_app_job.aggregation_job.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.aggregation_scheduler.identity[0].principal_id
}
