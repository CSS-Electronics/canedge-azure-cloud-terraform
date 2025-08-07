variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "unique_id" {
  description = "Unique identifier to use in resource names"
  type        = string
}

variable "job_name" {
  description = "Name of the Container App Job"
  type        = string
  default     = "aggregation"
}

variable "container_image" {
  description = "Container image to use for the job"
  type        = string
  # Try image without specific processor path
  default     = "ghcr.io/css-electronics/canedge-mdftoparquet-automation/aggregation-processor:latest"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage account"
  type        = string
}

variable "github_username" {
  description = "GitHub username for container registry authentication"
  type        = string
  default     = "MatinF"
}

variable "github_token" {
  description = "GitHub Personal Access Token with read:packages scope for container registry authentication"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "CPU cores for the container"
  type        = string
  default     = "0.5"
}

variable "memory" {
  description = "Memory for the container in GB"
  type        = string
  default     = "1Gi"
}

variable "max_retry_count" {
  description = "Maximum number of retries for the job"
  type        = number
  default     = 1
}

variable "trigger_type" {
  description = "Trigger type for the job (Manual or Schedule)"
  type        = string
  default     = "Manual"
}

variable "input_container" {
  description = "Name of the input container in Azure Storage"
  type        = string
  default     = ""
}
