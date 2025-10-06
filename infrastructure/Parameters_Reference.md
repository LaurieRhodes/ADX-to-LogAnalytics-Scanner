# Bicep Parameters Reference

## Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `Location` | string | Azure region for deployment | `"Australia SouthEast"` |
| `ResourceGroupID` | string | Full Resource ID of target resource group | `"/subscriptions/{sub-id}/resourceGroups/{rg-name}"` |
| `FunctionAppName` | string | Name for the Function App | `"adx-sentinel-scanner"` |
| `StorageAccountName` | string | Name for storage account (3-24 chars, lowercase) | `"adxscannersa001"` |
| `ApplicationInsightsName` | string | Name for Application Insights | `"adx-scanner-insights"` |
| `UserAssignedIdentityResourceId` | string | Full Resource ID of managed identity | `"/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{name}"` |
| `SentinelWorkspaceID` | string | Full Resource ID of Log Analytics workspace | `"/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{name}"` |
| `ADXClusterURI` | string | URI of Azure Data Explorer cluster | `"https://cluster.region.kusto.windows.net"` |
| `ADXDatabase` | string | Name of ADX database | `"SecurityLogs"` |

## Optional Parameters

| Parameter | Type | Default | Description | Example |
|-----------|------|---------|-------------|---------|
| `QueryPackID` | string | `""` | Full Resource ID of Query Pack | `"/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/querypacks/{name}"` |
| `EventHubResourceID` | string | `""` | Full Resource ID of Event Hub | `"/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.EventHub/namespaces/{ns}/eventhubs/{name}"` |
| `ExistingAppServicePlanResourceId` | string | `""` | Full Resource ID of existing App Service Plan | `"/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{plan-name}"` |

## Parameter Details

### EventHubResourceID

**Format:**
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.EventHub/namespaces/{namespace-name}/eventhubs/{eventhub-name}
```

**How to get:**
```bash
# Azure CLI
az eventhubs eventhub show \
  --resource-group {rg} \
  --namespace-name {namespace} \
  --name {eventhub} \
  --query id -o tsv

# PowerShell
Get-AzEventHub -ResourceGroupName {rg} -NamespaceName {namespace} -Name {eventhub} | Select-Object -ExpandProperty Id
```

Leave empty if not using Event Hub integration.

### ExistingAppServicePlanResourceId

**Purpose:** Deploy Function App to an existing App Service Plan instead of creating a new Consumption Plan

**Format:**
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/serverfarms/{plan-name}
```

**How to get:**
```bash
# Azure CLI
az appservice plan show \
  --name {plan-name} \
  --resource-group {rg} \
  --query id -o tsv

# PowerShell
Get-AzAppServicePlan -ResourceGroupName {rg} -Name {plan-name} | Select-Object -ExpandProperty Id
```

**Deployment Behavior:**
- **Empty (default)**: Creates new Consumption Plan (Y1 SKU)
- **Populated**: Deploys to existing App Service Plan

**When to use:**
- Shared infrastructure across multiple Function Apps
- VNet integration required
- Better performance with dedicated resources
- Predictable costs with reserved capacity
- Premium tier features (always-on, deployment slots)

Leave empty for Consumption Plan (default).

## Example Parameters Files

### Minimum Configuration (Consumption Plan)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "Location": {
      "value": "Australia SouthEast"
    },
    "ResourceGroupID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-adx-scanner"
    },
    "FunctionAppName": {
      "value": "adx-sentinel-scanner"
    },
    "StorageAccountName": {
      "value": "adxscannersa001"
    },
    "ApplicationInsightsName": {
      "value": "adx-scanner-insights"
    },
    "UserAssignedIdentityResourceId": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adx-scanner-identity"
    },
    "SentinelWorkspaceID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-sentinel/providers/Microsoft.OperationalInsights/workspaces/sentinel-workspace"
    },
    "ADXClusterURI": {
      "value": "https://mycluster.australiasoutheast.kusto.windows.net"
    },
    "ADXDatabase": {
      "value": "SecurityLogs"
    },
    "QueryPackID": {
      "value": ""
    },
    "EventHubResourceID": {
      "value": ""
    },
    "ExistingAppServicePlanResourceId": {
      "value": ""
    }
  }
}
```

### Full Configuration (with Event Hub and App Service Plan)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "Location": {
      "value": "Australia SouthEast"
    },
    "ResourceGroupID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-adx-scanner"
    },
    "FunctionAppName": {
      "value": "adx-sentinel-scanner"
    },
    "StorageAccountName": {
      "value": "adxscannersa001"
    },
    "ApplicationInsightsName": {
      "value": "adx-scanner-insights"
    },
    "UserAssignedIdentityResourceId": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adx-scanner-identity"
    },
    "SentinelWorkspaceID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-sentinel/providers/Microsoft.OperationalInsights/workspaces/sentinel-workspace"
    },
    "ADXClusterURI": {
      "value": "https://mycluster.australiasoutheast.kusto.windows.net"
    },
    "ADXDatabase": {
      "value": "SecurityLogs"
    },
    "QueryPackID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-sentinel/providers/Microsoft.OperationalInsights/querypacks/security-queries"
    },
    "EventHubResourceID": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-eventhubs/providers/Microsoft.EventHub/namespaces/security-events/eventhubs/from-adx"
    },
    "ExistingAppServicePlanResourceId": {
      "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-app-services/providers/Microsoft.Web/serverfarms/shared-premium-plan"
    }
  }
}
```

## Deployment Command

```bash
az deployment group create \
  --resource-group rg-adx-scanner \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/parameters.json
```

## Outputs

After deployment, the following outputs are available:

| Output Name | Description |
|-------------|-------------|
| `functionAppName` | Name of the deployed Function App |
| `functionAppId` | Resource ID of the Function App |
| `storageAccountName` | Name of the storage account |
| `managedIdentityClientId` | Client ID of the managed identity |
| `dataCollectionEndpointId` | Resource ID of the Data Collection Endpoint |
| `queryPackConfigured` | Boolean indicating if Query Pack is configured |
| `eventHubConfigured` | Boolean indicating if Event Hub is configured |
| `usingExistingAppServicePlan` | Boolean indicating if using existing App Service Plan |
| `hostingPlanId` | Resource ID of the hosting plan (existing or newly created) |
| `hostingPlanName` | Name of the hosting plan |

## Troubleshooting

### Common Issues

**Event Hub "ParentResourceNotFound" error:**
- Verify Resource ID format is correct
- Ensure all segments are present in the path
- Check Event Hub exists in the specified subscription/resource group

**App Service Plan not found:**
- Verify the plan exists before deployment
- Check Resource ID matches exactly
- Ensure plan is in the specified subscription/resource group

**Permission errors:**
- Managed identity needs Contributor role on Event Hub resource group
- Managed identity needs Contributor role on App Service Plan resource group (if different)

### Validation

Before deploying, validate your parameters:

```bash
az deployment group validate \
  --resource-group rg-adx-scanner \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/parameters.json
```

---

**Last Updated:** October 2025  
**Version:** 2.0 (PascalCase standardization)
