# Set-DcrLastRunTime

## Purpose

Sets the last successful run time for a specific Data Collection Rule (DCR) in Azure Storage Table. This function maintains execution timestamps to enable incremental data processing, ensuring accurate tracking of processing boundaries and preventing data gaps or duplicates.

## Key Concepts

### Atomic Timestamp Updates

Provides atomic updates to DCR execution timestamps with automatic "updatedat" metadata, ensuring reliable tracking of when each processing run completed successfully.

### Incremental Processing Foundation

Establishes the foundation for incremental data processing by maintaining accurate execution boundaries, enabling efficient processing of only new data since the last successful run.

### Audit Trail Maintenance

Automatically records both the execution timestamp and the update timestamp, providing a complete audit trail of DCR processing history for debugging and compliance purposes.

## Parameters

| Parameter       | Type    | Required | Default | Description                                                          |
| --------------- | ------- | -------- | ------- | -------------------------------------------------------------------- |
| `DcrName`       | String  | Yes      | -       | Name of the Data Collection Rule to update timestamp for             |
| `LastRunTime`   | String  | Yes      | -       | ISO 8601 formatted timestamp of successful execution                 |
| `TableName`     | String  | Yes      | -       | Name of the Azure Storage Table containing DCR timestamps            |
| `StorageContext`| Object  | Yes      | -       | Azure Storage context for table operations                           |

## Return Value

This function does not return a value. Success is indicated by completion without exceptions. Failure results in thrown exceptions with detailed error messages.

## Storage Table Structure

The function creates or updates entities with this structure:

```
PartitionKey: "dcr_timestamps"
RowKey: "{DcrName}"
Properties:
  - lastruntime: {LastRunTime parameter value}
  - updatedat: {Current UTC timestamp in ISO 8601 format}
```

## Usage Examples

### Standard Timestamp Update After Successful Processing

```powershell
# Complete DCR processing workflow with timestamp update
function Complete-DcrProcessingWithTimestamp {
    param(
        [string]$DcrName,
        [string]$StartTime,
        [string]$EndTime,
        [string]$TableName,
        [object]$StorageContext
    )
    
    try {
        Write-Information "Starting processing for $DcrName from $StartTime to $EndTime"
        
        # Perform DCR processing (example)
        $processingResult = Invoke-DataProcessing -DcrName $DcrName -StartTime $StartTime -EndTime $EndTime
        
        if ($processingResult.Success) {
            # Only update timestamp after successful processing
            Set-DcrLastRunTime -DcrName $DcrName -LastRunTime $EndTime -TableName $TableName -StorageContext $StorageContext
            
            Write-Information "✅ Successfully completed processing for $DcrName and updated timestamp to $EndTime"
            
            return @{
                Success = $true
                ProcessedRecords = $processingResult.RecordCount
                TimeWindow = "$StartTime to $EndTime"
                TimestampUpdated = $true
            }
        } else {
            Write-Warning "❌ Processing failed for $DcrName - timestamp not updated"
            return @{
                Success = $false
                Error = $processingResult.ErrorMessage
                TimestampUpdated = $false
            }
        }
        
    } catch {
        Write-Error "Critical error in DCR processing workflow: $($_.Exception.Message)"
        throw
    }
}

# Usage
$result = Complete-DcrProcessingWithTimestamp -DcrName "DCR-Syslog" -StartTime $lastRun -EndTime $currentTime -TableName "eventparsing" -StorageContext $context
```

### Batch Processing with Selective Timestamp Updates

