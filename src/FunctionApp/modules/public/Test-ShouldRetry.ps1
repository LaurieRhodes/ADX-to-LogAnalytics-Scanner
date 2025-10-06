function Test-ShouldRetry {
    <#
    .SYNOPSIS
        Determines if an exception represents a retryable error condition
    
    .DESCRIPTION
        Analyzes exception type and content to determine if the operation should be
        retried or if it represents a permanent failure condition.
    
    .PARAMETER Exception
        PowerShell ErrorRecord or .NET Exception object to analyze
        
    .PARAMETER ErrorType
        Classified error type from Get-ErrorType function
    
    .OUTPUTS
        Boolean - True if the error condition is retryable, False otherwise
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Exception,  # Accept both ErrorRecord and Exception
        
        [Parameter(Mandatory = $true)]
        [string]$ErrorType
    )
    
    # Handle PowerShell ErrorRecord vs .NET Exception
    $actualException = if ($Exception -is [System.Management.Automation.ErrorRecord]) {
        $Exception.Exception
    } else {
        $Exception
    }
    
    # Define retryable error types
    $retryableErrors = @(
        "RateLimit",      # 429 - Always retry with backoff
        "ServerError",    # 500 - Temporary server issues
        "BadGateway",     # 502 - Proxy/gateway issues
        "ServiceUnavailable", # 503 - Service temporarily down
        "Timeout",        # 504 - Request timeout
        "Network",        # Network connectivity issues
        "Connection",     # Connection failures
        "DNS"            # DNS resolution failures
    )
    
    # Non-retryable errors (fail fast)
    $nonRetryableErrors = @(
        "Authentication", # 401 - Need new token or permissions
        "Authorization",  # 403 - Insufficient permissions
        "TokenError",     # Token format or validation issues
        "EventHub"       # Event Hub specific errors often need configuration fixes
    )
    
    if ($ErrorType -in $nonRetryableErrors) {
        return $false
    }
    
    if ($ErrorType -in $retryableErrors) {
        return $true
    }
    
    # For Event Hub 401 errors, don't retry as it's likely a permission issue
    if ($actualException.Message -match "401.*eventhub|401.*servicebus") {
        return $false
    }
    
    # For unknown errors, default to retry (conservative approach)
    return $true
}
