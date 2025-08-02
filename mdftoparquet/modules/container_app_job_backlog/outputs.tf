output "container_app_job_name" {
  description = "Name of the deployed Container App Job"
  value       = azurerm_container_app_job.backlog_processor.name
}

output "container_app_job_id" {
  description = "ID of the deployed Container App Job"
  value       = azurerm_container_app_job.backlog_processor.id
}

output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.job_env.id
}

output "container_app_environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.job_env.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.container_app.id
}
