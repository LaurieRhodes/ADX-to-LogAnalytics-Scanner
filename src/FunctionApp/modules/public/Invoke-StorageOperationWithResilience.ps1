function Invoke-StorageOperationWithResilience {
    <#
    .SYNOPSIS
        Simple resilience wrapper for storage operations
    
    .PARAMETER StorageAccountName
        Name of the Azure Storage account
    
    .PARAMETER StorageAccountKey
        Access key for the Azure Storage account
    
    .PARAMETER Operation
        ScriptBlock containing the storage operation to execute
    
    .PARAMETER OperationName
        Name of the operation for logging purposes
    
    .PARAMETER InstanceId
        Unique instance identifier for logging
    
    .OUTPUTS
        Result of the storage operation
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$Operation,
        
        [Parameter(Mandatory=$true)]
        [string]$OperationName,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    $maxRetries = 3
    $retryCount = 0
    
    while ($retryCount -lt $maxRetries) {
        try {
            $result = & $Operation
            return $result
        }
        catch {
            $retryCount++
            
            # Handle specific Azure Storage errors
            if ($_.Exception.Response) {
                $statusCode = $_.Exception.Response.StatusCode.value__
                
                # Handle 409 Conflict (table already exists) as success for table creation operations
                if ($statusCode -eq 409 -and ($OperationName -eq "New-StorageTable" -or $OperationName -eq "New-StorageTableRestAPI")) {
                    Write-Debug "[$InstanceId] Table already exists (409) - treating as success"
                    return @{ AlreadyExists = $true }
                }
                
                # Handle 404 Not Found for get operations
                if ($statusCode -eq 404 -and $OperationName -like "*Get*") {
                    Write-Debug "[$InstanceId] Resource not found (404) for $OperationName"
                    return $null
                }
                
                Write-Warning "[$InstanceId] $OperationName failed with HTTP $statusCode (attempt $retryCount/$maxRetries)"
            } else {
                Write-Warning "[$InstanceId] $OperationName failed: $($_.Exception.Message) (attempt $retryCount/$maxRetries)"
            }
            
            if ($retryCount -lt $maxRetries) {
                $waitTime = [Math]::Pow(2, $retryCount) # Exponential backoff
                Write-Debug "[$InstanceId] Waiting $waitTime seconds before retry..."
                Start-Sleep -Seconds $waitTime
            } else {
                throw "Max retries exceeded for $OperationName`: $($_.Exception.Message)"
            }
        }
    }
}