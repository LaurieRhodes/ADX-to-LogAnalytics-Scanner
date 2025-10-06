function Set-TableQueueEntryRestAPI {
    <#
    .SYNOPSIS
        Sets a table queue entry with enhanced resilience
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER TableName
        Name of the table containing the queue entries
    
    .PARAMETER QueueEntry
        Hashtable containing the queue entry data
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Boolean indicating success
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$QueueEntry,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Information "[$InstanceId] Setting queue entry for table: $($QueueEntry.RowKey)"
    
    $operation = {
        $body = ConvertTo-Json -InputObject $QueueEntry -Compress
        $date = (Get-Date).ToUniversalTime().ToString("R")
        $resource = "$TableName(PartitionKey='$($QueueEntry.PartitionKey)',RowKey='$($QueueEntry.RowKey)')"
        
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
        
        $uri = "https://$StorageAccountName.table.core.windows.net/$resource"
        
        return Invoke-RestMethod -Uri $uri -Headers $headers -Method PUT -Body $body -ContentType "application/json" -TimeoutSec 30
    }
    
    $result = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Set-TableQueueEntryRestAPI" -InstanceId $InstanceId
    
    Write-Information "[$InstanceId] Successfully set queue entry for table: $($QueueEntry.RowKey)"
    return $true
}