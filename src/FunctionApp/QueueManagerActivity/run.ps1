param($inputobject)

$instanceId = [System.Guid]::NewGuid().ToString().Substring(0, 8)

# Set up logging preferences
$InformationPreference = "Continue"
$DebugPreference = "Continue"

Write-Information "[$instanceId] QueueManagerActivity started"

# =============================================================================
# UNIFIED MODULE INITIALISATION
# =============================================================================

# Get the path to the current script directory
$scriptDirectory = Split-Path -Parent $PsScriptRoot
# Define the relative path to the modules directory
$modulesPath = Join-Path $scriptDirectory 'modules'
# Resolve the full path to the modules directory
$resolvedModulesPath = (Get-Item $modulesPath).FullName

Write-Debug "[$instanceId] Loading functionApp module from: $resolvedModulesPath"

try {
    # Import the main functionApp module - contains all required functions
    Import-Module "$resolvedModulesPath\functionApp.psm1" -Force -Global
    Write-Debug "[$instanceId] functionApp module loaded successfully with unified architecture"
    
    # Verify key functions are available from the unified module
    $keyFunctions = @(
        'Get-NextAvailableTableRestAPI', 'Set-TableAsProcessingRestAPI', 'Update-TableStatusRestAPI', 'Get-TableQueueEntryRestAPI'
    )
    $missingFunctions = @()
    
    foreach ($func in $keyFunctions) {
        if (-not (Get-Command -Name $func -ErrorAction SilentlyContinue)) {
            $missingFunctions += $func
        }
    }
    
    if ($missingFunctions.Count -eq 0) {
        Write-Debug "[$instanceId] ✅ All key functions available in unified functionApp module"
    } else {
        Write-Warning "[$instanceId] ⚠️ Missing functions: $($missingFunctions -join ', ')"
        Write-Debug "[$instanceId] Available functions: $((Get-Command -Module functionApp).Name -join ', ')"
    }
    
} catch {
    Write-Error "[$instanceId] ❌ Failed to load unified functionApp module: $($_.Exception.Message)"
    throw "Module loading failed - cannot continue"
}

Write-Debug "[$instanceId] 🚀 UNIFIED module architecture loaded for QueueManagerActivity!"

