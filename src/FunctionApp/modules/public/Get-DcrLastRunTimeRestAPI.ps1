function Get-DcrLastRunTimeRestAPI {
    <#
    .SYNOPSIS
        Gets the last run time for a DCR with enhanced resilience
    
    .PARAMETER DcrName
        Name of the DCR to get last run time for
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        ISO formatted datetime string of last run time, or default time if not found
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DcrName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Information "[$InstanceId][$DcrName] Getting last run time from storage account: $StorageAccountName"
    
    $operation = {
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
            "Accept" = "application/json;odata=nometadata"
        }
        
        $uri = "https://$StorageAccountName.table.core.windows.net/eventparsing(PartitionKey='$DcrName',RowKey='lastUpdated')"
        
        return Invoke-RestMethod -Uri $uri -Headers $headers -Method GET -TimeoutSec 30
    }
    
    $result = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "Get-DcrLastRunTimeRestAPI" -InstanceId $InstanceId
    
    if ($result -and $result.lastUpdated) {
        Write-Information "[$InstanceId][$DcrName] Retrieved last run time: $($result.lastUpdated)"
        return $result.lastUpdated
    }
    
    # Return default time if no previous run found
    $defaultTime = (Get-Date ([datetime]::UtcNow).AddHours(-1) -Format O)
    Write-Information "[$InstanceId][$DcrName] No previous run found, using default: $defaultTime"
    return $defaultTime
}