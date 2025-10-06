function Update-TableStatusRestAPI {
    <#
    .SYNOPSIS
        Updates table status with enhanced resilience
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER QueueTableName
        Name of the queue table
    
    .PARAMETER TableName
        Name of the table to update status for
    
    .PARAMETER Status
        New status to set
    
    .PARAMETER LastProcessed
        Last processed timestamp
    
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
        [string]$QueueTableName,
        
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        [string]$Status,
        
        [Parameter(Mandatory=$true)]
        [string]$LastProcessed,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Information "[$InstanceId] Updating table $TableName status to: $Status"
    
    # First get current entity
    $currentEntity = Get-TableQueueEntryRestAPI -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -QueueTableName $QueueTableName -TableName $TableName -InstanceId $InstanceId
    
    if (-not $currentEntity) {
        throw "Could not retrieve current entity for table $TableName"
    }
    
    $operation = {
        $entity = @{
            PartitionKey = "TableQueue"
            RowKey = $TableName
            TableName = $currentEntity.TableName
            DcrId = $currentEntity.DcrId
            Status = $Status
            LastProcessed = $LastProcessed
            ProcessingInstanceId = ""  # Clear processing instance
            LastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
            SupervisorId = $currentEntity.SupervisorId
        }
        
        $body = ConvertTo-Json -InputObject $entity -Compress
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
            "Content-Type" = "application/json"
            "Accept" = "application/json;odata=nometadata"
            "If-Match" = "*"
        }
        
        $uri = "https://$StorageAccountName.table.core.windows.net/$resource"
        return Invoke-RestMethod -Uri $uri -Headers $headers -Method PUT -Body $body -ContentType "application/json" -TimeoutSec 30
    }
    
    $result = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Update-TableStatusRestAPI" -InstanceId $InstanceId
    
    Write-Information "[$InstanceId] Successfully updated table $TableName status to: $Status"
    return $true
}