# ADXQueryActivity - Optimized logging for production cost management
# DEBUG: Detailed diagnostics, troubleshooting info
# INFORMATION: Key operational metrics only
# WARNING: Issues that need attention

param($inputobject)

$instanceId = [System.Guid]::NewGuid().ToString().Substring(0, 8)
$InformationPreference = "Continue"
$DebugPreference = "Continue"

Write-Debug "[$instanceId] ADXQueryActivity started"

try {
    # =============================================================================
    # LAZY MODULE LOADING
    # =============================================================================
    
    $scriptDirectory = Split-Path -Parent $PsScriptRoot
    $modulesPath = Join-Path $scriptDirectory 'modules'
    $resolvedModulesPath = (Get-Item $modulesPath).FullName
    
    Write-Debug "[$instanceId] Loading functionApp module from: $resolvedModulesPath"
    Import-Module "$resolvedModulesPath\functionApp.psm1" -Force -Global
    Write-Debug "[$instanceId] Module loaded successfully"
    
    # =============================================================================
    # INPUT PROCESSING
    # =============================================================================
    
    $DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($inputobject))
    $params = ConvertFrom-Json -InputObject $DecodedText
    
    $tableName = $params.TableName
    $dcrId = $params.TableConfig.DcrId
    $blockEndTimeZulu = if ($params.BlockEndTime) { $params.BlockEndTime } else { (Get-Date).AddMinutes(10).ToString('yyyy-MM-ddTHH:mm:ssZ') }
    $supervisorId = if ($params.SupervisorId) { $params.SupervisorId } else { "Unknown" }
    $queueMode = if ($params.QueueMode) { $params.QueueMode } else { $false }
    $cycleNumber = if ($params.CycleNumber) { $params.CycleNumber } else { 1 }
    
    $logPrefix = if ($queueMode) { "[$instanceId][$tableName][Cycle-$cycleNumber]" } else { "[$instanceId][$tableName]" }
    
    Write-Debug "$logPrefix Processing started"
    
    # =============================================================================
    # TIME BOUNDARY CHECK
    # =============================================================================
    
    $currentTimeZulu = [DateTime]::UtcNow
    $blockEndTime = [DateTime]::Parse($blockEndTimeZulu).ToUniversalTime()
    
    if ($currentTimeZulu -ge $blockEndTime) {
        Write-Debug "$logPrefix Block time exceeded - skipping"
        return @{
            Success = $true
            TableName = $tableName
            Status = "BlockTimeExceeded"
            Message = "Block end time exceeded"
            RecordsProcessed = 0
            InstanceId = $instanceId
        }
    }
    
    # =============================================================================
    # OUTPUT DESTINATION
    # =============================================================================
    
    $isEventHubConfigured = (-not [string]::IsNullOrWhiteSpace($env:EVENTHUBNAMESPACE)) -and (-not [string]::IsNullOrWhiteSpace($env:EVENTHUBNAME))
    $outputDestination = if ($isEventHubConfigured) { "EventHub" } else { "DCR" }
    
    Write-Debug "$logPrefix Output destination: $outputDestination"
    
    # =============================================================================
    # ENVIRONMENT VALIDATION
    # =============================================================================
    
    $requiredEnvVars = @("ADXCLUSTERURI", "ADXDATABASE", "CLIENTID")
    if ($outputDestination -eq "DCR") { $requiredEnvVars += "DATA_COLLECTION_ENDPOINT_URL" }
    
    $missingEnvVars = $requiredEnvVars | Where-Object { [string]::IsNullOrWhiteSpace((Get-Item "env:$_" -ErrorAction SilentlyContinue).Value) }
    
    if ($missingEnvVars.Count -gt 0) {
        return @{
            Success = $false
            TableName = $tableName
            Status = "ConfigurationError"
            Message = "Missing environment variables: $($missingEnvVars -join ', ')"
            InstanceId = $instanceId
        }
    }
    
    # =============================================================================
    # STORAGE CONFIGURATION
    # =============================================================================
    
    $storageAccountName = $null
    $storageAccountKey = $null
    $restApiAvailable = $false
    
    if ($env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING) {
        try {
            $storageDetails = Get-StorageDetailsFromConnectionString -ConnectionString $env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING
            if ($storageDetails -and $storageDetails.AccountName) {
                $storageAccountName = $storageDetails.AccountName
                $storageAccountKey = $storageDetails.AccountKey
                $restApiAvailable = $true
            }
        } catch { }
    }
    
    if (-not $restApiAvailable -and $env:AzureWebJobsStorage) {
        try {
            $storageDetails = Get-StorageDetailsFromConnectionString -ConnectionString $env:AzureWebJobsStorage
            if ($storageDetails -and $storageDetails.AccountName) {
                $storageAccountName = $storageDetails.AccountName
                $storageAccountKey = $storageDetails.AccountKey
                $restApiAvailable = $true
            }
        } catch { }
    }
    
    # =============================================================================
    # TIME WINDOW DETERMINATION
    # =============================================================================
    
    if ($restApiAvailable) {
        $lastRunTime = Get-DcrLastRunTimeRestAPI -DcrName $tableName -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -InstanceId $instanceId
    } else {
        $lastRunTime = (Get-Date ([datetime]::UtcNow).AddHours(-1) -Format O)
        Write-Warning "$logPrefix No storage - using 1 hour default window"
    }
    
    $currentTime = Get-Date ($currentTimeZulu) -Format O
    
    # Validate time window (max 1 hour)
    $currentDateTime = [datetime]::Parse($currentTime)
    $lastRunDateTime = [datetime]::Parse($lastRunTime)
    if (($currentDateTime - $lastRunDateTime).TotalHours -gt 1) {
        $lastRunTime = $currentDateTime.AddHours(-1).ToString('O')
    }
    
    Write-Debug "$logPrefix Time window: $lastRunTime to $currentTime"
    
    # =============================================================================
    # QUERY RETRIEVAL AND EXECUTION
    # =============================================================================
    
    $queryDetails = Get-TableQueries -TableName $tableName -StartTime $lastRunTime -EndTime $currentTime -InstanceId $instanceId
    
    if ($queryDetails.Count -eq 0) {
        Write-Debug "$logPrefix No queries found"
        
        if ($restApiAvailable) {
            Set-DcrLastRunTimeRestAPI -DcrName $tableName -LastRunTime $currentTime -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -InstanceId $instanceId | Out-Null
        }
        
        return @{
            Success = $true
            TableName = $tableName
            Status = "NoQueriesFound"
            RecordsProcessed = 0
            InstanceId = $instanceId
        }
    }
    
    $eventData = Get-ADXRecords -QueryDetails $queryDetails -ClientId $env:CLIENTID -LastRunTime $lastRunTime -CurrentTime $currentTime -ADXClusterURI $env:ADXCLUSTERURI -ADXDatabase $env:ADXDATABASE
    
    Write-Debug "$logPrefix Retrieved $($eventData.Count) records from ADX"
    
    # =============================================================================
    # DATA FORWARDING
    # =============================================================================
    
    $recordsSent = 0
    $recordsFailed = 0
    
    if ($eventData.Count -gt 0) {
        if ($outputDestination -eq "EventHub") {
            # Extract raw records - query property may contain JSON string or object array
            $recordsToSend = @()
            foreach ($eventRecord in $eventData) {
                if ($eventRecord.table -eq $tableName -and $eventRecord.query) {
                    # Check if query is a JSON string that needs parsing
                    if ($eventRecord.query -is [string]) {
                        try {
                            $parsedRecords = ConvertFrom-Json -InputObject $eventRecord.query
                            if ($parsedRecords -is [Array]) {
                                $recordsToSend += $parsedRecords
                            } else {
                                $recordsToSend += @($parsedRecords)
                            }
                        } catch {
                            Write-Warning "$logPrefix Failed to parse query JSON: $($_.Exception.Message)"
                        }
                    } else {
                        # Query is already an object or array
                        if ($eventRecord.query -is [Array]) {
                            $recordsToSend += $eventRecord.query
                        } else {
                            $recordsToSend += @($eventRecord.query)
                        }
                    }
                }
            }
            
            if ($recordsToSend.Count -gt 0) {
                $batchPayload = ConvertTo-Json -InputObject $recordsToSend -Depth 50
                $ehResult = Send-ToEventHub -Payload $batchPayload -TableName $tableName -ClientId $env:CLIENTID -InstanceId $instanceId
                
                if ($ehResult.Success) {
                    $recordsSent = $recordsToSend.Count
                } else {
                    $recordsFailed = $recordsToSend.Count
                    
                    # Only log detailed error if not a retry-recommended scenario
                    if ($ehResult.RetryRecommended) {
                        Write-Debug "$logPrefix Event Hub permissions may still be propagating"
                    } else {
                        Write-Warning "$logPrefix Event Hub transmission failed: $($ehResult.Message)"
                    }
                }
            }
        } else {
            # DCR path
            foreach ($eventRecord in $eventData) {
                if ($eventRecord.table -eq $tableName) {
                    $result = Send-ToDCR -EventMessage $eventRecord.query -TableName $tableName -DcrImmutableId $dcrId -DceEndpoint $env:DATA_COLLECTION_ENDPOINT_URL -ClientId $env:CLIENTID -InstanceId $instanceId
                    if ($result.Success) { $recordsSent++ } else { $recordsFailed++ }
                }
            }
        }
    }
    
    # INFORMATION level - key operational metric only
    Write-Information "$logPrefix Sent: $recordsSent, Failed: $recordsFailed"
    
    # =============================================================================
    # TIMESTAMP UPDATE
    # =============================================================================
    
    $allSuccessful = ($recordsFailed -eq 0)
    $timestampUpdated = $false
    
    if ($allSuccessful -or $eventData.Count -eq 0) {
        if ($restApiAvailable) {
            $timestampUpdated = Set-DcrLastRunTimeRestAPI -DcrName $tableName -LastRunTime $currentTime -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -InstanceId $instanceId
        }
    }
    
    # =============================================================================
    # RETURN RESULT
    # =============================================================================
    
    return @{
        Success = $allSuccessful
        TableName = $tableName
        DcrId = $dcrId
        Status = if ($allSuccessful) { "Completed" } else { "CompletedWithErrors" }
        Message = "Processed successfully"
        OutputDestination = $outputDestination
        RecordsProcessed = $recordsSent + $recordsFailed
        RecordsSent = $recordsSent
        RecordsFailed = $recordsFailed
        TimestampUpdated = $timestampUpdated
        InstanceId = $instanceId
        QueueMode = $queueMode
        CycleNumber = $cycleNumber
        ModuleArchitecture = "Lazy-Loading-v1.0"
    }
    
} catch {
    Write-Error "$logPrefix Error: $($_.Exception.Message)"
    
    return @{
        Success = $false
        TableName = if ($tableName) { $tableName } else { "Unknown" }
        Status = "Failed"
        Message = $_.Exception.Message
        InstanceId = $instanceId
        Error = @{
            Type = $_.Exception.GetType().Name
            Message = $_.Exception.Message
            Line = $_.InvocationInfo.ScriptLineNumber
        }
    }
}

Write-Debug "[$instanceId] ADXQueryActivity completed"
