output "job_name" {
  description = "Name of the Container App Job"
  value       = azurerm_container_app_job.process_aggregation.name
}

output "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.container_app.id
}

output "resource_group_name" {
  description = "Resource group where the job is deployed"
  value       = var.resource_group_name
}

output "execution_command" {
  description = "CLI command to manually execute the job"
  value       = "az containerapp job start --name ${azurerm_container_app_job.process_aggregation.name} --resource-group ${var.resource_group_name}"
}

output "job_id" {
  description = "ID of the Container App Job"
  value       = azurerm_container_app_job.process_aggregation.id
}

output "endpoint" {
  description = "Endpoint URL for the Container App Job"
  value       = "https://${azurerm_container_app_environment.job_env.name}.${azurerm_container_app_environment.job_env.location}.azurecontainerapps.io"
}
