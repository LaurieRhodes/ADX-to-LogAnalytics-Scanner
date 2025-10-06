# Event Hub Integration Guide

## Overview

The ADX to Log Analytics Scanner now supports **Event Hub** as an alternative output destination to Data Collection Rules (DCR). This provides flexibility for routing ADX query results to different downstream systems.

## Architecture Decision

Event Hub is implemented as an **ALTERNATIVE** to DCR, not in addition to it.  The Function App automatically detects which destination is configured and routes data accordingly:

- **DCR Mode** (Default): When Event Hub is not configured, data flows to Data Collection Rules → Log Analytics/Sentinel
- **Event Hub Mode**: When Event Hub namespace and name are provided, data flows to Event Hub instead

## Configuration Pattern

Event Hub follows the same optional configuration pattern as Query Pack:

### Bicep Parameters

```bicep
param EVENTHUBNAMESPACE string = ''  // Empty string = disabled
param EVENTHUBNAME string = ''       // Empty string = disabled
```

The infrastructure automatically:

1. Detects if both parameters are provided and non-empty
2. Conditionally deploys Event Hub permissions module
3. Assigns "Azure Event Hubs Data Sender" role to the managed identity
4. Configures environment variables in the Function App

## Deployment Examples

### Example 1: DCR Mode (Default)

**parameters.json**:

```json
{
  "parameters": {
    "ResourceGroupID": {"value": "/subscriptions/.../resourceGroups/rg-ADX-to-LogAnalytics-Scanner"},
    "FunctionAppName": {"value": "adx-sentinel-prod"},
    "SentinelWorkspaceID": {"value": "/subscriptions/.../workspaces/sentinel-prod"},
    "ADXClusterURI": {"value": "https://mycluster.eastus.kusto.windows.net"},
    "ADXDatabase": {"value": "SecurityLogs"},
    "QueryPackID": {"value": ""},
    "EventHubResourceID": {"value": ""}
  }
}
```

**Result**: Data flows to DCR → Log Analytics/Sentinel

### Example 2: Event Hub Mode

**parameters.json**:

```json
{
  "parameters": {
    "ResourceGroupID": {"value": "/subscriptions/.../resourceGroups/rg-ADX-to-LogAnalytics-Scanner"},
    "FunctionAppName": {"value": "adx-eventhub-prod"},
    "SentinelWorkspaceID": {"value": "/subscriptions/.../workspaces/sentinel-prod"},
    "ADXClusterURI": {"value": "https://mycluster.eastus.kusto.windows.net"},
    "ADXDatabase": {"value": "SecurityLogs"},
    "QueryPackID": {"value": ""},
    "EventHubResourceID": {"value": "/subscriptions/.../eventhubs/from-adx"}
  }
}
```

**Result**: Data flows to Event Hub (DCR is bypassed)

### Example 3: With Query Pack and Event Hub

**parameters.json**:

```json
{
  "parameters": {
    "ResourceGroupID": {"value": "/subscriptions/.../resourceGroups/rg-ADX-to-LogAnalytics-Scanner"},
    "FunctionAppName": {"value": "adx-enhanced-prod"},
    "SentinelWorkspaceID": {"value": "/subscriptions/.../workspaces/sentinel-prod"},
    "ADXClusterURI": {"value": "https://mycluster.eastus.kusto.windows.net"},
    "ADXDatabase": {"value": "SecurityLogs"},
    "QueryPackID": {"value": "/subscriptions/.../querypacks/security-queries"},
    "EventHubResourceID": {"value": "/subscriptions/.../eventhubs/from-adx"}
  }
}
```

**Result**: 

- Queries loaded from Query Pack
- Data flows to Event Hub
- DCR is bypassed

## Infrastructure Components

### 1. Conditional Module Deployment

The `main.bicep` includes conditional logic:

