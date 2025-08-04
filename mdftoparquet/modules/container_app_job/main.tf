# Create a Log Analytics workspace for Container App logs
resource "azurerm_log_analytics_workspace" "container_app" {
  name                = "log-${var.job_name}-${var.unique_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Create Container App Environment with proper logging configuration
resource "azurerm_container_app_environment" "job_env" {
  name                       = "env-${var.job_name}-${var.unique_id}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container_app.id
  tags                       = var.tags
}

# Generate a secure master key password
resource "random_password" "master_key" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# Get Storage Account Key for connection string
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Create Container App Job
resource "azurerm_container_app_job" "map_tables" {
  name                         = "${var.job_name}-${var.unique_id}"
  container_app_environment_id = azurerm_container_app_environment.job_env.id
  resource_group_name          = var.resource_group_name
  location                     = var.location
  tags                         = var.tags
  
  # Required field
  replica_timeout_in_seconds   = 900
  
  # Enable system identity for Log Analytics access
  identity {
    type = "SystemAssigned"
  }
  
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
      name   = "test-container"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory
      
      env {
        name  = "STORAGE_ACCOUNT"
        value = var.storage_account_name
      }
      
      env {
        name  = "CONTAINER_OUTPUT"
        value = var.output_container_name
      }
      
      env {
        name  = "STORAGE_CONNECTION_STRING"
        secret_name = "storage-connection-string"
      }
      
      env {
        name  = "SYNAPSE_SERVER"
        value = var.synapse_server
      }
      
      env {
        name  = "SYNAPSE_PASSWORD"
        secret_name = "synapse-password"
      }
      
      env {
        name  = "MASTER_KEY_PASSWORD"
        secret_name = "master-key-password"
      }
      
      # Add debug environment variable
      env {
        name  = "DEBUG"
        value = "true"
      }
      
      # Define explicit command to run our test script
      command = ["python", "-u", "test_container.py"]
      
      env {
        name  = "SYNAPSE_DATABASE"
        value = var.database_name
      }
      
      env {
        name  = "SYNAPSE_USER"
        value = "sqladminuser"
      }
    }
  }
  
  # Secrets configuration
  secret {
    name  = "storage-connection-string"
    value = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${data.azurerm_storage_account.storage.primary_access_key};EndpointSuffix=core.windows.net"
  }
  
  secret {
    name  = "synapse-password"
    value = var.synapse_sql_password
  }
  
  secret {
    name  = "master-key-password"
    value = random_password.master_key.result
  }

  # GitHub Container Registry authentication token
  secret {
    name  = "github-token"
    value = var.github_token
  }
}

# Create diagnostic settings for Container App Job to ensure logs are sent to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "container_app_job_logs" {
  name                       = "diag-${var.job_name}-${var.unique_id}"
  target_resource_id         = azurerm_container_app_job.map_tables.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container_app.id
  
  # Enable all available log categories
  enabled_log {
    category = "ContainerAppConsoleLogs"
  }
  
  enabled_log {
    category = "ContainerAppSystemLogs"
  }
  
  # Enable metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Assign Log Analytics Contributor role to Container App Job system identity
resource "azurerm_role_assignment" "container_app_log_analytics" {
  scope                = azurerm_log_analytics_workspace.container_app.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_container_app_job.map_tables.identity[0].principal_id
  
  depends_on = [azurerm_container_app_job.map_tables]
}