try {
    # Decode input
    $DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($inputobject))
    $params = ConvertFrom-Json -InputObject $DecodedText
    
    $operationType = $params.OperationType
    $queueTableName = $params.QueueTableName
    $storageAccountName = $params.StorageAccountName
    $storageAccountKey = $params.StorageAccountKey
    $supervisorId = $params.SupervisorId
    
    Write-Information "[$instanceId] QueueManagerActivity - Operation: $operationType"
    Write-Debug "[$instanceId] DEBUG: QueueTableName: $queueTableName"
    Write-Debug "[$instanceId] DEBUG: StorageAccountName: $storageAccountName"
    
    if ($operationType -eq "GetNextAvailable") {
        # Find next available table to process using unified module
        Write-Debug "[$instanceId] Searching for next available table..."
        
        $availableTable = Get-NextAvailableTableRestAPI -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -QueueTableName $queueTableName -InstanceId $instanceId
        
        if ($availableTable) {
            Write-Debug "[$instanceId] Found available table: $($availableTable.TableName)"
            Write-Debug "[$instanceId] DEBUG: Available table details: Status=$($availableTable.Status), DcrId=$($availableTable.DcrId), PartitionKey=$($availableTable.PartitionKey)"
            
            # Set table as processing using unified module function with approved PowerShell verb
            $setResult = Set-TableAsProcessingRestAPI -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -QueueTableName $queueTableName -TableName $availableTable.TableName -ProcessingInstanceId $params.InstanceId -InstanceId $instanceId
            
            if ($setResult) {
                Write-Information "[$instanceId] Successfully set $($availableTable.TableName) as processing"
                
                return @{
                    Success = $true
                    TableName = $availableTable.TableName
                    TableConfig = @{ DcrId = $availableTable.DcrId }
                    Message = "Table assigned for processing"
                    OperationType = $operationType
                    ModuleArchitecture = "Unified-functionApp"
                    PowerShellCompliance = "Approved-Verbs"
                }
            } else {
                Write-Warning "[$instanceId] Failed to set $($availableTable.TableName) as processing"
                
                return @{
                    Success = $false
                    Reason = "FailedToSetProcessing"
                    Message = "Could not set table as processing"
                    TableName = $availableTable.TableName
                    OperationType = $operationType
                    ModuleArchitecture = "Unified-functionApp"
                }
            }
        } else {
            Write-Warning "[$instanceId] No available tables found"
            
            return @{
                Success = $false
                Reason = "NoAvailableTables"
                Message = "No tables available for processing"
                OperationType = $operationType
                ModuleArchitecture = "Unified-functionApp"
            }
        }
    }
    elseif ($operationType -eq "UpdateStatus") {
        # Update table status after processing using unified module
        $tableName = $params.TableName
        $processResult = $params.ProcessingResult
        
        Write-Information "[$instanceId] Updating status for table: $tableName"
        Write-Debug "[$instanceId] DEBUG: ProcessingResult received: Success=$($processResult.Success), Status=$($processResult.Status), Message=$($processResult.Message)"
        
        # ENHANCED: More intelligent status determination
        $newStatus = if ($processResult -and $processResult.Success) { 
            "Available" 
        } elseif ($processResult -and $processResult.Status -eq "BlockTimeExceeded") {
            # If block time exceeded, mark as available for next cycle
            "Available"
        } else { 
            "Error" 
        }
        
        # FIX: Always provide a LastProcessed value
        # - On success: Update to current time
        # - On BlockTimeExceeded or Error: Keep existing timestamp by using a timestamp from 1 hour ago as a safe default
        #   (The Update function should ideally preserve existing value, but we provide a fallback)
        $lastProcessed = if ($processResult -and $processResult.Success) { 
            # Successful processing - update to current time
            (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ') 
        } else {
            # Error or BlockTimeExceeded - use a default timestamp (1 hour ago)
            # This ensures the table can be retried without being marked as "never processed"
            (Get-Date).AddHours(-1).ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        
        Write-Debug "[$instanceId] Setting status to: $newStatus, LastProcessed: $lastProcessed"
        Write-Debug "[$instanceId] DEBUG: Processing result details: $($processResult | ConvertTo-Json -Depth 3)"
        
        $updateResult = Update-TableStatusRestAPI -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey -QueueTableName $queueTableName -TableName $tableName -Status $newStatus -LastProcessed $lastProcessed -InstanceId $instanceId
        
        if ($updateResult) {
            Write-Debug "[$instanceId] Successfully updated status for $tableName to $newStatus"
        } else {
            Write-Error "[$instanceId] Failed to update status for $tableName"
        }
        
        return @{
            Success = $updateResult
            TableName = $tableName
            NewStatus = $newStatus
            LastProcessed = $lastProcessed
            Message = if ($updateResult) { "Status updated successfully" } else { "Failed to update status" }
            OperationType = $operationType
            ProcessingResultReceived = ($processResult -ne $null)
            ProcessingSuccess = if ($processResult) { $processResult.Success } else { $false }
            ModuleArchitecture = "Unified-functionApp"
            PowerShellCompliance = "Approved-Verbs"
        }
    }
    else {
        throw "Unknown operation type: $operationType"
    }
    
} catch {
    Write-Error "[$instanceId] QueueManagerActivity error: $($_.Exception.Message)"
    Write-Error "[$instanceId] DEBUG: Stack trace: $($_.ScriptStackTrace)"
    
    return @{
        Success = $false
        Message = "Queue manager error: $($_.Exception.Message)"
        OperationType = if ($operationType) { $operationType } else { "Unknown" }
        ModuleArchitecture = "Unified-functionApp"
        PowerShellCompliance = "Approved-Verbs"
        Error = @{
            Type = $_.Exception.GetType().Name
            Message = $_.Exception.Message
            StackTrace = $_.ScriptStackTrace
        }
    }
}

Write-Information "[$instanceId] QueueManagerActivity completed"
