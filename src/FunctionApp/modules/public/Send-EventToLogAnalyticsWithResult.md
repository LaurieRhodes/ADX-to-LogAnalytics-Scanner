# Send-EventToLogAnalyticsWithResult

## Purpose

A wrapper function for Send-EventToLogAnalytics that provides detailed result reporting and structured error handling. This function returns comprehensive processing results instead of throwing exceptions, making it ideal for batch processing scenarios and automated retry logic.

## Key Concepts

### Result-Based Processing

Returns a structured hashtable with success status, error messages, and processing metadata instead of throwing exceptions, enabling better error handling in automation scenarios.

### Detailed Processing Metadata

Provides comprehensive information about the processing attempt including timestamps, processing method, and event type for audit trails and debugging purposes.

### Universal DCR Integration

Uses the same universal DCR module integration as Send-EventToLogAnalytics but wraps the execution in exception handling to provide controlled result reporting.

## Parameters

| Parameter        | Type      | Required | Default | Description                                                    |
| ---------------- | --------- | -------- | ------- | -------------------------------------------------------------- |
| `EventRecord`    | String    | Yes      | -       | JSON formatted event record to send to Log Analytics          |
| `EventType`      | String    | Yes      | -       | Type of event (corresponds to table name, e.g., "Syslog")     |
| `DcrMappingTable`| Hashtable | Yes      | -       | Hashtable mapping event types to DCR configurations           |

## Return Value

Returns a hashtable with the following structure:

```powershell
@{
    Success = $true/$false                           # Boolean indicating operation success
    ErrorMessage = $null/"Error description"        # String containing error details if failed
    EventType = "TableName"                         # Echo of the input event type
    ProcessingMethod = "UniversalDCR"               # Processing method identifier
    Timestamp = "yyyy-MM-ddTHH:mm:ssZ"              # ISO 8601 timestamp of processing attempt
}
```

## Usage Examples

### Standard Event Processing with Result Handling

```powershell
# Define DCR mapping configuration
$dcrMappingTable = @{
    "Syslog" = @{ DcrId = "dcr-syslog-12345" }
    "SecurityEvent" = @{ DcrId = "dcr-security-67890" }
}

# Prepare event data
$eventData = @{
    TenantId = "12345678-1234-1234-1234-123456789012"
    TimeGenerated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    Computer = "Server01"
    SeverityLevel = "Informational"
    Facility = "auth"
    SyslogMessage = "User authentication successful"
} | ConvertTo-Json -Compress

# Send event with result handling
$result = Send-EventToLogAnalyticsWithResult -EventRecord $eventData -EventType "Syslog" -DcrMappingTable $dcrMappingTable

if ($result.Success) {
    Write-Host "✅ Event successfully sent to $($result.EventType) at $($result.Timestamp)"
} else {
    Write-Error "❌ Failed to send $($result.EventType): $($result.ErrorMessage)"
}
```

### Batch Processing with Result Aggregation

```powershell
# Process multiple events and collect results
$events = @(
    @{ Type = "Syslog"; Data = $syslogJson },
    @{ Type = "SecurityEvent"; Data = $securityEventJson },
    @{ Type = "AWSCloudTrail"; Data = $cloudTrailJson }
)

$results = @()
$successCount = 0
$failureCount = 0

foreach ($event in $events) {
    $result = Send-EventToLogAnalyticsWithResult -EventRecord $event.Data -EventType $event.Type -DcrMappingTable $dcrMappingTable
    $results += $result
    
    if ($result.Success) {
        $successCount++
        Write-Information "✅ $($event.Type) processed successfully"
    } else {
        $failureCount++
        Write-Warning "❌ $($event.Type) failed: $($result.ErrorMessage)"
    }
}

# Generate summary report
Write-Host "Processing Summary:"
Write-Host "  Total Events: $($events.Count)"
Write-Host "  Successful: $successCount"
Write-Host "  Failed: $failureCount"
Write-Host "  Success Rate: $([math]::Round(($successCount / $events.Count) * 100, 2))%"
```

### Retry Logic Implementation

