param($Timer, $durableClient)

# Enhanced logging and diagnostics
$DebugPreference = "Continue"
$InformationPreference = "Continue"
$VerbosePreference = "Continue"

# Generate execution ID for tracking
$executionId = [System.Guid]::NewGuid().ToString()

Write-Host "=========================================="
Write-Host "Timer Trigger Started - ADX Query Manager"
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "Execution Policy: $(Get-ExecutionPolicy)"
Write-Host "Execution ID: $executionId"
Write-Host "Current Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"

# Validate Timer object
if ($null -eq $Timer) {
    Write-Error "CRITICAL: Timer parameter is null - binding configuration problem"
    throw "Timer binding failed - check function.json configuration"
}

Write-Host "Timer Object Type: $($Timer.GetType().FullName)"

# Safe property access with null checking
$scheduledTime = if ($Timer.PSObject.Properties['ScheduledTime']) { $Timer.ScheduledTime } else { "Not Available" }
$isPastDue = if ($Timer.PSObject.Properties['IsPastDue']) { $Timer.IsPastDue } else { "Not Available" }

Write-Host "Scheduled Time: $scheduledTime"
Write-Host "Is Past Due: $isPastDue"
Write-Host "Mode: ADX Continuous Query Manager"
Write-Host "=========================================="

try {
    # Validate durable client
    if ($null -eq $durableClient) {
        Write-Error "CRITICAL: DurableClient parameter is null - binding configuration problem"
        throw "DurableClient binding failed - check function.json configuration"
    }

    Write-Host "DurableClient validated successfully"
    Write-Host "Task Hub Name: $($durableClient.taskHubName)"
    Write-Host "Calling SupervisorFunction via timer trigger..."
    
    # Create default configuration for timer-triggered starts
    $timerConfig = @{
        batchSize = 3
        queryInterval = 300  # 5 minutes
        maxRetries = 5
        healthCheckInterval = 1800  # 30 minutes
        restartOnError = $true
    }
    
    # Create mock HTTP object for SupervisorFunction
    $supervisorHttpObj = @{
        Method = "POST"
        Body = ($timerConfig | ConvertTo-Json)
    }
    
    Write-Host "Timer Configuration:"
    Write-Host "  Batch Size: $($timerConfig.batchSize)"
    Write-Host "  Query Interval: $($timerConfig.queryInterval) seconds"
    Write-Host "  Max Retries: $($timerConfig.maxRetries)"
    Write-Host "  Health Check Interval: $($timerConfig.healthCheckInterval) seconds"
    
    try {
        Write-Host "Calling SupervisorFunction directly from timer..."
        
        # Call the SupervisorFunction directly (standard function call)
        $supervisorResult = & "$PSScriptRoot\..\SupervisorFunction\run.ps1" -httpobj $supervisorHttpObj -durableClient $durableClient
        
        Write-Host "SupervisorFunction completed from timer trigger"
        
        if ($supervisorResult.statusCode -eq 200) {
            $responseBody = $supervisorResult.body | ConvertFrom-Json
            Write-Host "Eternal Orchestration Instance ID: $($responseBody.eternalInstanceId)"
            Write-Host "Status Query URI: $($responseBody.statusQueryUri)"
        } else {
            Write-Warning "SupervisorFunction returned status code: $($supervisorResult.statusCode)"
        }
        
    } catch {
        Write-Error "SupervisorFunction call failed: $($_.Exception.Message)"
        throw "Failed to start ADX query supervisor via timer: $($_.Exception.Message)"
    }
    
    if ($scheduledTime -ne "Not Available") {
        Write-Host "Next scheduled run: $(([DateTime]$scheduledTime).AddDays(1))"
    }
    
    Write-Host "Timer Trigger completed successfully - ADX query system started"
        
} catch {
    Write-Error "CRITICAL ERROR in Timer Trigger execution"
    Write-Error "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Error "Exception Message: $($_.Exception.Message)"
    Write-Error "Execution ID: $executionId"
    
    if ($_.Exception.InnerException) {
        Write-Error "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    
    Write-Error "Stack Trace: $($_.ScriptStackTrace)"
    
    # Re-throw to ensure function shows as failed in Azure monitoring
    throw $_
}

Write-Host "Timer Trigger Function execution completed - Execution ID: $executionId"