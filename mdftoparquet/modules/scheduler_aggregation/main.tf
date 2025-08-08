/**
 * Minimal Azure Logic App Scheduler for Container App Job Aggregation
 * Creates a simple Logic App workflow to trigger the container app job
 * Disabled by default, can be enabled through the Azure Portal
 */

# Create Logic App Workflow that will serve as our scheduler
resource "azurerm_logic_app_workflow" "aggregation_scheduler" {
  name                = "scheduler-aggregation-${var.unique_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Disable workflow by default
  enabled             = var.scheduler_enabled

  # Use managed identity for authentication
  identity {
    type = "SystemAssigned"
  }

  # Use workflow_parameters to define the endpoint URL
  workflow_parameters = jsonencode({
    "$connections": {
      "defaultValue": {},
      "type": "Object"
    }
  })

  # Define the workflow definition directly in the workflow resource
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  
  # Complete workflow definition with recurrence trigger and HTTP action
  workflow_definition = jsonencode({
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "$connections": {
        "defaultValue": {},
        "type": "Object"
      }
    },
    "triggers": {
      "daily_trigger": {
        "recurrence": {
          "frequency": var.scheduler_frequency,
          "interval": var.scheduler_interval,
          "schedule": {
            "hours": [var.scheduler_hour],
            "minutes": [var.scheduler_minute]
          },
          "timeZone": var.scheduler_timezone
        },
        "type": "Recurrence"
      }
    },
    "actions": {
      "trigger_container_app_job": {
        "inputs": {
          "method": "POST",
          "uri": "https://${var.container_app_job_name}-${var.unique_id}.${var.location}.azurecontainerapps.io/jobs",
          "headers": {
            "Content-Type": "application/json"
          },
          "body": {
            "properties": {}
          }
        },
        "runAfter": {},
        "type": "Http"
      }
    },
    "outputs": {}
  })
}

# Grant permissions at resource group level for the Logic App's managed identity
resource "azurerm_role_assignment" "logic_app_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_logic_app_workflow.aggregation_scheduler.identity[0].principal_id
}
