param($Timer, $durableClient)

$DebugPreference = "Continue"
$InformationPreference = "Continue"

$executionId = [System.Guid]::NewGuid().ToString()

Write-Information "=========================================="
Write-Information "Timer Trigger Started - ADX Scanner"
Write-Information "Execution ID: $executionId"
Write-Information "Current Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Information "Scheduled Time: $($Timer.ScheduledTime)"
Write-Information "Is Past Due: $($Timer.IsPastDue)"
Write-Information "=========================================="

try {
    # Create mock HTTP object that SupervisorFunction expects
    $timerConfig = @{
        batchSize = 5
        queryInterval = 300
        maxRetries = 3
        healthCheckInterval = 3600
        restartOnError = $true
        queuePollInterval = 5
        maxCycles = 1000
        maxExecutionMinutes = 9.5
        triggeredBy = "TimerTrigger"
        timerExecutionId = $executionId
    }
    
    Write-Information "Timer Configuration:"
    $timerConfig.GetEnumerator() | ForEach-Object {
        Write-Information "  $($_.Key): $($_.Value)"
    }
    
    # Create a mock HTTP request object matching what SupervisorFunction expects
    $mockHttpObj = New-Object PSObject -Property @{
        Method = "POST"
        Body = ($timerConfig | ConvertTo-Json)
        Headers = @{ "Content-Type" = "application/json" }
        Query = @{}
        Params = @{}
    }
    
    Write-Information "Invoking SupervisorFunction directly..."
    
    # Get the path to SupervisorFunction
    $supervisorPath = Join-Path (Split-Path -Parent $PSScriptRoot) "SupervisorFunction\run.ps1"
    
    if (-not (Test-Path $supervisorPath)) {
        throw "SupervisorFunction not found at: $supervisorPath"
    }
    
    Write-Information "SupervisorFunction path: $supervisorPath"
    Write-Information "Calling SupervisorFunction script..."
    
    # Invoke the SupervisorFunction script directly - IMPORTANT: capture and log result
    $result = & $supervisorPath -httpobj $mockHttpObj -durableClient $durableClient
    
    Write-Information "SupervisorFunction call completed"
    Write-Information "Checking result..."
    
    if ($null -eq $result) {
        Write-Warning "SupervisorFunction returned null result"
    } elseif ($result -is [hashtable]) {
        Write-Information "Result is a hashtable with statusCode: $($result.statusCode)"
        
        if ($result.body) {
            $responseBody = if ($result.body -is [string]) { 
                try {
                    $result.body | ConvertFrom-Json 
                } catch {
                    Write-Warning "Could not parse response body as JSON"
                    $result.body
                }
            } else { 
                $result.body 
            }
            
            Write-Information "Response body received:"
            Write-Information ($responseBody | ConvertTo-Json -Depth 2 -Compress)
            
            if ($responseBody.orchestrationInstanceId) {
                Write-Information "✓ Orchestration started successfully"
                Write-Information "  Instance ID: $($responseBody.orchestrationInstanceId)"
                Write-Information "  Supervisor ID: $($responseBody.supervisorId)"
                Write-Information "  Table Count: $($responseBody.tableCount)"
            } elseif ($responseBody.error) {
                Write-Error "✗ SupervisorFunction reported an error: $($responseBody.error.message)"
            }
        }
        
        if ($result.statusCode -eq 200) {
            Write-Information "✓ Timer Trigger completed successfully"
        } else {
            Write-Warning "SupervisorFunction returned non-200 status: $($result.statusCode)"
        }
    } else {
        Write-Warning "Result is of unexpected type: $($result.GetType().FullName)"
        Write-Information "Result value: $result"
    }
    
    Write-Information "Timer Trigger execution finishing normally"
    
} catch {
    Write-Error "CRITICAL ERROR in Timer Trigger execution"
    Write-Error "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Error "Exception Message: $($_.Exception.Message)"
    Write-Error "Execution ID: $executionId"
    
    if ($_.Exception.InnerException) {
        Write-Error "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    
    Write-Error "Stack Trace: $($_.ScriptStackTrace)"
    
    # Log but don't throw - allow retry on next schedule
    Write-Warning "Timer trigger encountered error but will retry on next scheduled run"
}

Write-Information "=========================================="
Write-Information "Timer Trigger execution COMPLETED"
Write-Information "Execution ID: $executionId"
Write-Information "End Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Information "=========================================="
