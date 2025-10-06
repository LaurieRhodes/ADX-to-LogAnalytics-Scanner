param($httpobj, $durableClient)

# Set up logging preferences
$DebugPreference = "Continue"
$InformationPreference = "Continue"

# Initialize execution context
$requestId = [System.Guid]::NewGuid().ToString()
Write-Information "=============================================="
Write-Information "Supervisor Function Started - Queue-Managed Continuous Processing"
Write-Information "Request ID: $requestId"
Write-Information "Current Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Information "Dynamic Table Discovery: ENABLED"
Write-Information "=============================================="

# =============================================================================
# UNIFIED MODULE INITIALIZATION - PROFESSIONAL ARCHITECTURE
# =============================================================================

# Get the path to the current script directory
$scriptDirectory = Split-Path -Parent $PsScriptRoot
# Define the relative path to the modules directory
$modulesPath = Join-Path $scriptDirectory 'modules'
# Resolve the full path to the modules directory
$resolvedModulesPath = (Get-Item $modulesPath).FullName

# ✅ PROFESSIONAL APPROACH: Single unified module import - no dot-sourcing required
Write-Information "[$requestId] Loading unified functionApp module from: $resolvedModulesPath"

try {
    Import-Module "$resolvedModulesPath\functionApp.psm1" -Force -Global
    Write-Debug "[$requestId] functionApp module loaded successfully"
    
    # Verify key functions are available from the unified module
    $keyFunctions = @(
        'Get-StorageDetailsFromConnectionString', 'New-StorageTableRestAPI',
        'Set-TableQueueEntryRestAPI', 'Get-AzureADToken'
    )
    $missingFunctions = @()
    
    foreach ($func in $keyFunctions) {
        if (-not (Get-Command -Name $func -ErrorAction SilentlyContinue)) {
            $missingFunctions += $func
        }
    }
    
    if ($missingFunctions.Count -eq 0) {
    } else {
        Write-Warning "[$requestId] ⚠️ Missing functions: $($missingFunctions -join ', ')"
    }
    
} catch {
    Write-Error "[$requestId] ❌ Failed to load unified functionApp module: $($_.Exception.Message)"
    throw "Module loading failed - cannot continue"
}

Write-Information "[$requestId] 🚀 UNIFIED module architecture loaded - professional standards applied!"

