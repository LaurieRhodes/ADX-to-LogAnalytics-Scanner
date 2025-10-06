# Test-ShouldRetry

## Purpose

Determines if an exception represents a retryable error condition by analyzing exception type and content. This function provides intelligent retry logic for automated error recovery, helping distinguish between transient failures that should be retried and permanent failures that require immediate attention.

## Key Concepts

### Intelligent Error Classification

Analyzes both the exception type and message content to make informed decisions about retry potential, considering factors like HTTP status codes, error categories, and service-specific patterns.

### Fail-Fast for Permanent Errors

Immediately identifies non-retryable error conditions (authentication, authorization, configuration) to prevent unnecessary retry attempts and faster failure feedback.

### Conservative Retry Approach

Defaults to allowing retries for unknown error types while specifically blocking known permanent failure conditions, balancing reliability with efficiency.

## Parameters

| Parameter    | Type                    | Required | Default | Description                                                     |
| ------------ | ----------------------- | -------- | ------- | --------------------------------------------------------------- |
| `Exception`  | ErrorRecord/Exception   | Yes      | -       | PowerShell ErrorRecord or .NET Exception object to analyze     |
| `ErrorType`  | String                  | Yes      | -       | Classified error type from Get-ErrorType function              |

## Return Value

Returns a boolean value:
- `$true` - Error condition is retryable, should attempt retry
- `$false` - Error condition is permanent, should not retry

## Error Classification Categories

### Retryable Error Types

Errors that typically indicate transient issues and should be retried:

```powershell
$retryableErrors = @(
    "RateLimit",        # HTTP 429 - Temporary rate limiting
    "ServerError",      # HTTP 500 - Temporary server issues  
    "BadGateway",       # HTTP 502 - Proxy/gateway issues
    "ServiceUnavailable", # HTTP 503 - Service temporarily down
    "Timeout",          # HTTP 504 - Request timeout
    "Network",          # Network connectivity issues
    "Connection",       # Connection failures
    "DNS"              # DNS resolution failures
)
```

### Non-Retryable Error Types

Errors that indicate permanent failures requiring manual intervention:

```powershell
$nonRetryableErrors = @(
    "Authentication",   # HTTP 401 - Need new token or permissions
    "Authorization",    # HTTP 403 - Insufficient permissions  
    "TokenError",       # Token format or validation issues
    "EventHub"         # Event Hub specific configuration errors
)
```

## Usage Examples

### Standard Retry Logic Implementation

```powershell
# Complete retry workflow with Test-ShouldRetry
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$BaseDelaySeconds = 2,
        [string]$OperationName = "Operation"
    )
    
    $attempt = 0
    
    do {
        $attempt++
        
        try {
            Write-Information "Attempt $attempt/$MaxRetries for $OperationName"
            
            # Execute the operation
            $result = & $ScriptBlock
            
            Write-Information "✅ $OperationName succeeded on attempt $attempt"
            return $result
            
        } catch {
            # Classify the error
            $errorType = Get-ErrorType -Exception $_
            $shouldRetry = Test-ShouldRetry -Exception $_ -ErrorType $errorType
            
            Write-Warning "❌ $OperationName failed on attempt $attempt with $errorType`: $($_.Exception.Message)"
            
            if (-not $shouldRetry) {
                Write-Error "🚫 Non-retryable error detected for $OperationName, aborting retry attempts"
                throw
            }
            
            if ($attempt -ge $MaxRetries) {
                Write-Error "🔥 $OperationName failed after $MaxRetries attempts"
                throw
            }
            
            # Calculate exponential backoff delay
            $delaySeconds = $BaseDelaySeconds * [math]::Pow(2, $attempt - 1)
            Write-Information "⏳ Retrying $OperationName in $delaySeconds seconds..."
            Start-Sleep -Seconds $delaySeconds
        }
        
    } while ($attempt -lt $MaxRetries)
}

