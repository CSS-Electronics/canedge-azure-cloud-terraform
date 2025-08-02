/**
* Output variables for the CANedge MDF-to-Parquet Terraform Stack for Azure
*/

output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.resource_group_name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = data.azurerm_storage_account.existing.name
}

output "input_container_name" {
  description = "Name of the input container where MDF files are uploaded"
  value       = var.input_container_name
}

output "output_container_name" {
  description = "Name of the output container for Parquet files"
  value       = azurerm_storage_container.output_container.name
}


output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = azurerm_linux_function_app.function_app.name
}

output "function_app_url" {
  description = "URL of the Azure Function App"
  value       = "https://${azurerm_linux_function_app.function_app.default_hostname}"
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.insights.name
}

output "eventgrid_topic_name" {
  description = "Name of the Event Grid System Topic"
  value       = azurerm_eventgrid_system_topic.storage_events.name
}

output "eventgrid_subscription_name" {
  description = "Name of the Event Grid Subscription"
  value       = azurerm_eventgrid_system_topic_event_subscription.input_events.name
}

output "backlog_processor_job_name" {
  description = "Name of the Backlog Processor Container App Job (if deployed)"
  value       = var.deploy_backlog_processor && var.github_token != "" ? module.container_app_job_backlog[0].container_app_job_name : "not-deployed"
}

output "backlog_processor_environment_name" {
  description = "Name of the Backlog Processor Container App Environment (if deployed)"
  value       = var.deploy_backlog_processor && var.github_token != "" ? module.container_app_job_backlog[0].container_app_environment_name : "not-deployed"
}
