# Get-DcrLastRunTime

## Purpose

Retrieves the last successful run time for a specific Data Collection Rule (DCR) from Azure Storage Table. This function enables incremental data processing by tracking when each DCR was last executed successfully, ensuring data continuity and avoiding duplicates.

## Key Concepts

### Incremental Processing Support

Maintains execution timestamps for each DCR to enable incremental data collection, processing only new data since the last successful run and avoiding reprocessing of historical data.

### Fault-Tolerant Default Behavior

Provides intelligent default behavior when no previous run time exists or when storage access fails, defaulting to 24 hours ago to ensure reasonable data coverage without overwhelming the system.

### Storage Table Integration

Uses Azure Storage Tables with a standardized partition and row key structure for reliable, scalable timestamp persistence across distributed processing scenarios.

## Parameters

| Parameter       | Type    | Required | Default | Description                                                          |
| --------------- | ------- | -------- | ------- | -------------------------------------------------------------------- |
| `DcrName`       | String  | Yes      | -       | Name of the Data Collection Rule to retrieve timestamp for           |
| `TableName`     | String  | Yes      | -       | Name of the Azure Storage Table containing DCR timestamps            |
| `StorageContext`| Object  | Yes      | -       | Azure Storage context for table operations                           |

## Return Value

Returns a string containing an ISO 8601 formatted timestamp:

```powershell
# Successful retrieval
"2024-01-15T10:30:00.0000000Z"

# Default time (24 hours ago) when no previous run found
"2024-01-14T10:30:00.0000000Z"
```

## Storage Table Structure

The function expects a standardized Azure Storage Table structure:

```
PartitionKey: "dcr_timestamps"
RowKey: "{DcrName}"
Properties:
  - lastruntime: ISO 8601 timestamp string
  - updatedat: ISO 8601 timestamp of last update
```

## Dependencies

### Required Functions

- **Get-AzTableStorageData**: For retrieving data from Azure Storage Tables

### Azure Resources

- **Azure Storage Account**: With Table Storage enabled
- **Storage Table**: Named table (commonly "eventparsing") containing timestamps
- **Managed Identity**: With Storage Table Data Contributor permissions

### Required Permissions

```
Storage Table Data Contributor
- On the Azure Storage Account
- On the specific table containing DCR timestamps
```

## Usage Examples

### Standard DCR Timestamp Retrieval

```powershell
# Set up storage context
$storageAccountName = $env:STORAGEACCOUNTNAME
$clientId = $env:CLIENTID
$storageContext = Get-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

# Retrieve last run time for specific DCR
$dcrName = "DCR-Syslog-Collection"
$tableName = "eventparsing"

$lastRunTime = Get-DcrLastRunTime -DcrName $dcrName -TableName $tableName -StorageContext $storageContext

Write-Host "Last run time for $dcrName`: $lastRunTime"

# Use timestamp for incremental processing
$startTime = $lastRunTime
$endTime = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')

Write-Host "Processing data from $startTime to $endTime"
```

### Error Handling and Recovery

```powershell
# Robust timestamp retrieval with comprehensive error handling
function Get-DcrLastRunTimeWithFallback {
    param(
        [string]$DcrName,
        [string]$TableName,
        [object]$StorageContext,
        [string]$FallbackHours = "24"
    )
    
    try {
        # Attempt primary retrieval
        $timestamp = Get-DcrLastRunTime -DcrName $DcrName -TableName $TableName -StorageContext $StorageContext
        
        # Validate timestamp format
        try {
            $parsedTime = [datetime]::Parse($timestamp)
            
            # Validate timestamp is not in the future
            if ($parsedTime -gt [datetime]::UtcNow) {
                Write-Warning "Timestamp for $DcrName is in the future, using fallback"
                return (Get-Date ([datetime]::UtcNow).AddHours(-$FallbackHours) -Format O)
            }
            
            # Validate timestamp is not too old (more than 30 days)
            if (([datetime]::UtcNow - $parsedTime).TotalDays -gt 30) {
                Write-Warning "Timestamp for $DcrName is very old ($($([datetime]::UtcNow - $parsedTime).TotalDays) days), using fallback"
                return (Get-Date ([datetime]::UtcNow).AddHours(-$FallbackHours) -Format O)
            }
            
            return $timestamp
            
        } catch {
            Write-Warning "Invalid timestamp format for $DcrName, using fallback: $($_.Exception.Message)"
            return (Get-Date ([datetime]::UtcNow).AddHours(-$FallbackHours) -Format O)
        }
        
    } catch {
        Write-Warning "Failed to retrieve timestamp for $DcrName, using fallback: $($_.Exception.Message)"
        return (Get-Date ([datetime]::UtcNow).AddHours(-$FallbackHours) -Format O)
    }
}

# Usage with fallback
$safeTimestamp = Get-DcrLastRunTimeWithFallback -DcrName "DCR-Test" -TableName "eventparsing" -StorageContext $context -FallbackHours "12"
```
