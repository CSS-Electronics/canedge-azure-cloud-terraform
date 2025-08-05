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
}

# Get existing storage account
data "azurerm_storage_account" "existing" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}


# Deploy Container App Job for Backlog Processor
module "container_app_job" {
  source                = "./modules/container_app_job"
  resource_group_name   = var.resource_group_name
  location              = var.location
  unique_id             = var.unique_id
  storage_account_name  = var.storage_account_name
  github_token          = var.github_token
  
  # Add tags for resource management
  tags = {
    Environment = "Production"
    Application = "CANedge"
    Component   = "BacklogProcessor"
  }
}
