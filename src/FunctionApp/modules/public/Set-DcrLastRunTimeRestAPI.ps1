function Set-DcrLastRunTimeRestAPI {
    <#
    .SYNOPSIS
        Sets the last run time for a DCR with enhanced resilience and automatic table creation
    
    .PARAMETER DcrName
        Name of the DCR to set last run time for
    
    .PARAMETER LastRunTime
        ISO formatted datetime string to set as last run time
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Boolean indicating success ($true) or failure ($false)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DcrName,
        
        [Parameter(Mandatory=$true)]
        [string]$LastRunTime,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Debug "[$InstanceId][$DcrName] Attempting to set last run time to: $LastRunTime"
    
    try {
        # CRITICAL: Ensure table exists before trying to write
        # This handles first-time execution scenarios
        try {
            New-StorageTableRestAPI -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -TableName "eventparsing" -InstanceId $InstanceId | Out-Null
        }
        catch {
            # Table creation failure is not fatal if table already exists
            Write-Debug "[$InstanceId][$DcrName] Table creation check: $($_.Exception.Message)"
        }
        
        $operation = {
            $entity = @{
                PartitionKey = $DcrName
                RowKey = "lastUpdated"
                lastUpdated = $LastRunTime
            }
            
            $body = ConvertTo-Json -InputObject $entity -Compress
            $date = (Get-Date).ToUniversalTime().ToString("R")
            $resource = "eventparsing(PartitionKey='$DcrName',RowKey='lastUpdated')"
            
            $stringToSign = "$date`n/$StorageAccountName/$resource"
            
            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Convert]::FromBase64String($StorageAccountKey)
            $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
            $signature = [Convert]::ToBase64String($signature)
            
            $headers = @{
                "x-ms-date" = $date
                "Authorization" = "SharedKeyLite $($StorageAccountName):$signature"
                "x-ms-version" = "2020-08-04"
                "Content-Type" = "application/json"
                "Accept" = "application/json;odata=nometadata"
            }
            
            $uri = "https://$StorageAccountName.table.core.windows.net/eventparsing(PartitionKey='$DcrName',RowKey='lastUpdated')"
            
            Write-Debug "[$InstanceId][$DcrName] PUT to: $uri with body: $body"
            
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method PUT -Body $body -ContentType "application/json" -TimeoutSec 30
            Write-Debug "[$InstanceId][$DcrName] Response: $($response | ConvertTo-Json -Compress)"
            return $response
        }
        
        $result = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Set-DcrLastRunTimeRestAPI" -InstanceId $InstanceId
        
        # Check if we got a valid result
        if ($null -ne $result) {
            Write-Information "[$InstanceId][$DcrName] ✓ Successfully set last run time to: $LastRunTime"
            return $true
        } else {
            Write-Warning "[$InstanceId][$DcrName] ✗ Set last run time returned null result"
            return $false
        }
    }
    catch {
        Write-Warning "[$InstanceId][$DcrName] ✗ Failed to set last run time: $($_.Exception.Message)"
        Write-Debug "[$InstanceId][$DcrName] Stack trace: $($_.ScriptStackTrace)"
        return $false
    }
}
