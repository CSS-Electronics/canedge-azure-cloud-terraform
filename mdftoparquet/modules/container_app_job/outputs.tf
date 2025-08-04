output "job_id" {
  description = "ID of the Container App Job"
  value       = azurerm_container_app_job.map_tables.id
}

output "job_name" {
  description = "Name of the Container App Job"
  value       = azurerm_container_app_job.map_tables.name
}

output "resource_group_name" {
  description = "Resource group where the job is deployed"
  value       = var.resource_group_name
}

output "execution_command" {
  description = "Command to execute the Container App Job"
  value       = "az containerapp job start --name ${azurerm_container_app_job.map_tables.name} --resource-group ${var.resource_group_name}"
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Container App logs"
  value       = azurerm_log_analytics_workspace.container_app.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name for Container App logs"
  value       = azurerm_log_analytics_workspace.container_app.name
}

output "log_query_commands" {
  description = "KQL queries to check Container App logs"
  value = {
    console_logs = "ContainerAppConsoleLogs | where ContainerName == 'test-container' | order by TimeGenerated desc"
    system_logs  = "ContainerAppSystemLogs | where ContainerAppName contains '${var.job_name}' | order by TimeGenerated desc"
    all_logs     = "union ContainerAppConsoleLogs, ContainerAppSystemLogs | where ContainerAppName contains '${var.job_name}' or ContainerName == 'test-container' | order by TimeGenerated desc"
    # Alternative queries for custom log tables (if logs appear with _CL suffix)
    console_logs_cl = "ContainerAppConsoleLogs_CL | where ContainerName_s == 'test-container' | order by TimeGenerated desc"
    system_logs_cl  = "ContainerAppSystemLogs_CL | where ContainerAppName_s contains '${var.job_name}' | order by TimeGenerated desc"
    all_logs_cl     = "union ContainerAppConsoleLogs_CL, ContainerAppSystemLogs_CL | where ContainerAppName_s contains '${var.job_name}' or ContainerName_s == 'test-container' | order by TimeGenerated desc"
  }
}
