#!/bin/bash

# Deployment script for backlog processing resources
# This script deploys resources for processing a backlog of data in Synapse

# Default values
SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
STORAGE_ACCOUNT=""
INPUT_CONTAINER=""
UNIQUE_ID=""
REGION=""


# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --subid)
      SUBSCRIPTION_ID="$2"
      shift
      shift
      ;;
    --resourcegroup)
      RESOURCE_GROUP="$2"
      shift
      shift
      ;;
    --storageaccount)
      STORAGE_ACCOUNT="$2"
      shift
      shift
      ;;
    --container)
      INPUT_CONTAINER="$2"
      shift
      shift
      ;;
    --id)
      UNIQUE_ID="$2"
      shift
      shift
      ;;

    --github-token)
      GITHUB_TOKEN="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Check required parameters
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "Error: Subscription ID (--subid) is required"
  exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Error: Resource group (--resourcegroup) is required"
  exit 1
fi

if [[ -z "$STORAGE_ACCOUNT" ]]; then
  echo "Error: Storage account (--storageaccount) is required"
  exit 1
fi

if [[ -z "$INPUT_CONTAINER" ]]; then
  echo "Error: Input container (--container) is required"
  exit 1
fi

if [[ -z "$UNIQUE_ID" ]]; then
  echo "Error: Unique ID (--id) is required"
  exit 1
fi

# Set the subscription context
echo "Setting Azure subscription context to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Check if subscription exists
echo "Verifying subscription ID: $SUBSCRIPTION_ID..."
SUB_NAME=$(az account show --subscription "$SUBSCRIPTION_ID" --query "name" -o tsv 2>/dev/null)
if [ -z "$SUB_NAME" ]; then
  echo "Error: Subscription ID $SUBSCRIPTION_ID not found or not accessible"
  exit 1
else
  echo "Found subscription: $SUB_NAME"
fi

echo "Registering the Microsoft.App resource provider (needed for Container Apps)..."
az provider register --namespace Microsoft.App

echo "Registering the Microsoft.OperationalInsights resource provider (needed for Log Analytics)..."
az provider register --namespace Microsoft.OperationalInsights

echo "Waiting for registration to complete (this may take a few minutes)..."

# Wait for Microsoft.App registration to complete
while [ "$(az provider show -n Microsoft.App --query "registrationState" -o tsv)" != "Registered" ]; do
  echo "Still registering Microsoft.App provider... (this can take several minutes)"
  sleep 10
done
echo "Microsoft.App provider is now registered."

# Wait for Microsoft.OperationalInsights registration to complete
while [ "$(az provider show -n Microsoft.OperationalInsights --query "registrationState" -o tsv)" != "Registered" ]; do
  echo "Still registering Microsoft.OperationalInsights provider... (this can take several minutes)"
  sleep 10
done
echo "Microsoft.OperationalInsights provider is now registered."

# Verify that the resource group exists
echo "Verifying resource group: $RESOURCE_GROUP"
RESGROUP_EXISTS=$(az group exists --name "$RESOURCE_GROUP")
if [ "$RESGROUP_EXISTS" != "true" ]; then
  echo "Error: Resource group '$RESOURCE_GROUP' does not exist in subscription '$SUBSCRIPTION_ID'."
  exit 1
fi

# Verify that the storage account exists
echo "Verifying storage account: $STORAGE_ACCOUNT"
STORAGE_EXISTS=$(az storage account check-name --name "$STORAGE_ACCOUNT" --query "nameAvailable" -o tsv)
if [ "$STORAGE_EXISTS" == "true" ]; then
  echo "Error: Storage account '$STORAGE_ACCOUNT' does not exist in resource group '$RESOURCE_GROUP'."
  exit 1
fi

# Verify that the input container exists
echo "Verifying input container: $INPUT_CONTAINER"
az storage container show --name "$INPUT_CONTAINER" --account-name "$STORAGE_ACCOUNT" --auth-mode login > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Input container $INPUT_CONTAINER does not exist in storage account $STORAGE_ACCOUNT"
  exit 1
fi
echo "Input container $INPUT_CONTAINER exists"

# If region is not specified, get it from the storage account
if [ -z "$REGION" ]; then
  REGION=$(az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --query "location" -o tsv)
  echo "✓ Using region from storage account: $REGION"
fi


echo "========================================================"
echo "Starting deployment with the following parameters:"
echo "  Subscription:    $SUBSCRIPTION_ID"
echo "  Resource Group:  $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Input Container: $INPUT_CONTAINER"
echo "  Unique ID:       $UNIQUE_ID"
echo "  Region:          $REGION"
[[ -n "$GITHUB_TOKEN" ]] && echo "  GitHub Token:    Provided" || echo "  GitHub Token:    Not provided (public image required)"
echo "========================================================"

# Navigate to the relevant terraform directory
cd "$(dirname "$0")/jobtest"

# Set up Terraform state storage in the input container
echo "Setting up Terraform state storage in the input container..."

# Initialize Terraform with remote state
echo "Initializing Terraform with remote state..."
terraform init \
  -backend-config="subscription_id=$SUBSCRIPTION_ID" \
  -backend-config="resource_group_name=$RESOURCE_GROUP" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
  -backend-config="container_name=$INPUT_CONTAINER" \
  -backend-config="key=terraform/state/jobtest/default.tfstate"

