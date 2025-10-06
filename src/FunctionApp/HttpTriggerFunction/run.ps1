param($httpobj, $durableClient)

# Set up logging preferences
$DebugPreference = "Continue"
$InformationPreference = "Continue"

# Initialize HTTP execution context
$requestId = [System.Guid]::NewGuid().ToString()
Write-Information "=============================================="
Write-Information "HTTP Trigger Function Started - ADX Query Manager"
Write-Information "Request ID: $requestId"
Write-Information "Method: $($httpobj.Method)"
Write-Information "Current Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Information "=============================================="

try {
    # Validate HTTP method
    if ($httpobj.Method -notin @('GET', 'POST')) {
        Write-Warning "Unsupported HTTP method: $($httpobj.Method)"
        
        return @{
            statusCode = 405
            headers = @{
                'Content-Type' = 'application/json'
            }
            body = @{
                error = "Method Not Allowed"
                message = "Only GET and POST methods are supported"
                requestId = $requestId
            } | ConvertTo-Json
        }
    }

    # For GET requests, return status information
    if ($httpobj.Method -eq 'GET') {
        Write-Information "GET request - checking ADX query system status"
        
        $statusInfo = @{
            status = "ready"
            message = "ADX Query Manager is operational"
            requestId = $requestId
            functionVersion = "4.0-ADXQuery"
            timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            mode = "ADXContinuousQuery"
            architecture = "Eternal Orchestrator Pattern"
            capabilities = @{
                continuousQuerySupport = $true
                eternalOrchestrationSupport = $true
                supervisorPattern = $true
                batchProcessing = $true
            }
            taskHubName = $durableClient.taskHubName
            note = "Use POST to start continuous ADX query orchestration"
        }
        
        return @{
            statusCode = 200
            headers = @{
                'Content-Type' = 'application/json'
            }
            body = ($statusInfo | ConvertTo-Json -Depth 3)
        }
    }
    
    # For POST requests, call SupervisorFunction directly (not as orchestration)
    Write-Information "POST request - calling SupervisorFunction directly"
    
    try {
        # Create a mock HTTP request object for the SupervisorFunction
        $supervisorHttpObj = @{
            Method = "POST"
            Body = $httpobj.Body
        }
        
        Write-Information "Calling SupervisorFunction directly with HTTP request data"
        
        # Call the SupervisorFunction directly (standard function call)
        $supervisorResult = & "$PSScriptRoot\..\SupervisorFunction\run.ps1" -httpobj $supervisorHttpObj -durableClient $durableClient
        
        Write-Information "SupervisorFunction completed - returning result"
        
        # Return the supervisor's response directly
        return $supervisorResult
        
    } catch {
        Write-Error "Failed to call SupervisorFunction: $($_.Exception.Message)"
        throw "SupervisorFunction call failed: $($_.Exception.Message)"
    }
    
} catch {
    Write-Error "Critical error in HTTP Trigger execution: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    
    return @{
        statusCode = 500
        headers = @{
            'Content-Type' = 'application/json'
        }
        body = @{
            status = "critical_error"
            message = "HTTP Trigger encountered an error"
            requestId = $requestId
            error = @{
                message = $_.Exception.Message
                type = $_.Exception.GetType().Name
                timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
                stackTrace = $_.ScriptStackTrace
            }
            troubleshooting = @{
                requestId = $requestId
                recommendation = "Check Function App logs for detailed investigation"
            }
        } | ConvertTo-Json -Depth 3
    }
}