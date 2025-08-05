output "job_id" {
  description = "ID of the Container App Job"
  value       = azurerm_container_app_job.process_backlog.id
}

output "job_name" {
  description = "Name of the Container App Job"
  value       = azurerm_container_app_job.process_backlog.name
}

output "job_principal_id" {
  value       = azurerm_container_app_job.process_backlog.identity.0.principal_id
  description = "The principal ID of the system-assigned identity for the container app job"
  depends_on = [azurerm_container_app_job.process_backlog]
}

output "log_analytics_id" {
  value       = azurerm_log_analytics_workspace.container_app.id
  description = "The ID of the Log Analytics workspace"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.container_app.workspace_id
  description = "The workspace ID of the Log Analytics workspace"
}

output "resource_group_name" {
  description = "Resource group where the job is deployed"
  value       = var.resource_group_name
}

output "execution_command" {
  description = "CLI command to manually execute the job"
  value       = "az containerapp job start --name ${azurerm_container_app_job.process_backlog.name} --resource-group ${var.resource_group_name}"
}
