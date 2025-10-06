function Test-StorageAccountHealth {
    <#
    .SYNOPSIS
        Tests storage account health with simple connectivity check
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Boolean indicating storage account health status
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    try {
        Write-Debug "[$InstanceId] Testing storage account health: $StorageAccountName"
        
        # Simple connectivity test - try to list tables
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
            "Accept" = "application/json;odata=nometadata"
        }
        
        $uri = "https://$StorageAccountName.table.core.windows.net/Tables"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET -TimeoutSec 10
        
        Write-Debug "[$InstanceId] Storage account health check passed"
        return $true
    }
    catch {
        Write-Warning "[$InstanceId] Storage account health check failed: $($_.Exception.Message)"
        return $false
    }
}
