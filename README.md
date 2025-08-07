# CANedge Azure Cloud Platform Deployment

This repository provides Terraform configurations to automate the deployment of CANedge data processing infrastructure on Azure.

1. **Input Container Deployment**: Creates an input container for storing uploaded CANedge log files
2. **MF4-to-Parquet Deployment**: Creates an output container and Function for DBC decoding MDF to Parquet
3. **Synapse Deployment**: Creates Synapse resources for querying Parquet data (e.g. from Grafana dashboards)

----------

## Deployment

### Setup Instructions

![Azure Cloud Shell](http://canlogger1000.csselectronics.com/img/azure-console-setup-terraform-crop.png)

1. Log in to [Azure](https://portal.azure.com/#home)
3. Click on the Cloud Shell icon (>_) to open Cloud Shell (top right) and select 'Bash'
4. Once Cloud Shell is open, run below command to clone this repository (paste via **ctrl+shift+v**):

```bash
cd ~ && rm -rf canedge-azure-cloud-terraform && git clone https://github.com/CSS-Electronics/canedge-azure-cloud-terraform.git && cd canedge-azure-cloud-terraform
```


&nbsp;

### 1: Deploy Input Container

If you're just getting started, first deploy the input container where your CANedge devices will upload MF4 files:

```bash
chmod +x deploy_input_container.sh && ./deploy_input_container.sh --subid YOUR_SUBSCRIPTION_ID  --resourcegroup YOUR_RESOURCE_GROUP --storageaccount YOUR_STORAGE_ACCOUNT --region YOUR_REGION --container YOUR_CONTAINER_NAME
```

Replace:
- `YOUR_SUBSCRIPTION_ID` with your desired Azure subscription ID (e.g. `ff652281-fac4-4dbb-b2ba-819cdf28ac83`)
- `YOUR_RESOURCE_GROUP` with your desired resource group (e.g. `canedge-resources`)
- `YOUR_STORAGE_ACCOUNT` with your desired storage account, existing or new (e.g. `canedgestorage1`)
- `YOUR_REGION` with your desired region (e.g., `germanywestcentral` - see [this link](https://azuretracks.com/2021/04/current-azure-region-names-reference/) for available regions)
- `YOUR_CONTAINER_NAME` with your desired container name (e.g. `canedge-test-container-20`)

&nbsp;

### 2: Deploy MF4-to-Parquet Pipeline

Once you have an input container set up, you can optionally deploy the processing pipeline to automatically DBC decode uploaded MF4 files to Parquet format and provide backlog/aggregation processing capabilities:

```bash
chmod +x deploy_mdftoparquet.sh && ./deploy_mdftoparquet.sh  --subid YOUR_SUBSCRIPTION_ID --resourcegroup YOUR_RESOURCE_GROUP --storageaccount YOUR_STORAGE_ACCOUNT --container YOUR_INPUT_CONTAINER_NAME --id YOUR_UNIQUE_ID --email YOUR_EMAIL --github-token YOUR_GITHUB_TOKEN

```

Replace:
- `YOUR_SUBSCRIPTION_ID` with your desired Azure subscription ID (e.g. `ff652281-fac4-4dbb-b2ba-819cdf28ac83`)
- `YOUR_RESOURCE_GROUP` with your input container resource group from step 1 (e.g. `canedge-resources`)
- `YOUR_STORAGE_ACCOUNT` with your input storage account from step 1 (e.g. `canedgestorage1`)
- `YOUR_INPUT_CONTAINER_NAME` with your input container name from step 1 (e.g. `canedge-test-container-20`)
- `YOUR_UNIQUE_ID` with a short unique identifier (e.g. `datalake1`)
- `YOUR_EMAIL` with your email address to receive notifications
- `YOUR_GITHUB_TOKEN` with the GitHub token for accessing the backlog/aggregation processor container registry
  - *Get the token from the [CANedge Intro](https://www.csselectronics.com/pages/can-bus-hardware-software-docs) (Process/MF4 decoders/Parquet data lake/Azure)*

Optional Parameters:
- `--zip YOUR_FUNCTION_ZIP` to specify a custom function ZIP file name
  - *Download the ZIP from the [CANedge Intro](https://www.csselectronics.com/pages/can-bus-hardware-software-docs) (Process/MF4 decoders/Parquet data lake/Azure)*


> [!NOTE]  
> Make sure to upload the function ZIP to your input container root before deployment

> [!NOTE]  
> If the deployment fails you may need to refresh the page, repeat the setup instructions and deploy again

&nbsp;


### 3: Deploy Synapse

After setting up the MF4-to-Parquet pipeline, you can deploy Synapse to query your Parquet data lake:

```bash
chmod +x deploy_synapse.sh && ./deploy_synapse.sh --subid YOUR_SUBSCRIPTION_ID --resourcegroup YOUR_RESOURCE_GROUP --storageaccount YOUR_STORAGE_ACCOUNT --container YOUR_INPUT_CONTAINER_NAME --id YOUR_UNIQUE_ID --database YOUR_DATABASE_NAME --github-token CSS_GITHUB_TOKEN

```

Replace:
- `YOUR_SUBSCRIPTION_ID` with your desired Azure subscription ID (e.g. `ff652281-fac4-4dbb-b2ba-819cdf28ac83`)
- `YOUR_RESOURCE_GROUP` with your input container resource group from step 1 (e.g. `canedge-resources`)
- `YOUR_STORAGE_ACCOUNT` with your input storage account from step 1 (e.g. `canedgestorage1`)
- `YOUR_INPUT_CONTAINER_NAME` with your input container name from step 1 (e.g. `canedge-test-container-20`)
- `YOUR_UNIQUE_ID` with your unique identifier from step 1 (e.g. `datalake1`)
- `YOUR_DATABASE_NAME` with your desired Synapse database name (e.g. `database1`)
- `CSS_GITHUB_TOKEN` with the github token provided by CSS Electronics
  - *Get the token from the [CANedge Intro](https://www.csselectronics.com/pages/can-bus-hardware-software-docs) (Process/MF4 decoders/Parquet data lake - interfaces/Azure)*

> [!NOTE]  
> Pay-as-you-go subscriptions are limited to 2 active Synapse workspaces and the deployment fails if you have reached this quota limit. In this case, remove any unused workspaces and deploy again

----------

## Troubleshooting

If you encounter issues with either deployment:

- Make sure you have proper permissions in your Azure cloud
- Try refreshing the page and restarting the shell (make sure to select 'Bash' mode)
- For the MF4-to-Parquet deployment ensure the function ZIP is uploaded to your input container
- Use unique identifiers with the `--id` parameter to avoid resource conflicts
- When deploying the MF4-to-Parquet pipeline, it can take 5-10 min for the function to be fully deployed. You can then open the 'Logs' tab in the function in one tab and after 1-3 min upload an MF4 test file to your input container to track the decoding results in real-time
- If your function does not deploy in your Function App, check Monitoring/Logs/KQL mode with below:

  ```
  traces
  | where timestamp > ago(0.1h)
  | where customDimensions.Category == "Host.Function.Console"
  | order by timestamp desc
  ```

- If your Azure Job fails (backlog processing or synapse table mapping), wait 5 mins and go to 'Execution history/Logs/Console' for details
- [Contact us](https://www.csselectronics.com/pages/contact-us) if you need deployment support