```powershell
# Process multiple DCRs and update timestamps only for successful ones
$dcrProcessingTasks = @(
    @{ Name = "DCR-Syslog"; StartTime = "2024-01-15T08:00:00Z"; EndTime = "2024-01-15T09:00:00Z" },
    @{ Name = "DCR-SecurityEvent"; StartTime = "2024-01-15T08:00:00Z"; EndTime = "2024-01-15T09:00:00Z" },
    @{ Name = "DCR-CloudTrail"; StartTime = "2024-01-15T08:00:00Z"; EndTime = "2024-01-15T09:00:00Z" }
)

$results = @()

foreach ($task in $dcrProcessingTasks) {
    try {
        Write-Information "Processing $($task.Name)..."
        
        # Simulate processing (replace with actual processing logic)
        $success = Invoke-DcrDataProcessing -DcrName $task.Name -StartTime $task.StartTime -EndTime $task.EndTime
        
        if ($success) {
            # Update timestamp only after successful processing
            Set-DcrLastRunTime -DcrName $task.Name -LastRunTime $task.EndTime -TableName "eventparsing" -StorageContext $storageContext
            
            $results += @{
                DcrName = $task.Name
                Status = "Success"
                TimestampUpdated = $true
                EndTime = $task.EndTime
            }
            
            Write-Information "✅ $($task.Name) completed successfully, timestamp updated"
        } else {
            $results += @{
                DcrName = $task.Name
                Status = "Failed"
                TimestampUpdated = $false
                Error = "Processing failed"
            }
            
            Write-Warning "❌ $($task.Name) processing failed, timestamp not updated"
        }
        
    } catch {
        $results += @{
            DcrName = $task.Name
            Status = "Error"
            TimestampUpdated = $false
            Error = $_.Exception.Message
        }
        
        Write-Error "💥 $($task.Name) encountered error: $($_.Exception.Message)"
    }
}

# Generate summary report
$successCount = ($results | Where-Object Status -eq "Success").Count
$failedCount = ($results | Where-Object Status -ne "Success").Count

Write-Host "`n=== BATCH PROCESSING SUMMARY ==="
Write-Host "Total DCRs: $($dcrProcessingTasks.Count)"
Write-Host "Successful: $successCount"
Write-Host "Failed: $failedCount"
Write-Host "Timestamps Updated: $(($results | Where-Object TimestampUpdated).Count)"
```

### Transactional Processing with Rollback Protection

```powershell
# Implement transaction-like behavior for critical processing
function Set-DcrTimestampWithValidation {
    param(
        [string]$DcrName,
        [string]$ProposedTimestamp,
        [string]$TableName,
        [object]$StorageContext
    )
    
    try {
        # Get current timestamp for validation
        $currentTimestamp = Get-DcrLastRunTime -DcrName $DcrName -TableName $TableName -StorageContext $StorageContext
        
        # Parse timestamps for validation
        $currentTime = [datetime]::Parse($currentTimestamp)
        $proposedTime = [datetime]::Parse($ProposedTimestamp)
        
        # Validate proposed timestamp is not going backwards
        if ($proposedTime -le $currentTime) {
            throw "Proposed timestamp ($ProposedTimestamp) is not newer than current timestamp ($currentTimestamp)"
        }
        
        # Validate proposed timestamp is not too far in the future
        $futureLimit = [datetime]::UtcNow.AddHours(1)
        if ($proposedTime -gt $futureLimit) {
            throw "Proposed timestamp ($ProposedTimestamp) is too far in the future"
        }
        
        # Validate time gap is reasonable (not more than 7 days)
        $timeGap = $proposedTime - $currentTime
        if ($timeGap.TotalDays -gt 7) {
            Write-Warning "Large time gap detected ($($timeGap.TotalDays) days) between current and proposed timestamp"
        }
        
        # Store backup of current timestamp before update
        $backupInfo = @{
            DcrName = $DcrName
            PreviousTimestamp = $currentTimestamp
            BackupTime = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        
        # Perform the timestamp update
        Set-DcrLastRunTime -DcrName $DcrName -LastRunTime $ProposedTimestamp -TableName $TableName -StorageContext $StorageContext
        
        Write-Information "✅ Timestamp updated for $DcrName`: $currentTimestamp → $ProposedTimestamp"
        
        return @{
            Success = $true
            PreviousTimestamp = $currentTimestamp
            NewTimestamp = $ProposedTimestamp
            TimeGap = $timeGap.ToString()
            BackupInfo = $backupInfo
        }
        
    } catch {
        Write-Error "Failed to update timestamp for $DcrName`: $($_.Exception.Message)"
        throw
    }
}

# Usage with validation
try {
    $result = Set-DcrTimestampWithValidation -DcrName "DCR-Critical" -ProposedTimestamp "2024-01-15T10:30:00Z" -TableName "eventparsing" -StorageContext $context
    Write-Host "Timestamp update successful: $($result.NewTimestamp)"
} catch {
    Write-Error "Timestamp update failed: $($_.Exception.Message)"
}
```

### Bulk Timestamp Management

```powershell
# Efficiently manage timestamps for multiple DCRs
function Set-BulkDcrTimestamps {
    param(
        [hashtable]$DcrTimestamps,  # @{ "DCR-Name" = "2024-01-15T10:00:00Z" }
        [string]$TableName,
        [object]$StorageContext
    )
    
    $results = @{
        TotalDcrs = $DcrTimestamps.Count
        SuccessCount = 0
        FailureCount = 0
        Successes = @()
        Failures = @()
    }
    
    foreach ($dcrEntry in $DcrTimestamps.GetEnumerator()) {
        $dcrName = $dcrEntry.Key
        $timestamp = $dcrEntry.Value
        
        try {
            # Validate timestamp format
            $parsedTime = [datetime]::Parse($timestamp)
            
            # Update timestamp
            Set-DcrLastRunTime -DcrName $dcrName -LastRunTime $timestamp -TableName $TableName -StorageContext $StorageContext
            
            $results.SuccessCount++
            $results.Successes += @{
                DcrName = $dcrName
                Timestamp = $timestamp
                UpdatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            
            Write-Debug "✅ Updated timestamp for $dcrName to $timestamp"
            
        } catch {
            $results.FailureCount++
            $results.Failures += @{
                DcrName = $dcrName
                Timestamp = $timestamp
                Error = $_.Exception.Message
            }
            
            Write-Warning "❌ Failed to update timestamp for $dcrName`: $($_.Exception.Message)"
        }
    }
    
    Write-Information "Bulk timestamp update completed: $($results.SuccessCount)/$($results.TotalDcrs) successful"
    return $results
}

# Usage for bulk updates
$timestampUpdates = @{
    "DCR-Syslog" = "2024-01-15T10:00:00Z"
    "DCR-SecurityEvent" = "2024-01-15T10:05:00Z"
    "DCR-CloudTrail" = "2024-01-15T10:10:00Z"
}

$bulkResult = Set-BulkDcrTimestamps -DcrTimestamps $timestampUpdates -TableName "eventparsing" -StorageContext $context
```

## Error Handling

### Common Error Scenarios

#### Storage Access Failures

```powershell
try {
    Set-DcrLastRunTime -DcrName "DCR-Test" -LastRunTime "2024-01-15T10:00:00Z" -TableName "eventparsing" -StorageContext $invalidContext
} catch {
    # Error: Storage account access denied, network issues, etc.
    Write-Error "Storage access failed: $($_.Exception.Message)"
}
```

#### Invalid Parameters

```powershell
# Error: Invalid timestamp format
try {
    Set-DcrLastRunTime -DcrName "DCR-Test" -LastRunTime "invalid-date" -TableName "eventparsing" -StorageContext $context
} catch {
    # Function may throw validation errors from underlying storage operations
}

# Error: Empty or null parameters
try {
    Set-DcrLastRunTime -DcrName "" -LastRunTime "2024-01-15T10:00:00Z" -TableName "eventparsing" -StorageContext $context
} catch {
    # Parameter validation errors
}
```

#### Table or Storage Issues

```powershell
# Error: Table doesn't exist
try {
    Set-DcrLastRunTime -DcrName "DCR-Test" -LastRunTime "2024-01-15T10:00:00Z" -TableName "nonexistent" -StorageContext $context
} catch {
    # Table not found errors
    Write-Error "Table operation failed: $($_.Exception.Message)"
}
```

## Performance Characteristics

### Operation Speed

- **Typical response time**: 200-800ms for Storage Table update
- **Network dependency**: Requires connectivity to Azure Storage
- **Atomic operation**: Single table entity upsert operation

### Best Practices

#### Minimize Update Frequency

```powershell
# Avoid updating timestamps too frequently
$minUpdateInterval = 300  # 5 minutes

function Set-DcrTimestampThrottled {
    param($DcrName, $NewTimestamp, $TableName, $StorageContext)
    
    # Get current timestamp
    $currentTimestamp = Get-DcrLastRunTime -DcrName $DcrName -TableName $TableName -StorageContext $StorageContext
    $currentTime = [datetime]::Parse($currentTimestamp)
    $newTime = [datetime]::Parse($NewTimestamp)
    
    # Check if update is needed
    $timeDiff = ($newTime - $currentTime).TotalSeconds
    if ($timeDiff -lt $minUpdateInterval) {
        Write-Debug "Skipping timestamp update for $DcrName - insufficient time difference ($timeDiff seconds)"
        return
    }
    
    # Perform update
    Set-DcrLastRunTime -DcrName $DcrName -LastRunTime $NewTimestamp -TableName $TableName -StorageContext $StorageContext
}
```

## Dependencies

### Required Functions

- **Set-AzTableStorageData**: For updating data in Azure Storage Tables

### Azure Resources

- **Azure Storage Account**: With Table Storage enabled
- **Storage Table**: Target table for timestamp storage
- **Managed Identity**: With Storage Table Data Contributor permissions

### Required Permissions

```
Storage Table Data Contributor
- On the Azure Storage Account
- On the specific table containing DCR timestamps
```

## Integration Examples

### Azure Function Integration

```powershell
# Azure Function timer trigger with timestamp management
param($Timer)

$dcrName = "DCR-ScheduledCollection"
$tableName = "eventparsing"

try {
    # Get last run time
    $lastRunTime = Get-DcrLastRunTime -DcrName $dcrName -TableName $tableName -StorageContext $storageContext
    $currentTime = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
    
    # Process data
    $processingResult = Invoke-DataCollection -StartTime $lastRunTime -EndTime $currentTime
    
    if ($processingResult.Success) {
        # Update timestamp only after successful processing
        Set-DcrLastRunTime -DcrName $dcrName -LastRunTime $currentTime -TableName $tableName -StorageContext $storageContext
        Write-Information "Timer trigger completed successfully, processed $($processingResult.RecordCount) records"
    } else {
        Write-Error "Timer trigger processing failed: $($processingResult.ErrorMessage)"
    }
    
} catch {
    Write-Error "Timer trigger error: $($_.Exception.Message)"
}
```
