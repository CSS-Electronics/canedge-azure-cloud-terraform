output "logic_app_id" {
  description = "ID of the created Logic App"
  value       = azurerm_logic_app_workflow.aggregation_scheduler.id
}

output "logic_app_name" {
  description = "Name of the created Logic App"
  value       = azurerm_logic_app_workflow.aggregation_scheduler.name
}

output "scheduler_enabled" {
  description = "Whether the scheduler is enabled"
  value       = azurerm_logic_app_workflow.aggregation_scheduler.enabled
}

output "scheduler_status" {
  description = "Status of the scheduler (Enabled/Disabled)"
  value       = azurerm_logic_app_workflow.aggregation_scheduler.enabled ? "Enabled" : "Disabled"
}
