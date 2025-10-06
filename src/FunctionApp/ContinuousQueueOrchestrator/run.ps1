param($context)

# Durable Functions cmdlets (Invoke-DurableActivity, etc.) are automatically available
# when using Extension Bundle v3 - no explicit import needed

try {
    # Get and validate input in single flow
    $rawInput = $context.get_input()
    Write-Debug "DEBUG: Raw input received (length: $($rawInput.Length))"
    
    $DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($rawInput))
    Write-Debug "DEBUG: Base64 decode successful (length: $($DecodedText.Length))"
    
    $params = ConvertFrom-Json -InputObject $DecodedText
    Write-Debug "DEBUG: JSON parse successful"
    
    # Extract required parameters with validation
    $instanceId = $context.get_instanceid()
    $supervisorId = $params.SupervisorId
    $queueTableName = $params.QueueTableName
    $storageAccountName = $params.StorageAccountName
    $storageAccountKey = $params.StorageAccountKey
    $queuePollInterval = if ($params.QueuePollInterval) { $params.QueuePollInterval } else { 5 }
    $maxCycles = if ($params.MaxCycles) { $params.MaxCycles } else { 1000 }
    
    # OPTIMIZED: Time boundary calculation using Durable Functions context
    $orchestratorStartTime = $context.get_currentutcdatetime()
    $blockEndTime = [DateTime]::Parse($params.BlockEndTime).ToUniversalTime()
    $maxExecutionMinutes = if ($params.MaxExecutionTime) { $params.MaxExecutionTime } else { 9.5 }
    
    # OPTIMIZED: Calculate ABSOLUTE maximum execution time from orchestrator start
    $absoluteMaxEndTime = $orchestratorStartTime.AddMinutes($maxExecutionMinutes)
    $effectiveEndTime = if ($blockEndTime -lt $absoluteMaxEndTime) { $blockEndTime } else { $absoluteMaxEndTime }
    
    # OPTIMIZED: Reduced safety buffer (15 seconds) for near real-time processing
    $safetyBufferSeconds = 15  # REDUCED from 30 seconds for maximum processing time
    $gracefulExitTime = $effectiveEndTime.AddSeconds(-$safetyBufferSeconds)
    
    # Check if optimized for near real-time
    $optimizedForNearRealTime = if ($params.TimeBoundarySettings -and $params.TimeBoundarySettings.OptimizedForNearRealTime) { 
        $params.TimeBoundarySettings.OptimizedForNearRealTime 
    } else { 
        $false 
    }
    
    # Validate required parameters exist
    if (-not $queueTableName) { throw "Missing QueueTableName parameter" }
    if (-not $storageAccountName) { throw "Missing StorageAccountName parameter" }
    if (-not $storageAccountKey) { throw "Missing StorageAccountKey parameter" }
    
    Write-Information "[$instanceId] ContinuousQueueOrchestrator started - Queue: $queueTableName"
    Write-Information "[$instanceId] OPTIMIZED for Near Real-Time: $optimizedForNearRealTime"
    Write-Debug "[$instanceId] Orchestrator Start Time: $($orchestratorStartTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Debug "[$instanceId] Block End Time: $($blockEndTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Debug "[$instanceId] Absolute Max End Time: $($absoluteMaxEndTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Debug "[$instanceId] Effective End Time: $($effectiveEndTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Debug "[$instanceId] Graceful Exit Time: $($gracefulExitTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Debug "[$instanceId] Safety Buffer: $safetyBufferSeconds seconds (OPTIMIZED)"
    Write-Debug "[$instanceId] Max Execution Minutes: $maxExecutionMinutes (OPTIMIZED)"
    Write-Debug "[$instanceId] Poll interval: $queuePollInterval seconds, Max cycles: $maxCycles"
    
    # Initialize tracking
    $cycleCount = 0
    $totalRecordsProcessed = 0
    $successfulProcesses = 0
    $failedProcesses = 0
    $gracefulExit = $false
    $exitReason = "Unknown"
    $consecutiveNoTablesCount = 0
    $maxConsecutiveNoTables = if ($optimizedForNearRealTime) { 2 } else { 3 }  # OPTIMIZED: Reduced for faster cycling
    
    # OPTIMIZED: Calculate processing efficiency targets
    $totalAvailableTime = ($gracefulExitTime - $orchestratorStartTime).TotalMinutes
    $estimatedCyclesPerMinute = if ($optimizedForNearRealTime) { 12 } else { 6 }  # OPTIMIZED: Faster cycling
    $targetCycles = [Math]::Max(1, [Math]::Floor($totalAvailableTime * $estimatedCyclesPerMinute))
    
    Write-Information "[$instanceId] OPTIMIZED Processing Targets:"
    Write-Information "[$instanceId]   Total Available Time: $([Math]::Round($totalAvailableTime, 2)) minutes"
    Write-Information "[$instanceId]   Target Cycles: $targetCycles"
    Write-Information "[$instanceId]   Max Consecutive No Tables: $maxConsecutiveNoTables"
    Write-Information "[$instanceId]   Estimated Cycles/Minute: $estimatedCyclesPerMinute"
    
    # Main processing loop with OPTIMIZED time boundary logic for near real-time
    while ($true) {
        # OPTIMIZED: Use deterministic Durable Functions time instead of wall clock
        $currentOrchestrationTime = $context.get_currentutcdatetime()
        
        # OPTIMIZED: Multiple hard stop conditions with near real-time priority
        if ($currentOrchestrationTime -ge $gracefulExitTime) {
            $timeRemaining = ($effectiveEndTime - $currentOrchestrationTime).TotalSeconds
            Write-Information "[$instanceId] GRACEFUL EXIT: Time boundary reached (Remaining: $([Math]::Round($timeRemaining, 1))s)"
            $gracefulExit = $true
            $exitReason = "TimeBoundaryReached"
            break
        }
        
        # Safety check - absolute maximum execution time
        if ($currentOrchestrationTime -ge $absoluteMaxEndTime) {
            Write-Debug "[$instanceId] HARD STOP: Absolute maximum execution time reached"
            $exitReason = "AbsoluteTimeLimit"
            break
        }
        
        # OPTIMIZED: Dynamic cycle limit based on processing efficiency
        $effectiveMaxCycles = if ($optimizedForNearRealTime) { [Math]::Min($maxCycles, $targetCycles * 2) } else { $maxCycles }
        if ($cycleCount -ge $effectiveMaxCycles) {
            Write-Debug "[$instanceId] HARD STOP: Maximum cycles reached ($effectiveMaxCycles)"
            $exitReason = "CycleLimitReached"
            break
        }
        
        # OPTIMIZED: Reduced consecutive no tables threshold for faster response
        if ($consecutiveNoTablesCount -ge $maxConsecutiveNoTables) {
            Write-Debug "[$instanceId] GRACEFUL EXIT: No tables available for $maxConsecutiveNoTables consecutive cycles"
            $gracefulExit = $true
            $exitReason = "NoTablesAvailable"
            break
        }
        
        # Calculate remaining time for logging and decisions
        $timeRemainingMinutes = ($gracefulExitTime - $currentOrchestrationTime).TotalMinutes
        $processingEfficiency = if ($cycleCount -gt 0 -and $totalAvailableTime -gt 0) { 
            [Math]::Round(($cycleCount / ($totalAvailableTime - $timeRemainingMinutes)) * 100, 1) 
        } else { 
            0 
        }
        
        Write-Debug "[$instanceId] Cycle $cycleCount (Time remaining: $([Math]::Round($timeRemainingMinutes, 2)) min, Efficiency: $processingEfficiency%)"
        
        # OPTIMIZED: Enhanced queue management for near real-time processing
        $queueCheckInput = @{
            QueueTableName = $queueTableName
            StorageAccountName = $storageAccountName
            StorageAccountKey = $storageAccountKey
            SupervisorId = $supervisorId
            InstanceId = $instanceId
            OperationType = "GetNextAvailable"
            OptimizedForNearRealTime = $optimizedForNearRealTime
            CycleNumber = $cycleCount
        }
        
        $encodedQueueInput = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $queueCheckInput -Depth 10)))
        $nextTableResult = Invoke-DurableActivity -FunctionName "QueueManagerActivity" -Input $encodedQueueInput
        
        # Process queue manager result with optimized handling
        if (-not $nextTableResult -or -not $nextTableResult.Success) {
            if ($nextTableResult -and $nextTableResult.Reason -eq "NoAvailableTables") {
                $consecutiveNoTablesCount++
                Write-Debug "[$instanceId] No tables currently available (consecutive count: $consecutiveNoTablesCount/$maxConsecutiveNoTables)"
                
                # OPTIMIZED: Check time boundary before any delay
                $currentTimeBeforeDelay = $context.get_currentutcdatetime()
                $timeUntilExit = ($gracefulExitTime - $currentTimeBeforeDelay).TotalSeconds
                
                # OPTIMIZED: Reduced minimum time threshold for faster cycling
                $minimumTimeForNextCycle = if ($optimizedForNearRealTime) { 2 } else { $queuePollInterval }
                
                if ($timeUntilExit -le $minimumTimeForNextCycle) {
                    Write-Debug "[$instanceId] Not enough time for another cycle - exiting gracefully"
                    $gracefulExit = $true
                    $exitReason = "InsufficientTimeForNextCycle"
                    break
                }
                
                # OPTIMIZED: Continue immediately for near real-time processing
                Write-Debug "[$instanceId] Will retry on next cycle (optimized for near real-time)"
                
                $cycleCount++
                continue
            } else {
                Write-Error "[$instanceId] Queue manager error: $($nextTableResult.Message)"
                $failedProcesses++
                $exitReason = "QueueManagerError"
                break
            }
        }
        
        # Reset consecutive no tables counter since we found a table
        $consecutiveNoTablesCount = 0
        
        # Extract table information
        $tableToProcess = $nextTableResult.TableName
        $tableConfig = $nextTableResult.TableConfig
        
        Write-Information "[$instanceId] Processing table: $tableToProcess (Cycle: $cycleCount, Efficiency: $processingEfficiency%)"
        
        # OPTIMIZED: Calculate remaining time for activity execution with near real-time priority
        $currentTimeBeforeActivity = $context.get_currentutcdatetime()
        $remainingTimeMinutes = ($gracefulExitTime - $currentTimeBeforeActivity).TotalMinutes
        
        # OPTIMIZED: More aggressive time allocation for activities
        $activityMaxTime = if ($optimizedForNearRealTime) {
            [Math]::Min(8, [Math]::Max(0.5, $remainingTimeMinutes - 0.25))  # OPTIMIZED: 15s buffer, up to 8 minutes
        } else {
            [Math]::Min(5, [Math]::Max(1, $remainingTimeMinutes - 0.5))    # Standard: 30s buffer, up to 5 minutes
        }
        
        # Process the table with optimized parameters
        $activityInput = @{
            TableName = $tableToProcess
            TableConfig = $tableConfig
            SupervisorId = $supervisorId
            BlockEndTime = $gracefulExitTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
            CycleNumber = $cycleCount
            QueueMode = $true
            MaxExecutionTime = $activityMaxTime
            OptimizedForNearRealTime = $optimizedForNearRealTime
            ProcessingEfficiency = $processingEfficiency
            
            # Queue management parameters for self-updating
            QueueTableName = $queueTableName
            QueueStorageAccountName = $storageAccountName
            QueueStorageAccountKey = $storageAccountKey
        }
        
        $encodedActivityInput = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $activityInput -Depth 10)))
        
        try {
            $processResult = Invoke-DurableActivity -FunctionName "ADXQueryActivity" -Input $encodedActivityInput
            
            # Track results with enhanced metrics for near real-time processing
            if ($processResult -and $processResult.Success) {
                $successfulProcesses++
                if ($processResult.RecordsProcessed) {
                    $totalRecordsProcessed += $processResult.RecordsProcessed
                }
                
                # OPTIMIZED: Enhanced logging for near real-time monitoring
                $recordsPerSecond = if ($processResult.ProcessingTimeSeconds -and $processResult.ProcessingTimeSeconds -gt 0) {
                    [Math]::Round($processResult.RecordsProcessed / $processResult.ProcessingTimeSeconds, 2)
                } else {
                    0
                }
                
                Write-Information "[$instanceId] ✓ $tableToProcess : $($processResult.RecordsProcessed) records ($recordsPerSecond rec/s)"
            } else {
                $failedProcesses++
                Write-Warning "[$instanceId] ✗ $tableToProcess : Processing failed"
            }
            
            # CRITICAL FIX: Update queue status after processing completes
            # This resets the table back to "Available" for continuous processing
            Write-Debug "[$instanceId] Updating queue status for $tableToProcess"
            $statusUpdateInput = @{
                QueueTableName = $queueTableName
                StorageAccountName = $storageAccountName
                StorageAccountKey = $storageAccountKey
                TableName = $tableToProcess
                ProcessingResult = $processResult
                InstanceId = $instanceId
                OperationType = "UpdateStatus"
                OptimizedForNearRealTime = $optimizedForNearRealTime
            }
            $encodedStatusInput = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $statusUpdateInput -Depth 10)))
            
            try {
                $statusUpdateResult = Invoke-DurableActivity -FunctionName "QueueManagerActivity" -Input $encodedStatusInput
                if ($statusUpdateResult -and $statusUpdateResult.Success) {
                    Write-Debug "[$instanceId] Queue status updated: $tableToProcess -> $($statusUpdateResult.NewStatus)"
                } else {
                    Write-Warning "[$instanceId] Failed to update queue status for $tableToProcess"
                }
            } catch {
                Write-Warning "[$instanceId] Exception updating queue status for $tableToProcess`: $($_.Exception.Message)"
            }
            
        } catch {
            Write-Error "[$instanceId] Activity execution failed for table $tableToProcess`: $($_.Exception.Message)"
            $failedProcesses++
            
            # Update queue status to Error for failed activity
            $errorQueueInput = @{
                QueueTableName = $queueTableName
                StorageAccountName = $storageAccountName
                StorageAccountKey = $storageAccountKey
                TableName = $tableToProcess
                ProcessingResult = @{
                    Success = $false
                    Status = "Error"
                    Message = $_.Exception.Message
                }
                InstanceId = $instanceId
                OperationType = "UpdateStatus"
                OptimizedForNearRealTime = $optimizedForNearRealTime
            }
            $encodedErrorInput = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $errorQueueInput -Depth 10)))
            try {
                Invoke-DurableActivity -FunctionName "QueueManagerActivity" -Input $encodedErrorInput
                Write-Debug "[$instanceId] Set $tableToProcess status to Error after activity failure"
            } catch {
                Write-Warning "[$instanceId] Failed to update queue status to Error for $tableToProcess"
            }
        }
        
        $cycleCount++
        
        # OPTIMIZED: Final time check before next iteration with enhanced decision making
        $currentTimeAfterActivity = $context.get_currentutcdatetime()
        if ($currentTimeAfterActivity -ge $gracefulExitTime) {
            Write-Information "[$instanceId] Time boundary reached after processing - exiting gracefully"
            $gracefulExit = $true
            $exitReason = "TimeBoundaryReachedAfterProcessing"
            break
        }
        
        # OPTIMIZED: Continue immediately for maximum processing throughput
        $remainingSeconds = ($gracefulExitTime - $currentTimeAfterActivity).TotalSeconds
        Write-Debug "[$instanceId] Cycle $cycleCount completed, $([Math]::Round($remainingSeconds, 1))s remaining"
    }
    
    # Calculate final execution metrics
    $finalTime = $context.get_currentutcdatetime()
    $totalExecutionMinutes = ($finalTime - $orchestratorStartTime).TotalMinutes
    $actualProcessingTime = $totalAvailableTime - ($gracefulExitTime - $finalTime).TotalMinutes
    $timeUtilization = if ($totalAvailableTime -gt 0) { [Math]::Round(($actualProcessingTime / $totalAvailableTime) * 100, 1) } else { 0 }
    $averageRecordsPerMinute = if ($totalExecutionMinutes -gt 0) { [Math]::Round($totalRecordsProcessed / $totalExecutionMinutes, 1) } else { 0 }
    
    # Return comprehensive results with near real-time metrics
    return @{
        Success = $gracefulExit
        InstanceId = $instanceId
        SupervisorId = $supervisorId
        EndTime = $finalTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
        ProcessingMode = if ($optimizedForNearRealTime) { "QueueManaged-NearRealTime" } else { "QueueManaged" }
        TotalCycles = $cycleCount
        SuccessfulProcesses = $successfulProcesses
        FailedProcesses = $failedProcesses
        TotalRecordsProcessed = $totalRecordsProcessed
        AverageRecordsPerCycle = if ($cycleCount -gt 0) { [Math]::Round($totalRecordsProcessed / $cycleCount, 2) } else { 0 }
        AverageRecordsPerMinute = $averageRecordsPerMinute
        Status = if ($gracefulExit) { "CompletedGracefully" } else { "CompletedWithLimits" }
        ExitReason = $exitReason
        TotalExecutionMinutes = [Math]::Round($totalExecutionMinutes, 2)
        ConsecutiveNoTablesCount = $consecutiveNoTablesCount
        
        # OPTIMIZED: Enhanced metrics for near real-time processing
        OptimizationMetrics = @{
            OptimizedForNearRealTime = $optimizedForNearRealTime
            TimeUtilization = $timeUtilization
            TargetCycles = $targetCycles
            ActualCycles = $cycleCount
            CycleEfficiency = if ($targetCycles -gt 0) { [Math]::Round(($cycleCount / $targetCycles) * 100, 1) } else { 0 }
            SafetyBufferSeconds = $safetyBufferSeconds
            MaxExecutionMinutes = $maxExecutionMinutes
            ActualProcessingTime = [Math]::Round($actualProcessingTime, 2)
            EstimatedCyclesPerMinute = $estimatedCyclesPerMinute
            ActualCyclesPerMinute = if ($totalExecutionMinutes -gt 0) { [Math]::Round($cycleCount / $totalExecutionMinutes, 1) } else { 0 }
        }
        
        TimeBoundaries = @{
            OrchestratorStart = $orchestratorStartTime.ToString('yyyy-MM-ddTHH:mm:ss')
            BlockEndTime = $blockEndTime.ToString('yyyy-MM-ddTHH:mm:ss')
            AbsoluteMaxEndTime = $absoluteMaxEndTime.ToString('yyyy-MM-ddTHH:mm:ss')
            EffectiveEndTime = $effectiveEndTime.ToString('yyyy-MM-ddTHH:mm:ss')
            GracefulExitTime = $gracefulExitTime.ToString('yyyy-MM-ddTHH:mm:ss')
            ActualEndTime = $finalTime.ToString('yyyy-MM-ddTHH:mm:ss')
        }
        ArchitectureVersion = "Optimized for Near Real-Time Processing v2.3 - Continuous Cycling"
    }
    
} catch {
    Write-Information "ORCHESTRATOR ERROR: $($_.Exception.Message) at line $($_.InvocationInfo.ScriptLineNumber)"
    
    return @{
        Success = $false
        InstanceId = if ($instanceId) { $instanceId } else { "Unknown" }
        Status = "Failed"
        EndTime = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
        Error = @{
            Message = $_.Exception.Message
            Type = $_.Exception.GetType().Name
            LineNumber = $_.InvocationInfo.ScriptLineNumber
        }
        ProcessingMode = "QueueManaged-Error"
        OptimizedForNearRealTime = if ($optimizedForNearRealTime) { $optimizedForNearRealTime } else { $false }
        ArchitectureVersion = "Optimized for Near Real-Time Processing v2.3 - Error State"
    }
}