# Create a terraform.tfvars file to avoid interactive prompts
echo "Creating terraform.tfvars file..."
cat > terraform.tfvars << EOF
subscription_id = "$SUBSCRIPTION_ID"
resource_group_name = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT"
input_container_name = "$INPUT_CONTAINER"
unique_id = "$UNIQUE_ID"
github_token = "$GITHUB_TOKEN"
EOF

# Set environment variables for Terraform to use
export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
export TF_VAR_resource_group_name="$RESOURCE_GROUP"
export TF_VAR_storage_account_name="$STORAGE_ACCOUNT"
export TF_VAR_input_container_name="$INPUT_CONTAINER"
export TF_VAR_unique_id="$UNIQUE_ID"
export TF_VAR_location="$REGION"
export TF_IN_AUTOMATION="true"  # This prevents interactive prompts

# Construct the Azure resource ID for the filesystem
STORAGE_ACCOUNT_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
FILESYSTEM_ID="$STORAGE_ACCOUNT_ID/blobServices/default/containers/${INPUT_CONTAINER}-parquet"

# Define our fixed state path
STATE_PATH="terraform/state/jobtest/default.tfstate"
echo "Using state path: $STATE_PATH"

# Clean up local Terraform files
rm -rf .terraform .terraform.lock.hcl

# Simple Terraform initialization
echo "Initializing Terraform..."
terraform init \
  -backend-config="subscription_id=$SUBSCRIPTION_ID" \
  -backend-config="resource_group_name=$RESOURCE_GROUP" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
  -backend-config="container_name=$INPUT_CONTAINER" \
  -backend-config="key=$STATE_PATH"

# Apply the configuration
echo "Applying Terraform configuration..."  
terraform apply -auto-approve \
  -var "subscription_id=$SUBSCRIPTION_ID" \
  -var "resource_group_name=$RESOURCE_GROUP" \
  -var "storage_account_name=$STORAGE_ACCOUNT" \
  -var "input_container_name=$INPUT_CONTAINER" \
  -var "unique_id=$UNIQUE_ID" \
  -var="location=${REGION}"


TERRAFORM_EXIT_CODE=$?

if [ $TERRAFORM_EXIT_CODE -ne 0 ]; then
  echo "Terraform apply failed."
  echo "Fix any errors above and try again."
  exit 1
else
  echo "Terraform apply succeeded!"
  
  # Get the container app job's principal ID and log analytics workspace ID from Terraform outputs
  echo "Getting container app job's managed identity and Log Analytics workspace information..."
  PRINCIPAL_ID=$(terraform output -raw module.container_app_job.job_principal_id 2>/dev/null)
  LOG_ANALYTICS_ID=$(terraform output -raw module.container_app_job.log_analytics_id 2>/dev/null)
  
  # Debug information
  echo "Principal ID: $PRINCIPAL_ID"
  echo "Log Analytics ID: $LOG_ANALYTICS_ID"
  
  # Check if we have both required IDs
  if [ -n "$PRINCIPAL_ID" ] && [ -n "$LOG_ANALYTICS_ID" ]; then
    echo "Assigning Log Analytics Contributor role to container app job's managed identity..."
    
    # Wait a moment for the identity to fully propagate in Azure
    echo "Waiting 15 seconds for the managed identity to propagate..."
    sleep 15
    
    # Try first with --skip-assignment-check to avoid potential permission issues
    az role assignment create \
      --assignee-object-id "$PRINCIPAL_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "Log Analytics Contributor" \
      --scope "$LOG_ANALYTICS_ID" \
      --skip-assignment-check true \
      -o json
    
    ROLE_RESULT=$?
    
    if [ $ROLE_RESULT -eq 0 ]; then
      echo "✅ Log Analytics permissions successfully assigned to container app job."
    else
      echo "⚠️ Failed to assign Log Analytics permissions with skip-assignment-check. Trying alternative approach..."
      
      # Try with the Monitoring Metrics Publisher role instead, which might be more appropriate
      az role assignment create \
        --assignee-object-id "$PRINCIPAL_ID" \
        --assignee-principal-type ServicePrincipal \
        --role "Monitoring Metrics Publisher" \
        --scope "$LOG_ANALYTICS_ID" \
        --skip-assignment-check true \
        -o json
      
      if [ $? -eq 0 ]; then
        echo "✅ Monitoring Metrics Publisher role assigned successfully."
      else
        echo "⚠️ Failed to assign permissions. Your container app logs may not appear correctly."
        echo "You may need to manually assign permissions in the Azure Portal:"
        echo "1. Go to your Log Analytics workspace"
        echo "2. Select Access control (IAM)"
        echo "3. Add a role assignment for the container app's managed identity"
        echo "4. Choose either 'Log Analytics Contributor' or 'Monitoring Metrics Publisher'"
      fi
    fi
  else
    echo "⚠️ Could not retrieve managed identity or Log Analytics information. Skipping role assignment."
  fi
fi



# Only show connection details if deployment was successful
if [ $TERRAFORM_EXIT_CODE -eq 0 ]; then
  # Show Container App Job information
  echo "======================================================="
  echo "Backlog Processor deployment completed successfully"
  echo "======================================================="
  exit 0
else
  echo "======================================================="
  echo "Deployment had issues. Please check the output above for more details."
  echo "======================================================="
  exit $TERRAFORM_EXIT_CODE
fi
