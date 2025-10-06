function Get-TableQueueEntryRestAPI {
    <#
    .SYNOPSIS
        Gets a table queue entry with enhanced resilience
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER QueueTableName
        Name of the queue table
    
    .PARAMETER TableName
        Name of the table to retrieve queue entry for
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Hashtable containing the queue entry, or null if not found
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$true)]
        [string]$QueueTableName,
        
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Debug "[$InstanceId] Getting queue entry for table: $TableName"
    
    $operation = {
        $date = (Get-Date).ToUniversalTime().ToString("R")
        $resource = "$QueueTableName(PartitionKey='TableQueue',RowKey='$TableName')"
        
        $stringToSign = "$date`n/$StorageAccountName/$resource"
        
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Convert]::FromBase64String($StorageAccountKey)
        $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
        $signature = [Convert]::ToBase64String($signature)
        
        $headers = @{
            "x-ms-date" = $date
            "Authorization" = "SharedKeyLite $($StorageAccountName):$signature"
            "x-ms-version" = "2020-08-04"
            "Accept" = "application/json;odata=nometadata"
        }
        
        $uri = "https://$StorageAccountName.table.core.windows.net/$resource"
        
        return Invoke-RestMethod -Uri $uri -Headers $headers -Method GET -TimeoutSec 30
    }
    
    $response = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Get-TableQueueEntryRestAPI" -InstanceId $InstanceId
    
    if ($response) {
        Write-Debug "[$InstanceId] Retrieved queue entry for table: $TableName"
        return $response
    } else {
        Write-Warning "[$InstanceId] No queue entry found for table: $TableName"
        return $null
    }
}