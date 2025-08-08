variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

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

variable "container_app_job_name" {
  description = "Name of the Container App Job to be triggered by the scheduler"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "scheduler_enabled" {
  description = "Whether the scheduler is enabled by default"
  type        = bool
  default     = false
}

variable "scheduler_frequency" {
  description = "Frequency of the schedule (Minute, Hour, Day, Week, Month)"
  type        = string
  default     = "Day"
}

variable "scheduler_interval" {
  description = "Interval for the specified frequency. For daily jobs this is usually 1"
  type        = number
  default     = 1
}

variable "scheduler_hour" {
  description = "Hour of the day when the job should run (0-23)"
  type        = number
  default     = 0
}

variable "scheduler_minute" {
  description = "Minute of the hour when the job should run (0-59)"
  type        = number
  default     = 0
}

variable "scheduler_timezone" {
  description = "Time zone for the scheduler"
  type        = string
  default     = "UTC"
}