try {
    # Parse configuration from request body
    $config = @{
        batchSize = 5
        queryInterval = 300  # 5 minutes
        maxRetries = 3
        healthCheckInterval = 3600  # 1 hour
        restartOnError = $true
        queuePollInterval = 5  # NEW: seconds between queue polls
        maxCycles = 1000       # NEW: safety limit
        maxExecutionMinutes = 9.92  # OPTIMIZED: 9 minutes 55 seconds for maximum processing time
    }
    
    if ($httpobj.Body) {
        try {
            $inputConfig = $httpobj.Body | ConvertFrom-Json -AsHashtable
            foreach ($key in $inputConfig.Keys) {
                $config[$key] = $inputConfig[$key]
            }
            Write-Information "Configuration updated from request body"
        } catch {
            Write-Warning "Failed to parse request body, using defaults"
        }
    }

    # Load the ADX permission testing function
    . "$PSScriptRoot\Test-ADXPermissions.ps1"

    # Helper function to encode complex objects for Durable Functions
    function ConvertTo-Base64EncodedJson {
        param($Object)
        
        $jsonText = ConvertTo-Json -InputObject $Object -Depth 10 -Compress
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonText)
        $encodedText = [Convert]::ToBase64String($bytes)
        
        Write-Debug "Encoded object type $($Object.GetType().Name) to base64 (length: $($encodedText.Length))"
        return $encodedText
    }

    function Get-DynamicTableMap {
        Write-Debug "DYNAMIC DISCOVERY: Scanning environment variables for DCR configurations..."
        
        $tableMap = @{}
        $dcrVariables = @()
        
        # Get all environment variables that start with "DCR"
        Get-ChildItem env: | Where-Object { $_.Name.StartsWith("DCR") -and $_.Name -ne "DCR" } | ForEach-Object {
            $dcrVariables += @{
                Name = $_.Name
                Value = $_.Value
                TableName = $_.Name.Substring(3)  # Remove "DCR" prefix to get table name
            }
        }
        
        Write-Information "DISCOVERY: Found $($dcrVariables.Count) DCR environment variables"
        
        foreach ($dcrVar in $dcrVariables) {
            $tableName = $dcrVar.TableName
            $dcrId = $dcrVar.Value
            $envVarName = $dcrVar.Name
            
            if (-not [string]::IsNullOrWhiteSpace($dcrId)) {
                $tableMap[$tableName] = @{
                    "DcrId" = $dcrId
                    "EnvironmentVariable" = $envVarName
                    "DiscoveredAt" = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
                }
                Write-Debug "DISCOVERED: Table '$tableName' → DCR ID: $($dcrId.Substring(0, [Math]::Min(8, $dcrId.Length)))... (from $envVarName)"
            } else {
                Write-Warning "SKIPPED: Environment variable '$envVarName' has empty/null DCR ID"
            }
        }
        
        if ($tableMap.Count -eq 0) {
            Write-Warning "DISCOVERY WARNING: No valid DCR environment variables found!"
            Write-Information "Expected pattern: DCR{TableName} = {DCR-ID}"
            Write-Information "Examples:"
            Write-Information "  - DCRSyslog = dcr-12345678..."
            Write-Information "  - DCRSecurityEvent = dcr-87654321..."
            Write-Information "  - DCRASimAuditEventLogs = dcr-abcdef12..."
        }
        
        return $tableMap
    }

    # Get dynamic table configuration
    $tableMap = Get-DynamicTableMap

    if ($tableMap.Count -eq 0) {
        throw "FATAL: No DCR environment variables found. Cannot proceed without table configuration."
    }

    Write-Information "DYNAMIC MODE: Processing $($tableMap.Count) dynamically discovered tables"

    # Enhanced validation with detailed reporting
    $missingDcrIds = @()
    $validTables = @{}
    $invalidTables = @()
    
    Write-Information "Validating dynamically discovered DCR configurations..."
    
    foreach ($tableName in $tableMap.Keys) {
        $tableConfig = $tableMap[$tableName]
        $dcrId = $tableConfig.DcrId
        $envVar = $tableConfig.EnvironmentVariable
        
        if (-not $dcrId -or [string]::IsNullOrWhiteSpace($dcrId)) {
            $missingDcrIds += "$tableName (env var: $envVar)"
            $invalidTables += $tableName
            Write-Warning "✗ Table $tableName has invalid DCR ID from $envVar"
        } elseif ($dcrId.Length -lt 10) {
            # Basic DCR ID format validation
            $invalidTables += $tableName
            Write-Warning "✗ Table $tableName has suspiciously short DCR ID: '$dcrId' (from $envVar)"
        } else {
            $validTables[$tableName] = $tableConfig
            Write-Information "✓ Table $tableName validated - DCR: $($dcrId.Substring(0, [Math]::Min(8, $dcrId.Length)))... (from $envVar)"
        }
    }
    
    # Report discovery and validation results
    Write-Information ""
    Write-Information "  Total DCR variables found: $($tableMap.Count)"
    Write-Information "  Valid table configurations: $($validTables.Count)"
    Write-Information "  Invalid configurations: $($invalidTables.Count)"
    
    if ($invalidTables.Count -gt 0) {
        Write-Warning "Invalid table configurations found:"
        $invalidTables | ForEach-Object { Write-Warning "  - $_" }
    }
    
    if ($missingDcrIds.Count -gt 0) {
        Write-Warning "Missing or invalid DCR environment variables:"
        $missingDcrIds | ForEach-Object { Write-Warning "  - $_" }
        
        # Use only valid tables
        $tableMap = $validTables
        Write-Information "Proceeding with $($tableMap.Count) valid tables from dynamic discovery"
    } else {
        Write-Information "✓ All $($tableMap.Count) dynamically discovered tables have valid DCR IDs"
    }

    if ($tableMap.Count -eq 0) {
        throw "FATAL: No valid DCR configurations found after validation - cannot proceed"
    }

    # Validate ADX configuration and permissions with specific error handling
    if ($env:ADXCLUSTERURI -and $env:ADXDATABASE -and $env:CLIENTID) {
        Write-Information "ADX configuration complete - validating access (REQUIRED)"
        
        try {
            $adxValidation = Test-ADXPermissions -ClusterUri $env:ADXCLUSTERURI -Database $env:ADXDATABASE -ClientId $env:CLIENTID
            Write-Information "✓ ADX access validated - proceeding with table processing"
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Error "FATAL: Cannot proceed without ADX access - $errorMessage"
            
            return @{
                statusCode = 503
                headers = @{ 'Content-Type' = 'application/json' }
                body = @{
                    status = "supervisor_blocked"
                    message = "ADX access validation failed"
                    supervisorId = $requestId
                    error = $errorMessage
                    discoveredTables = $tableMap.Count
                } | ConvertTo-Json -Depth 3
            }
        }
    } else {
        throw "FATAL: ADX configuration incomplete (missing ADXCLUSTERURI, ADXDATABASE, or CLIENTID)"
    }

    # SIMPLIFIED: Calculate end time as current time + configured max execution minutes
    # Since timer fires at 10-minute boundaries, we don't need complex block alignment
    $currentTime = Get-Date
    $currentTimeUtc = $currentTime.ToUniversalTime()
    $maxConfiguredMinutes = $config.maxExecutionMinutes  # 9.92 minutes (9m 55s)
    $safetyBufferMinutes = 0.083  # OPTIMIZED: 5 seconds safety buffer
    
    # Calculate block end time as simple offset from now
    $blockEndTime = $currentTimeUtc.AddMinutes($maxConfiguredMinutes)
    $blockEndTimeZulu = $blockEndTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $effectiveMaxMinutes = $maxConfiguredMinutes
    
    Write-Information "SIMPLIFIED: Time Boundary Calculation:"
    Write-Information "  Current Time (UTC): $($currentTimeUtc.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Information "  Block End Time: $($blockEndTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))"
    Write-Information "  Effective Max Minutes: $([Math]::Round($effectiveMaxMinutes, 2))"
    Write-Information "  Safety Buffer: $([Math]::Round($safetyBufferMinutes * 60, 0)) seconds (OPTIMIZED)"

    # NEW: Get storage account details for queue management using unified module
    $storageAccountName = $null
    $storageAccountKey = $null
    $restApiAvailable = $false
    
    # Try WEBSITE_CONTENTAZUREFILECONNECTIONSTRING first (has account key)
    if ($env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING) {
        try {
            # ✅ USING UNIFIED MODULE: Get connection string parser from functionApp module
            $storageDetails = Get-StorageDetailsFromConnectionString -ConnectionString $env:WEBSITE_CONTENTAZUREFILECONNECTIONSTRING
            if ($storageDetails -and $storageDetails.AccountName -and $storageDetails.AccountKey) {
                $storageAccountName = $storageDetails.AccountName
                $storageAccountKey = $storageDetails.AccountKey
                $restApiAvailable = $true
                Write-Information "Using storage account for queue management: $storageAccountName"
            } else {
                Write-Warning "Could not parse storage details from WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"
            }
        }
        catch {
            Write-Warning "Failed to parse WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: $($_.Exception.Message)"
        }
    }
    
    # Fallback to AzureWebJobsStorage if WEBSITE_CONTENTAZUREFILECONNECTIONSTRING not available
    if (-not $restApiAvailable -and $env:AzureWebJobsStorage) {
        try {
            $storageDetails = Get-StorageDetailsFromConnectionString -ConnectionString $env:AzureWebJobsStorage
            if ($storageDetails -and $storageDetails.AccountName -and $storageDetails.AccountKey) {
                $storageAccountName = $storageDetails.AccountName  
                $storageAccountKey = $storageDetails.AccountKey
                $restApiAvailable = $true
                Write-Information "Using storage account (fallback) for queue management: $storageAccountName"
            } else {
                Write-Warning "Could not parse storage details from AzureWebJobsStorage"
            }
        }
        catch {
            Write-Warning "Failed to parse AzureWebJobsStorage: $($_.Exception.Message)"
        }
    }
    
    if (-not $restApiAvailable) {
        throw "Storage account access required for queue management - no connection string available"
    }

    # NEW: Initialize the table processing queue with dynamic tables using unified module
    $queueTableName = "tableprocessingqueue"
    Write-Information "Initializing table processing queue: $queueTableName"
    
    # ✅ USING UNIFIED MODULE: Create queue table if it doesn't exist
    $queueCreated = New-StorageTableRestAPI -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -TableName $queueTableName -InstanceId $requestId
    
    if (-not $queueCreated) {
        throw "Failed to create/access table processing queue"
    }
    
    # NEW: Populate queue with all dynamically discovered tables using unified module
    $tablesPopulated = 0
    foreach ($tableName in $tableMap.Keys) {
        $tableConfig = $tableMap[$tableName]
        
        # Create queue entry for this table with discovery metadata
        $queueEntry = @{
            PartitionKey = "TableQueue"
            RowKey = $tableName
            TableName = $tableName
            DcrId = $tableConfig.DcrId
            Status = "Available"  # Available, Processing, Error
            LastProcessed = ""
            LastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            ProcessingInstanceId = ""
            SupervisorId = $requestId
            EnvironmentVariable = $tableConfig.EnvironmentVariable
            DiscoveredAt = $tableConfig.DiscoveredAt
            DiscoveryMethod = "Dynamic"
        }
        
        # ✅ USING UNIFIED MODULE: Insert or update queue entry
        $queueEntryCreated = Set-TableQueueEntryRestAPI -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -TableName $queueTableName -QueueEntry $queueEntry -InstanceId $requestId
        
        if ($queueEntryCreated) {
            $tablesPopulated++
            Write-Information "✓ Added $tableName to processing queue (discovered from $($tableConfig.EnvironmentVariable))"
        } else {
            Write-Warning "✗ Failed to add $tableName to processing queue"
        }
    }
    
    Write-Information "Dynamic queue initialization complete: $tablesPopulated/$($tableMap.Count) tables added"
    
    if ($tablesPopulated -eq 0) {
        throw "No tables were successfully added to the processing queue"
    }

    # Display final dynamic table configuration
    Write-Information ""
    Write-Information "FINAL DYNAMIC TABLE CONFIGURATION: $($tableMap.Count) tables"
    Write-Information "Tables discovered and configured for processing:"
    $tableMap.GetEnumerator() | Sort-Object Key | ForEach-Object {
        $dcrShort = if ($_.Value.DcrId) { "...$(($_.Value.DcrId).Substring([Math]::Max(0, $_.Value.DcrId.Length - 8)))" } else { "missing" }
        $envVar = $_.Value.EnvironmentVariable
        Write-Information "  - $($_.Key) → DCR: $dcrShort (from $envVar)"
    }

    # **NOW START THE QUEUE-MANAGED ORCHESTRATOR WITH DYNAMIC TABLES**
    Write-Information ""
    Write-Information "Starting OPTIMIZED queue-managed orchestration for near real-time processing..."
    
    $cycleNumber = 1
    
    # ENHANCED: Create orchestration input with optimized time boundaries
    $orchestrationInput = @{
        SupervisorId = $requestId
        CycleNumber = $cycleNumber
        StartTime = $currentTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
        BlockEndTime = $blockEndTimeZulu
        MaxExecutionTime = $effectiveMaxMinutes
        DataCollectionEndpointUrl = $env:DATA_COLLECTION_ENDPOINT_URL
        SentinelWorkspaceName = $env:SENTINEL_WORKSPACE_NAME
        ProcessingMode = "QueueManaged"
        BlockAlignment = "TimerAligned"
        
        # NEW: Queue management settings
        QueueTableName = $queueTableName
        StorageAccountName = $storageAccountName
        StorageAccountKey = $storageAccountKey
        TablesInQueue = $tablesPopulated
        QueuePollInterval = $config.queuePollInterval
        MaxCycles = $config.maxCycles
        
        # ENHANCED: Dynamic discovery metadata
        TableDiscovery = @{
            Method = "Dynamic"
            TotalDiscovered = $tableMap.Count
            ValidTables = $tablesPopulated
            InvalidTables = $invalidTables.Count
            DiscoveryTimestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        
        # OPTIMIZED: Enhanced time boundary settings for near real-time
        TimeBoundarySettings = @{
            CurrentTimeUtc = $currentTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
            BlockEndTime = $blockEndTimeZulu
            EffectiveMaxMinutes = $effectiveMaxMinutes
            SafetyBufferSeconds = [Math]::Round($safetyBufferMinutes * 60, 0)
            OptimizedForNearRealTime = $true
        }
    }
    
    # Validate orchestration input before encoding
    Write-Information "OPTIMIZED orchestration input validation:"
    Write-Information "  - SupervisorId: $($orchestrationInput.SupervisorId)"
    Write-Information "  - QueueTableName: $($orchestrationInput.QueueTableName)"
    Write-Information "  - TablesInQueue: $($orchestrationInput.TablesInQueue)"
    Write-Information "  - Discovery Method: $($orchestrationInput.TableDiscovery.Method)"
    Write-Information "  - Total Discovered: $($orchestrationInput.TableDiscovery.TotalDiscovered)"
    Write-Information "  - BlockEndTime: $($orchestrationInput.BlockEndTime)"
    Write-Information "  - MaxExecutionTime: $($orchestrationInput.MaxExecutionTime) (OPTIMIZED)"
    Write-Information "  - QueuePollInterval: $($orchestrationInput.QueuePollInterval)"
    Write-Information "  - EffectiveMaxMinutes: $($orchestrationInput.TimeBoundarySettings.EffectiveMaxMinutes)"
    Write-Information "  - SafetyBufferSeconds: $($orchestrationInput.TimeBoundarySettings.SafetyBufferSeconds)"
    Write-Information "  - OptimizedForNearRealTime: $($orchestrationInput.TimeBoundarySettings.OptimizedForNearRealTime)"

    # Start the queue-managed orchestration
    $encodedInput = ConvertTo-Base64EncodedJson -Object $orchestrationInput
    Write-Information "Encoded orchestration input length: $($encodedInput.Length) characters"
    
    $instanceId = Start-NewOrchestration -FunctionName "ContinuousQueueOrchestrator" -Input $encodedInput -DurableClient $durableClient
    Write-Information "✓ OPTIMIZED queue-managed orchestration started - Instance ID: $instanceId"
    
    # Wait briefly for orchestration to start
    Start-Sleep -Seconds 2
    
    Write-Information "Supervisor completed - OPTIMIZED near real-time orchestration running with Instance ID: $instanceId"
    
    return @{
        statusCode = 200
        headers = @{ 'Content-Type' = 'application/json' }
        body = @{
            status = "supervisor_completed"
            message = "OPTIMIZED queue-managed orchestration started for near real-time processing"
            supervisorId = $requestId
            orchestrationInstanceId = $instanceId
            timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            tableCount = $tablesPopulated
            blockEndTime = $blockEndTimeZulu
            effectiveMaxMinutes = $effectiveMaxMinutes
            serializationMethod = "base64"
            processingMode = "QueueManaged"
            queueTableName = $queueTableName
            validTablesConfirmed = $true
            optimizations = @{
                maxExecutionMinutes = 9.92
                safetyBufferSeconds = 5
                optimizedForNearRealTime = $true
                timeBoundaryFix = "Simplified timer-aligned processing with 5-second safety buffer"
            }
            moduleArchitecture = "Unified-functionApp-v3.0-Optimized"
            tableDiscovery = @{
                method = "Dynamic"
                totalDiscovered = $tableMap.Count
                validTables = $tablesPopulated
                invalidTables = $invalidTables.Count
                discoveryEnabled = $true
            }
        } | ConvertTo-Json -Depth 3
    }
    
} catch {
    Write-Error "Critical error in Supervisor Function: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    
    return @{
        statusCode = 500
        headers = @{ 'Content-Type' = 'application/json' }
        body = @{
            status = "supervisor_critical_error"
            message = "Supervisor function failed"
            supervisorId = $requestId
            error = @{
                message = $_.Exception.Message
                type = $_.Exception.GetType().Name
                timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
            moduleArchitecture = "Unified-functionApp-v3.0-Optimized"
            tableDiscovery = @{
                enabled = $true
                failed = $true
            }
        } | ConvertTo-Json -Depth 3
    }
}

Write-Information "Supervisor Function execution completed with OPTIMIZED near real-time architecture"
