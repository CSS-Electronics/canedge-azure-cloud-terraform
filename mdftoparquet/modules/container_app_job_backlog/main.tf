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
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Create Container App Job
resource "azurerm_container_app_job" "backlog_processor" {
  name                         = "${var.job_name}-${var.unique_id}"
  container_app_environment_id = azurerm_container_app_environment.job_env.id
  resource_group_name          = var.resource_group_name
  location                     = var.location
  tags                         = var.tags
  
  # Required field - set to 1 hour to allow for long-running processing
  replica_timeout_in_seconds   = 3600
  
  # Manual trigger config
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
      name   = "mdf-backlog-processor"
      image  = "ghcr.io/css-electronics/canedge-synapse-map-tables:latest"  # Using Synapse image instead
      cpu    = var.cpu
      memory = var.memory
      
      env {
        name  = "STORAGE_ACCOUNT"
        value = var.storage_account_name
      }
      
      env {
        name  = "INPUT_BUCKET"
        value = var.input_container_name
      }
      
      env {
        name  = "StorageConnectionString"
        secret_name = "storage-connection-string"
      }
      
      # Add debug environment variable
      env {
        name  = "DEBUG"
        value = "true"
      }
      
      # Add required Synapse environment variables
      env {
        name  = "SYNAPSE_DATABASE"
        value = "canedge"
      }
      
      env {
        name  = "SYNAPSE_SERVER"
        value = "test-synapse-server.database.windows.net"
      }
      
      env {
        name  = "SYNAPSE_USER"
        value = "sqladminuser"
      }
      
      env {
        name  = "SYNAPSE_PASSWORD"
        secret_name = "synapse-password"
      }
      
      env {
        name  = "MASTER_KEY_PASSWORD"
        secret_name = "master-key-password"
      }
      
      # Add command for the Synapse container
      command = ["sh", "-c", "echo 'Starting container' && env | grep -v PASSWORD && python -u synapse-map-tables.py"]
    }
  }
  
  # Secrets configuration
  secret {
    name  = "storage-connection-string"
    value = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${data.azurerm_storage_account.storage.primary_access_key};EndpointSuffix=core.windows.net"
  }
  
  # GitHub Container Registry authentication token
  secret {
    name  = "github-token"
    value = var.github_token
  }
  
  # Synapse password (test value for debugging)
  secret {
    name  = "synapse-password"
    value = "placeholder-password"
  }
  
  # Master key password (random generated value)
  secret {
    name  = "master-key-password"
    value = "placeholder-master-key"
  }
}