# Usage example
$result = Invoke-WithRetry -ScriptBlock {
    # Your operation that might fail
    Invoke-RestMethod -Uri "https://api.example.com/data" -Headers $authHeaders
} -MaxRetries 3 -OperationName "API Call"
```

### DCR Data Ingestion with Intelligent Retry

```powershell
# DCR ingestion with smart retry logic
function Send-EventToDcrWithRetry {
    param(
        [string]$EventData,
        [string]$TableName,
        [string]$DcrId,
        [string]$DceEndpoint,
        [string]$ClientId
    )
    
    $retryPolicy = @{
        MaxRetries = 5
        BaseDelay = 1
        MaxDelay = 30
    }
    
    $attempt = 0
    
    do {
        $attempt++
        
        try {
            # Attempt DCR ingestion
            $result = Send-ToDCR -EventMessage $EventData -TableName $TableName -DcrImmutableId $DcrId -DceEndpoint $DceEndpoint -ClientId $ClientId
            
            if ($result.Success) {
                Write-Information "DCR ingestion succeeded on attempt $attempt"
                return $result
            } else {
                throw "DCR ingestion failed: $($result.Message)"
            }
            
        } catch {
            $errorType = Get-ErrorType -Exception $_
            $shouldRetry = Test-ShouldRetry -Exception $_ -ErrorType $errorType
            
            Write-Warning "DCR ingestion attempt $attempt failed: $errorType - $($_.Exception.Message)"
            
            # Handle specific error types
            switch ($errorType) {
                { $_ -match "HTTP 429" } {
                    Write-Information "Rate limit detected, using extended backoff"
                    $delay = [math]::Min($retryPolicy.BaseDelay * [math]::Pow(3, $attempt), $retryPolicy.MaxDelay)
                }
                { $_ -match "Network|Connection" } {
                    Write-Information "Network issue detected, using standard backoff"
                    $delay = [math]::Min($retryPolicy.BaseDelay * [math]::Pow(2, $attempt), $retryPolicy.MaxDelay)
                }
                { $_ -match "Authentication|Authorization" } {
                    Write-Error "Authentication/Authorization error - aborting retry"
                    throw
                }
                default {
                    if ($shouldRetry) {
                        $delay = [math]::Min($retryPolicy.BaseDelay * [math]::Pow(2, $attempt), $retryPolicy.MaxDelay)
                    } else {
                        Write-Error "Non-retryable error detected - aborting"
                        throw
                    }
                }
            }
            
            if ($attempt -ge $retryPolicy.MaxRetries) {
                Write-Error "DCR ingestion failed after $($retryPolicy.MaxRetries) attempts"
                throw
            }
            
            Write-Information "Retrying DCR ingestion in $delay seconds..."
            Start-Sleep -Seconds $delay
        }
        
    } while ($attempt -lt $retryPolicy.MaxRetries)
}
```

### Batch Processing with Selective Retry

```powershell
# Process multiple events with individual retry decisions
function Process-EventBatchWithSelectiveRetry {
    param(
        [array]$Events,
        [hashtable]$DcrConfig
    )
    
    $results = @{
        TotalEvents = $Events.Count
        Successful = 0
        Failed = 0
        Retried = 0
        NonRetryable = 0
        Details = @()
    }
    
    foreach ($event in $Events) {
        $eventResult = @{
            EventId = $event.Id
            Status = "Unknown"
            Attempts = 0
            FinalError = $null
        }
        
        $maxAttempts = 3
        $attempt = 0
        $success = $false
        
        do {
            $attempt++
            $eventResult.Attempts = $attempt
            
            try {
                # Attempt to process the event
                Send-EventToLogAnalytics -EventRecord ($event | ConvertTo-Json) -EventType $event.Type -DcrMappingTable $DcrConfig
                
                $success = $true
                $eventResult.Status = "Success"
                $results.Successful++
                
                if ($attempt -gt 1) {
                    $results.Retried++
                    Write-Information "Event $($event.Id) succeeded after $attempt attempts"
                }
                
                break
                
            } catch {
                $errorType = Get-ErrorType -Exception $_
                $shouldRetry = Test-ShouldRetry -Exception $_ -ErrorType $errorType
                
                Write-Debug "Event $($event.Id) attempt $attempt failed: $errorType"
                
                if (-not $shouldRetry) {
                    $eventResult.Status = "NonRetryableFailure"
                    $eventResult.FinalError = $_.Exception.Message
                    $results.NonRetryable++
                    Write-Warning "Event $($event.Id) failed with non-retryable error: $errorType"
                    break
                }
                
                if ($attempt -ge $maxAttempts) {
                    $eventResult.Status = "RetryExhausted"
                    $eventResult.FinalError = $_.Exception.Message
                    $results.Failed++
                    Write-Warning "Event $($event.Id) failed after $maxAttempts attempts"
                    break
                }
                
                # Wait before retry
                $delay = 2 * [math]::Pow(2, $attempt - 1)
                Start-Sleep -Seconds $delay
            }
            
        } while ($attempt -lt $maxAttempts)
        
        $results.Details += $eventResult
    }
    
    # Generate summary
    Write-Host "=== BATCH PROCESSING SUMMARY ==="
    Write-Host "Total Events: $($results.TotalEvents)"
    Write-Host "Successful: $($results.Successful)"
    Write-Host "Failed (Retries Exhausted): $($results.Failed)"
    Write-Host "Failed (Non-Retryable): $($results.NonRetryable)"
    Write-Host "Required Retry: $($results.Retried)"
    
    return $results
}
```

## Error-Specific Retry Logic

### Special Handling for Event Hub Errors

The function includes special logic for Event Hub authentication errors:

```powershell
# Event Hub 401 errors are typically permission issues
if ($actualException.Message -match "401.*eventhub|401.*servicebus") {
    return $false  # Don't retry - likely permission configuration issue
}
```

### Rate Limiting Considerations

```powershell
# Example of rate limit aware retry
function Test-ShouldRetryWithRateLimit {
    param($Exception, $ErrorType, [int]$AttemptNumber)
    
    $baseRetryDecision = Test-ShouldRetry -Exception $Exception -ErrorType $ErrorType
    
    if ($ErrorType -match "RateLimit|HTTP 429") {
        # For rate limits, increase retry willingness but with backoff
        if ($AttemptNumber -le 5) {
            return $true
        } else {
            Write-Warning "Rate limit retry attempts exhausted"
            return $false
        }
    }
    
    return $baseRetryDecision
}
```

## Integration Patterns

### Azure Function Error Handling

```powershell
# Azure Function with comprehensive error handling
param($eventHubTrigger, $TriggerMetadata)

