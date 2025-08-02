variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the existing storage account"
  type        = string
}

variable "input_container_name" {
  description = "Name of the input container"
  type        = string
}

variable "output_container_name" {
  description = "Name of the output container"
  type        = string
}

variable "unique_id" {
  description = "Unique identifier for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "job_name" {
  description = "Name of the container app job"
  type        = string
  default     = "mdf-backlog-processor"
}

variable "container_image" {
  description = "Docker container image to use for the job"
  type        = string
  default     = "ghcr.io/css-electronics/canedge-mdftoparquet-automation:latest"
}

variable "cpu" {
  description = "CPU cores allocated to the container"
  type        = string
  default     = "1.0"
}

variable "memory" {
  description = "Memory allocated to the container in GB"
  type        = string
  default     = "2Gi"
}

variable "github_token" {
  description = "GitHub token for authenticating with the GitHub Container Registry"
  type        = string
  sensitive   = true
}

variable "github_username" {
  description = "GitHub username for authenticating with the GitHub Container Registry"
  type        = string
  default     = "MatinF"
}
