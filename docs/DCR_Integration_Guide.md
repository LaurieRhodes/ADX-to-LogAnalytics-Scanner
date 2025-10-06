# Data Collection Rules (DCR) Integration Guide

## Overview

The infrastructure has been enhanced to automatically provision Data Collection Rules (DCRs) and a Data Collection Endpoint (DCE) for sending data from Azure Data Explorer queries to your Sentinel workspace via Azure Monitor Logs Ingestion API.

## Architecture Changes

### Bicep Infrastructure
- **Data Collection Endpoint (DCE)**: Single endpoint for all log ingestion
- **Data Collection Rules (DCRs)**: One per table type, with Sentinel workspace-specific naming
- **Role Assignments**: Managed identity granted "Monitoring Metrics Publisher" role for each DCR
- **Environment Variables**: DCR IDs automatically configured in Function App

### Naming Convention
- **DCE Name**: `dce-{functionAppName}-{sentinelWorkspaceName}`
- **DCR Deployment Names**: `dcr-{sentinelWorkspaceName}-{TableType}`
- **Environment Variables**: `DCR{TableType}` (without workspace name for consistency)

## Configured Data Collection Rules

The following DCRs are automatically deployed:

| Table Type | Environment Variable | Priority | Purpose |
|------------|---------------------|----------|---------|
| ASimNetworkSessionLogs | `DCRASimNetworkSessionLogs` | 1 | Network session logs |
| AWSCloudTrail | `DCRAWSCloudTrail` | 1 | AWS CloudTrail logs |
| AWSCloudWatch | `DCRAWSCloudWatch` | 2 | AWS CloudWatch logs |
| AWSGuardDuty | `DCRAWSGuardDuty` | 1 | AWS GuardDuty logs |
| CommonSecurityLog | `DCRCommonSecurityLog` | 1 | Common security logs |
| SecurityEvent | `DCRSecurityEvent` | 1 | Windows security events |
| Syslog | `DCRSyslog` | 2 | Unix/Linux syslog |
| Anomalies | `DCRAnomalies` | 3 | Security anomalies |

## Environment Variables

The Function App automatically receives these environment variables:

### DCR Configuration
```
DCRASimNetworkSessionLogs=<dcr-immutable-id>
DCRAWSCloudTrail=<dcr-immutable-id>
DCRAWSCloudWatch=<dcr-immutable-id>
DCRAWSGuardDuty=<dcr-immutable-id>
DCRCommonSecurityLog=<dcr-immutable-id>
DCRSecurityEvent=<dcr-immutable-id>
DCRSyslog=<dcr-immutable-id>
DCRAnomalies=<dcr-immutable-id>
```

### Endpoint Configuration
```
DATA_COLLECTION_ENDPOINT_ID=<dce-resource-id>
DATA_COLLECTION_ENDPOINT_URL=<dce-ingestion-url>
SENTINEL_WORKSPACE_ID=<workspace-resource-id>
SENTINEL_WORKSPACE_NAME=<workspace-name>
```

## Function App Integration

### SupervisorFunction Updates
The SupervisorFunction now:
- Reads DCR IDs from environment variables
- Validates DCR configuration at startup
- Filters out tables with missing DCR IDs
- Includes DCE and workspace information in orchestration context

### Error Handling
- Missing DCR environment variables are logged as warnings
- Tables with missing DCRs are excluded from processing
- Execution continues with available tables
- Health checks include DCE status validation

## Deployment Process

### Prerequisites
1. Sentinel workspace must exist at the specified resource ID
2. Managed identity must have appropriate permissions
3. All DCR Bicep files must be present in `infrastructure/data-collection-rules/`

### Deployment Steps
```powershell
# Navigate to infrastructure directory
cd infrastructure/

# Deploy infrastructure with DCRs
az deployment group create --resource-group <your-resource-group> --template-file main.bicep --parameters @parameters.json
```

### Post-Deployment Validation
1. Verify DCE is created: `dce-{functionAppName}-{workspaceName}`
2. Verify DCRs are created with correct naming
3. Check Function App environment variables are populated
4. Validate managed identity role assignments
5. Test Function App startup logs for DCR validation

## Adding New DCRs

To add new Data Collection Rules:

### 1. Create DCR Bicep File
```bicep
// infrastructure/data-collection-rules/DCR-NewTableType.bicep
param location string
param workspaceResourceId string
param dataCollectionEndpointId string

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'write-to-NewTableType'
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    // ... DCR configuration
  }
}

output immutableId string = dataCollectionRule.properties.immutableId
```

### 2. Update main.bicep
Add module deployment:
```bicep
module dcrNewTableType 'data-collection-rules/DCR-NewTableType.bicep' = {
  name: 'dcr-${sentinelWorkspaceName}-NewTableType'
  params: {
    location: location
    dataCollectionEndpointId: dataCollectionEndpoint.id
    workspaceResourceId: sentinelWorkspaceID
  }
}
```

Add environment variable:
```bicep
{
  name: 'DCRNewTableType'
  value: dcrNewTableType.outputs.immutableId
}
```

Add role assignment:
```bicep
resource dcrRoleAssignmentNewTableType 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dcrNewTableType.outputs.immutableId, managedIdentity.id, 'Monitoring Metrics Publisher')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
```

### 3. Update SupervisorFunction
Add table mapping:
```powershell
"NewTableType" = @{
    "Function" = "Send-toDCRNewTableType"
    "DcrId" = $env:DCRNewTableType
    "Priority" = 2
}
```

## Data Ingestion Usage

In your ADXQueryActivity function, use the DCR IDs for Log Analytics ingestion:

```powershell
# Example usage in ADXQueryActivity
$dcrId = $input.DcrId  # From environment variable
$dceUrl = $env:DATA_COLLECTION_ENDPOINT_URL
$streamName = "Custom-$($input.TableName)"

# Send data to Log Analytics via DCR
Invoke-RestMethod -Uri "$dceUrl/dataCollectionRules/$dcrId/streams/$streamName" `
    -Method POST `
    -Headers @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    } `
    -Body ($jsonData | ConvertTo-Json)
```

## Monitoring and Troubleshooting

### Common Issues
1. **Missing DCR Environment Variables**: Check deployment outputs and Function App configuration
2. **Permission Errors**: Verify managed identity role assignments
3. **Ingestion Failures**: Check DCR configuration and data schema match
4. **DCE Connectivity**: Validate Data Collection Endpoint URL

### Monitoring Queries
```kql
// Check DCR ingestion success
DCRLogErrors
| where TimeGenerated > ago(1h)
| where DcrId in ("dcr-immutable-id-1", "dcr-immutable-id-2")

// Monitor Function App DCR usage
traces
| where operation_Name == "SupervisorFunction"
| where message contains "DCR"
| order by timestamp desc
```

## Security Considerations
- DCR IDs are not sensitive but should be kept consistent
- Managed identity permissions are scoped to specific DCRs
- Data Collection Endpoint URL is public but requires authentication
- Log Analytics workspace access is controlled separately

The DCR integration provides a scalable, secure method for ingesting ADX query results into your Sentinel workspace with proper schema validation and transformation capabilities.