```powershell
function Send-EventWithRetry {
    param(
        [string]$EventRecord,
        [string]$EventType,
        [hashtable]$DcrMappingTable,
        [int]$MaxRetries = 3,
        [int]$BaseDelaySeconds = 2
    )
    
    $attempt = 0
    do {
        $attempt++
        Write-Information "Attempt $attempt/$MaxRetries for $EventType"
        
        $result = Send-EventToLogAnalyticsWithResult -EventRecord $EventRecord -EventType $EventType -DcrMappingTable $DcrMappingTable
        
        if ($result.Success) {
            Write-Host "✅ $EventType succeeded on attempt $attempt"
            return $result
        }
        
        # Check if error is retryable
        $isRetryable = $result.ErrorMessage -match "timeout|network|429|502|503|504"
        
        if (-not $isRetryable) {
            Write-Warning "❌ $EventType failed with non-retryable error: $($result.ErrorMessage)"
            return $result
        }
        
        if ($attempt -lt $MaxRetries) {
            $delaySeconds = $BaseDelaySeconds * [math]::Pow(2, $attempt - 1)  # Exponential backoff
            Write-Information "Retrying $EventType in $delaySeconds seconds..."
            Start-Sleep -Seconds $delaySeconds
        }
        
    } while ($attempt -lt $MaxRetries)
    
    Write-Error "❌ $EventType failed after $MaxRetries attempts: $($result.ErrorMessage)"
    return $result
}

# Usage with retry logic
$result = Send-EventWithRetry -EventRecord $eventData -EventType "Syslog" -DcrMappingTable $dcrMappingTable -MaxRetries 3
```

### Error Analysis and Reporting

```powershell
# Collect detailed error analytics
$errorAnalytics = @{
    TotalEvents = 0
    SuccessfulEvents = 0
    FailedEvents = 0
    ErrorCategories = @{}
    DetailedResults = @()
}

foreach ($event in $eventsToProcess) {
    $errorAnalytics.TotalEvents++
    
    $result = Send-EventToLogAnalyticsWithResult -EventRecord $event.Data -EventType $event.Type -DcrMappingTable $dcrMappingTable
    $errorAnalytics.DetailedResults += $result
    
    if ($result.Success) {
        $errorAnalytics.SuccessfulEvents++
    } else {
        $errorAnalytics.FailedEvents++
        
        # Categorize errors
        $errorCategory = switch -Regex ($result.ErrorMessage) {
            "DcrId not specified|not configured" { "Configuration" }
            "DATA_COLLECTION_ENDPOINT_URL|CLIENTID" { "Environment" }
            "400|Bad Request" { "ValidationError" }
            "401|403|Unauthorized|Forbidden" { "Authentication" }
            "429|Too Many Requests" { "RateLimit" }
            "timeout|network" { "Network" }
            "500|502|503|504" { "ServerError" }
            default { "Unknown" }
        }
        
        if (-not $errorAnalytics.ErrorCategories.ContainsKey($errorCategory)) {
            $errorAnalytics.ErrorCategories[$errorCategory] = 0
        }
        $errorAnalytics.ErrorCategories[$errorCategory]++
    }
}

# Generate error report
Write-Host "=== ERROR ANALYSIS REPORT ==="
Write-Host "Total Events Processed: $($errorAnalytics.TotalEvents)"
Write-Host "Successful: $($errorAnalytics.SuccessfulEvents)"
Write-Host "Failed: $($errorAnalytics.FailedEvents)"
Write-Host ""
Write-Host "Error Categories:"
foreach ($category in $errorAnalytics.ErrorCategories.Keys) {
    $count = $errorAnalytics.ErrorCategories[$category]
    $percentage = [math]::Round(($count / $errorAnalytics.FailedEvents) * 100, 2)
    Write-Host "  $category`: $count ($percentage%)"
}
```

## Error Handling

### Error Response Structure

When an error occurs, the function captures the exception and returns it in a structured format:

```powershell
$errorResult = @{
    Success = $false
    ErrorMessage = "Detailed error description"
    EventType = "Syslog"
    ProcessingMethod = "UniversalDCR"
    Timestamp = "2024-01-15T10:30:00Z"
}
```

### Common Error Types

#### Configuration Errors

```powershell
# Missing DCR mapping
$result = Send-EventToLogAnalyticsWithResult -EventRecord $json -EventType "UnknownType" -DcrMappingTable $config
# Result.ErrorMessage: "Unsupported event type UnknownType. Valid types are Syslog, SecurityEvent"
```

#### Environment Errors

```powershell
# Missing environment variables
# Result.ErrorMessage: "DATA_COLLECTION_ENDPOINT_URL environment variable not set"
# Result.ErrorMessage: "CLIENTID environment variable not set"
```

#### Validation Errors

```powershell
# Invalid JSON format
# Result.ErrorMessage: "EventRecord cannot be null"
# Result.ErrorMessage: "EventType cannot be null or empty"
```

## Performance Characteristics

### Processing Overhead

- **Additional overhead**: ~5-10ms for result structure creation and exception handling
- **Memory usage**: Minimal additional memory for result hashtable
- **Error handling**: Catches and processes exceptions without re-throwing

### Batch Processing Benefits

When processing large numbers of events, this function provides:

- **Graceful degradation**: Failed events don't stop processing of subsequent events
- **Detailed reporting**: Comprehensive success/failure analytics
- **Error categorization**: Structured error information for analysis

## Integration Patterns

### Azure Function Integration

```powershell
# Azure Function with comprehensive result handling
param($eventHubTrigger, $TriggerMetadata)

