function New-StorageTableRestAPI {
    <#
    .SYNOPSIS
        Creates a storage table with enhanced resilience - handles 409 Conflict gracefully
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER TableName
        Name of the table to create
    
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
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    Write-Information "[$InstanceId] Creating storage table: $TableName"
    
    $operation = {
        $tablePayload = @{
            TableName = $TableName
        }
        
        $body = ConvertTo-Json -InputObject $tablePayload -Compress
        $date = (Get-Date).ToUniversalTime().ToString("R")
        $resource = "Tables"
        
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
        
        $uri = "https://$StorageAccountName.table.core.windows.net/Tables"
        
        return Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30
    }
    
    $result = Invoke-StorageOperationWithResilience -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -Operation $operation -OperationName "New-StorageTableRestAPI" -InstanceId $InstanceId
    
    # Handle both success scenarios: new table created or table already exists
    if ($result -and $result.AlreadyExists) {
        Write-Information "[$InstanceId] Storage table '$TableName' already exists - operation successful"
    } else {
        Write-Information "[$InstanceId] Successfully created storage table: $TableName"
    }
    
    return $true
}