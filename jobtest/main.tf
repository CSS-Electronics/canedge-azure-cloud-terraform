terraform {
  required_version = ">= 1.0.0"
  required_providers {
   azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
  # Store Terraform state in the input container
  backend "azurerm" {
    # These values will be provided via backend-config in the deployment script
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  # Explicitly set provider to use the subscription ID for all operations
  skip_provider_registration = true
}

# Get existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get existing storage account
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Get current Azure client details for admin configuration
data "azurerm_client_config" "current" {}

# Define all local values in a single block to avoid duplicates
locals {
  # The output container is always named as <input_container>-parquet by the MDF-to-Parquet component
  output_container_name = "${var.input_container_name}-parquet"
  
  # Construct the filesystem URL in the format required by Synapse:
  # https://<storageaccountname>.dfs.core.windows.net/<filesystem>
  storage_data_lake_gen2_filesystem_id = "https://${var.storage_account_name}.dfs.core.windows.net/${local.output_container_name}"
  
  # Use provided admin email or fallback to a generated one
  admin_email = coalesce(var.admin_email, "${data.azurerm_client_config.current.client_id}@${data.azurerm_client_config.current.tenant_id}.onmicrosoft.com")
}


# Deploy Container App Job for Synapse table mapping
module "container_app_job" {
  source                = "./modules/container_app_job"
  resource_group_name   = var.resource_group_name
  location              = data.azurerm_resource_group.rg.location
  unique_id             = var.unique_id
  storage_account_name  = var.storage_account_name
  output_container_name = local.output_container_name
  synapse_server        = "dummy"
  synapse_sql_password  = "dummy"
  github_token          = var.github_token
  database_name         = "dummy"
  
  # Add tags for resource management
  tags = {
    Environment = "Production"
    Application = "CANedge"
    Component   = "SynapseTableMapper"
  }
}