foreach ($event in $eventHubTrigger) {
    try {
        $success = $false
        $attempt = 0
        $maxAttempts = 3
        
        do {
            $attempt++
            
            try {
                # Process the event
                $result = Process-Event -Event $event
                $success = $true
                
            } catch {
                $errorType = Get-ErrorType -Exception $_
                $shouldRetry = Test-ShouldRetry -Exception $_ -ErrorType $errorType
                
                if ($shouldRetry -and $attempt -lt $maxAttempts) {
                    Write-Warning "Event processing failed (attempt $attempt), retrying: $($_.Exception.Message)"
                    Start-Sleep -Seconds (2 * $attempt)
                } else {
                    # Send to dead letter queue or log for manual review
                    Write-Error "Event processing failed permanently: $($_.Exception.Message)"
                    Send-ToDeadLetterQueue -Event $event -Error $_.Exception.Message -ErrorType $errorType
                    break
                }
            }
            
        } while (-not $success -and $attempt -lt $maxAttempts)
        
    } catch {
        Write-Error "Critical error processing event: $($_.Exception.Message)"
    }
}
```

## Dependencies

### Required Functions

- **Get-ErrorType**: For classifying exception types before retry decisions
- **Get-HttpStatusCode**: Used internally by Get-ErrorType for HTTP error classification

### Error Type Classifications

This function works in conjunction with Get-ErrorType to provide comprehensive error analysis:

```powershell
# Example error type classifications that influence retry decisions
$errorClassifications = @{
    "WebException (HTTP 429)" = $true    # Retryable - rate limit
    "WebException (HTTP 401)" = $false   # Non-retryable - authentication
    "WebException (HTTP 403)" = $false   # Non-retryable - authorization
    "WebException (HTTP 500)" = $true    # Retryable - server error
    "NetworkException" = $true           # Retryable - network issue
    "TimeoutException" = $true           # Retryable - timeout
    "TokenError" = $false               # Non-retryable - token issue
}
```

## Performance Considerations

### Retry Decision Speed

- **Decision time**: < 5ms for standard error analysis
- **Memory usage**: Minimal - only analyzes existing exception objects
- **CPU overhead**: Low - simple string matching and categorization

### Optimization Tips

```powershell
# Cache retry decisions for identical error patterns
$retryDecisionCache = @{}

function Test-ShouldRetryCached {
    param($Exception, $ErrorType)
    
    $cacheKey = "$ErrorType-$($Exception.GetType().Name)"
    
    if ($retryDecisionCache.ContainsKey($cacheKey)) {
        return $retryDecisionCache[$cacheKey]
    }
    
    $decision = Test-ShouldRetry -Exception $Exception -ErrorType $ErrorType
    $retryDecisionCache[$cacheKey] = $decision
    
    return $decision
}
```
