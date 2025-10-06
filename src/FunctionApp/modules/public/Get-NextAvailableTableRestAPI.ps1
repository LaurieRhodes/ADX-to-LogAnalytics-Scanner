function Get-NextAvailableTableRestAPI {
    <#
    .SYNOPSIS
        Gets the next available table from queue with enhanced resilience
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER QueueTableName
        Name of the queue table
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Hashtable containing the next available table entry, or null if none found
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$true)]
        [string]$QueueTableName,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Information "[$InstanceId] Searching for next available table in queue: $QueueTableName"
    
    $operation = {
        $date = (Get-Date).ToUniversalTime().ToString("R")
        $simpleResource = "$QueueTableName()"
        $simpleStringToSign = "$date`n/$StorageAccountName/$simpleResource"
        
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Convert]::FromBase64String($StorageAccountKey)
        $simpleSignature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($simpleStringToSign))
        $simpleSignature = [Convert]::ToBase64String($simpleSignature)
        
        $simpleHeaders = @{
            "x-ms-date" = $date
            "Authorization" = "SharedKeyLite $($StorageAccountName):$simpleSignature"
            "x-ms-version" = "2020-08-04"
            "Accept" = "application/json;odata=nometadata"
        }
        
        $simpleUri = "https://$StorageAccountName.table.core.windows.net/$simpleResource"
        
        return Invoke-RestMethod -Uri $simpleUri -Headers $simpleHeaders -Method GET -TimeoutSec 30
    }
    
    $response = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Get-NextAvailableTableRestAPI" -InstanceId $InstanceId
    
    if ($response -and $response.value) {
        Write-Information "[$InstanceId] DEBUG: Found $($response.value.Count) total entries in table"
        
        # Filter for available tables only
        $availableTables = $response.value | Where-Object { 
            $_.PartitionKey -eq "TableQueue" -and $_.Status -eq "Available" 
        }
        
        if ($availableTables) {
            Write-Information "[$InstanceId] DEBUG: Found $($availableTables.Count) available tables"
            
            # ROUND-ROBIN LOGIC: Sort by LastProcessed time (oldest first)
            $sortedTables = $availableTables | Sort-Object { 
                if ([string]::IsNullOrWhiteSpace($_.LastProcessed)) {
                    [DateTime]::MinValue
                } else {
                    try {
                        [DateTime]::Parse($_.LastProcessed)
                    } catch {
                        [DateTime]::MinValue
                    }
                }
            }
            
            $nextTable = $sortedTables[0]
            
            Write-Information "[$InstanceId] ROTATION: Selected table '$($nextTable.TableName)' (LastProcessed: $($nextTable.LastProcessed))"
            
            return $nextTable
        } else {
            Write-Information "[$InstanceId] No available tables found in queue"
        }
    } else {
        Write-Information "[$InstanceId] DEBUG: Table exists but has no entries"
    }
    
    return $null
}