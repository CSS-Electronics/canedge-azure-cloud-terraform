
output "container_app_job_name" {
  description = "Name of the Container App Job for Synapse table mapping"
  value       = module.container_app_job.job_name
}

output "container_app_job_execution_command" {
  description = "Command to manually execute the Synapse table mapping job"
  value       = module.container_app_job.execution_command
}