```bicep
// Conditional logic: Check if Event Hub is configured
var isEventHubConfigured = !empty(EVENTHUBNAMESPACE) && !empty(EVENTHUBNAME)

// CONDITIONAL MODULE: Event Hub Permissions (only if Event Hub is configured)
module eventHubPermissions 'modules/eventhub-permissions.bicep' = if (isEventHubConfigured) {
  name: 'eventhub-permissions-${functionAppName}'
  params: {
    eventHubNamespace: EVENTHUBNAMESPACE
    eventHubName: EVENTHUBNAME
    managedIdentityPrincipalId: managedIdentity.properties.principalId
    location: location
  }
}
```

### 2. Automatic Permission Assignment

The `eventhub-permissions.bicep` module automatically:

- References existing Event Hub Namespace
- References existing Event Hub
- Assigns "Azure Event Hubs Data Sender" role (GUID: 2b629674-e913-4c01-ae53-ef4638d8f975)
- Scopes the role assignment to the specific Event Hub

### 3. Environment Variables

The Function App automatically receives:

```
EVENTHUBNAMESPACE=my-eventhub-namespace
EVENTHUBNAME=security-events
CLIENTID={managed-identity-client-id}
```

## Runtime Behavior

### Output Destination Detection

The ADXQueryActivity automatically detects the output destination at runtime:

```powershell
# Determine output destination based on environment variables
$isEventHubConfigured = (-not [string]::IsNullOrWhiteSpace($env:EVENTHUBNAMESPACE)) -and `
                        (-not [string]::IsNullOrWhiteSpace($env:EVENTHUBNAME))

if ($isEventHubConfigured) {
    $outputDestination = "EventHub"
    Write-Information "Event Hub configured - data will be sent to Event Hub"
} else {
    $outputDestination = "DCR"
    Write-Information "DCR configured - data will be sent to Data Collection Rules"
}
```

### Event Hub Forwarding Logic

When Event Hub is configured, data forwarding uses batch transmission:

```powershell
if ($outputDestination -eq "EventHub") {
    # Collect all matching records for batch transmission
    $recordsToSend = @()
    foreach ($eventRecord in $eventData) {
        if ($eventRecord.table -eq $tableName) {
            $recordsToSend += $eventRecord.query
        }
    }

    if ($recordsToSend.Count -gt 0) {
        # Convert records to JSON array for Event Hub
        $batchPayload = ConvertTo-Json -InputObject $recordsToSend -Depth 50 -Compress

        # Send to Event Hub with automatic chunking
        $ehResult = Send-ToEventHub -Payload $batchPayload -TableName $tableName `
                                     -ClientId $env:CLIENTID -InstanceId $instanceId

        if ($ehResult.Success) {
            $recordsSent = $ehResult.RecordsProcessed
        }
    }
}
```

## Event Hub Module Features

### Send-ToEventHub Function

The `Send-ToEventHub` function provides:

#### 1. Intelligent Payload Chunking

- Automatic chunking for Basic SKU (256KB limit)
- Safe margin of 230KB per chunk to prevent rejections
- Warning threshold at 200KB

#### 2. Oversized Resource Detection

- Pre-validates individual resources
- Warns about resources exceeding 100KB
- Continues processing with automatic chunking

## Permissions Required

### Managed Identity Requirements

The User-Assigned Managed Identity requires:

1. **For ADX** (both modes):
   
   - Reader or Database Viewer on ADX database

2. **For DCR Mode**:
   
   - Monitoring Metrics Publisher on Data Collection Endpoint

3. **For Event Hub Mode**:
   
   - Azure Event Hubs Data Sender on the Event Hub

### Permission Propagation

⚠️ **IMPORTANT**: Azure role assignments can take up to **24 hours** to propagate fully. If you encounter 401 errors immediately after deployment:

1. Wait 15-30 minutes for initial propagation
2. Test the function again
3. If issues persist after 24 hours, verify role assignments in Azure Portal
