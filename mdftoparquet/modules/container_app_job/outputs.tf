output "job_id" {
  description = "ID of the Container App Job"
  value       = azurerm_container_app_job.process_backlog.id
}

output "job_name" {
  description = "Name of the Container App Job"
  value       = azurerm_container_app_job.process_backlog.name
}

output "resource_group_name" {
  description = "Resource group where the job is deployed"
  value       = var.resource_group_name
}

output "execution_command" {
  description = "CLI command to manually execute the job"
  value       = "az containerapp job start --name ${azurerm_container_app_job.process_backlog.name} --resource-group ${var.resource_group_name}"
}