$dcrMappings = @{
    "Syslog" = @{ DcrId = $env:DCR_SYSLOG_ID }
    "SecurityEvent" = @{ DcrId = $env:DCR_SECURITY_ID }
}

$processingResults = @()

foreach ($event in $eventHubTrigger) {
    $eventType = $event.EventType
    $eventData = $event | ConvertTo-Json -Compress
    
    $result = Send-EventToLogAnalyticsWithResult -EventRecord $eventData -EventType $eventType -DcrMappingTable $dcrMappings
    $processingResults += $result
    
    if (-not $result.Success) {
        # Log to Application Insights or dead letter queue
        Write-Warning "Event processing failed: $($result.ErrorMessage)"
    }
}

# Return summary for Function App monitoring
$summary = @{
    TotalEvents = $processingResults.Count
    SuccessfulEvents = ($processingResults | Where-Object Success).Count
    FailedEvents = ($processingResults | Where-Object { -not $_.Success }).Count
    ProcessingTimestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
}

Write-Information "Processing complete: $($summary | ConvertTo-Json -Compress)"
```

### Monitoring and Alerting

```powershell
# Function for monitoring dashboard integration
function Get-ProcessingHealthMetrics {
    param([array]$Results)
    
    $metrics = @{
        OverallHealthy = $true
        SuccessRate = 0
        ErrorsByType = @{}
        RecommendedActions = @()
    }
    
    if ($Results.Count -eq 0) {
        return $metrics
    }
    
    $successCount = ($Results | Where-Object Success).Count
    $metrics.SuccessRate = [math]::Round(($successCount / $Results.Count) * 100, 2)
    
    # Analyze failed events
    $failedResults = $Results | Where-Object { -not $_.Success }
    foreach ($failure in $failedResults) {
        $errorType = switch -Regex ($failure.ErrorMessage) {
            "Configuration|DcrId" { "ConfigurationIssue" }
            "Environment|CLIENTID" { "EnvironmentIssue" }
            "Authentication|401|403" { "AuthenticationIssue" }
            "RateLimit|429" { "RateLimitIssue" }
            default { "UnknownIssue" }
        }
        
        if (-not $metrics.ErrorsByType.ContainsKey($errorType)) {
            $metrics.ErrorsByType[$errorType] = 0
        }
        $metrics.ErrorsByType[$errorType]++
    }
    
    # Health assessment
    if ($metrics.SuccessRate -lt 95) {
        $metrics.OverallHealthy = $false
        $metrics.RecommendedActions += "Success rate below 95% - investigate errors"
    }
    
    if ($metrics.ErrorsByType.ContainsKey("ConfigurationIssue")) {
        $metrics.RecommendedActions += "Configuration errors detected - verify DCR mappings"
    }
    
    if ($metrics.ErrorsByType.ContainsKey("AuthenticationIssue")) {
        $metrics.RecommendedActions += "Authentication issues - check managed identity permissions"
    }
    
    return $metrics
}
```

## Dependencies

### Same as Send-EventToLogAnalytics

This function has identical dependencies to Send-EventToLogAnalytics since it's a wrapper:

- **UniversalDCR.psm1**: For DCR transmission
- **DCRSchemaLoader.psm1**: For schema validation
- **Azure Resources**: DCE, DCR, Managed Identity, Log Analytics

### Additional Considerations

- **No additional permissions required**
- **No additional environment variables needed**
- **Same performance characteristics with minimal overhead**
