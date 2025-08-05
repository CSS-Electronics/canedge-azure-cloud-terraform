# Create a Log Analytics workspace for Container App logs
resource "azurerm_log_analytics_workspace" "container_app" {
  name                = "log-${var.job_name}-${var.unique_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Create Container App Environment
resource "azurerm_container_app_environment" "job_env" {
  name                       = "env-${var.job_name}-${var.unique_id}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container_app.id
  tags                       = var.tags
}

# Get Storage Account Key for connection string
data "azurerm_storage_account" "existing" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Create Container App Job
resource "azurerm_container_app_job" "process_backlog" {
  name                         = "backlog-${var.unique_id}"
  container_app_environment_id = azurerm_container_app_environment.job_env.id
  resource_group_name          = var.resource_group_name
  location                     = var.location
  tags                         = var.tags
  
  # Required field
  replica_timeout_in_seconds   = 3600
  
  # Manual trigger configuration
  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }
  
  # Registry authentication for GitHub Container Registry
  registry {
    server               = "ghcr.io"
    username             = var.github_username
    password_secret_name = "github-token"
  }
  
  template {
    container {
      name   = "backlog-${var.unique_id}"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory
            
      env {
        name  = "StorageConnectionString"
        secret_name = "storage-connection-string"
      }
      
      # Add debug environment variable
      env {
        name  = "DEBUG"
        value = "true"
      }

      env {
        name  = "INPUT_BUCKET"
        value = var.input_container
      }
      
      env {
        name  = "CLOUD"
        value = "Azure"
      }
      
      # Define explicit command with debug flag
      command = ["sh", "-c", "echo 'Starting container' && env | grep -v PASSWORD && python -u process_backlog_azure.py"]
    }
  }
  
  # Secrets configuration
  secret {
    name  = "storage-connection-string"
    value = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${data.azurerm_storage_account.existing.primary_access_key};EndpointSuffix=core.windows.net"
  }
  
  # GitHub Container Registry authentication token
  secret {
    name  = "github-token"
    value = var.github_token
  }
}
