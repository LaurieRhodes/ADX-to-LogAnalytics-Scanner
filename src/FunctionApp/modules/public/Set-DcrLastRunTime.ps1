function Set-DcrLastRunTime {
    <#
    .SYNOPSIS
        Sets the last successful run time for a specific DCR in Azure Storage Table
    
    .DESCRIPTION
        Updates the timestamp record for a Data Collection Rule in Azure Storage Table
        to track successful execution times for incremental processing.
    
    .PARAMETER DcrName
        Name of the Data Collection Rule to update timestamp for
        
    .PARAMETER LastRunTime
        ISO 8601 formatted timestamp to set as the last run time
        
    .PARAMETER TableName
        Name of the Azure Storage Table containing timestamps
        
    .PARAMETER StorageContext
        Azure Storage context for table operations
    
    .OUTPUTS
        None - function throws on failure, completes silently on success
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DcrName,
        
        [Parameter(Mandatory=$true)]
        [string]$LastRunTime,
        
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        $StorageContext
    )
    
    try {
        Write-Debug "Set-DcrLastRunTime - Updating last run time for DCR $DcrName to $LastRunTime"
        
        Set-AzTableStorageData `
            -TableName $TableName `
            -StorageContext $StorageContext `
            -PartitionKey "dcr_timestamps" `
            -RowKey $DcrName `
            -Properties @{
                "lastruntime" = $LastRunTime
                "updatedat" = (Get-Date ([datetime]::UtcNow) -Format O)
            }
        
        Write-Information "Set-DcrLastRunTime - Successfully updated last run time for $DcrName to $LastRunTime"
    }
    catch {
        Write-Error "Set-DcrLastRunTime - Failed to update last run time for $DcrName. Error: $($_.Exception.Message)"
        throw
    }
}
