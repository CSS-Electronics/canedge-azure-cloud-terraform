
output "container_app_job_name" {
  description = "Name of the Container App Job for processing backlog of MDF files"
  value       = module.container_app_job.job_name
}

output "container_app_job_execution_command" {
  description = "Command to manually execute the backlog processing job"
  value       = module.container_app_job.execution_command
}
