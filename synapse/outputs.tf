output "synapse_workspace_name" {
  description = "The name of the Synapse workspace"
  value       = module.synapse.synapse_workspace_name
}

output "sql_server_endpoint" {
  description = "The SQL Server endpoint for the Synapse workspace"
  value       = module.synapse.sql_server_endpoint
}

output "serverless_sql_endpoint" {
  description = "The Serverless SQL endpoint for the Synapse workspace"
  value       = module.synapse.serverless_sql_endpoint
}

output "web_endpoint" {
  description = "The Web endpoint for the Synapse workspace"
  value       = module.synapse.web_endpoint
}

output "synapse_connection_details" {
  description = "Connection details for Synapse"
  value = <<EOF

===== SYNAPSE CONNECTION DETAILS =====

Name: Microsoft SQL Server
Host: ${module.synapse.serverless_sql_endpoint}
Database: ${var.database_name}
Authentication: SQL Server Authentication
User: ${module.synapse.sql_reader_user}
Password: ${module.synapse.sql_reader_password}
Min time interval: 1ms

The user above is read-only (queries only: Grafana, Power BI, CANedge AI tools). It is created by
the table mapping job: Run the job once (see below) before you connect.

SQL admin (to manage the database, never needed for queries):
User: sqladminuser
Password: ${module.synapse.sql_admin_password}
EOF
  sensitive = true
}

output "container_app_job_name" {
  description = "Name of the Container App Job for Synapse table mapping"
  value       = module.container_app_job.job_name
}

output "container_app_job_execution_command" {
  description = "Command to manually execute the Synapse table mapping job"
  value       = module.container_app_job.execution_command
}


