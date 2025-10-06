function Send-EventToLogAnalyticsWithResult {
    <#
    .SYNOPSIS
        Wrapper for Send-EventToLogAnalytics that returns success/failure result
    
    .DESCRIPTION
        Updated wrapper that uses the universal DCR module and provides detailed result reporting
    
    .PARAMETER EventRecord
        JSON formatted event record to send
    
    .PARAMETER EventType
        Type of event (corresponds to table name and DCR mapping)
    
    .PARAMETER DcrMappingTable
        Hashtable mapping event types to DCR configurations
    
    .OUTPUTS
        Hashtable with Success (boolean), ErrorMessage (string), and processing details
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$EventRecord,

        [Parameter(Mandatory=$true)]
        [string]$EventType,

        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$DcrMappingTable
    )
    
    $result = @{
        Success = $false
        ErrorMessage = $null
        EventType = $EventType
        ProcessingMethod = "UniversalDCR"
        Timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    
    try {
        Send-EventToLogAnalytics -EventRecord $EventRecord -EventType $EventType -DcrMappingTable $DcrMappingTable
        $result.Success = $true
        Write-Debug "Send-EventToLogAnalyticsWithResult - Successfully processed event of type $EventType using universal DCR"
    }
    catch {
        $result.ErrorMessage = $_.Exception.Message
        Write-Debug "Send-EventToLogAnalyticsWithResult - Failed to process event of type $EventType using universal DCR. Error: $($_.Exception.Message)"
    }
    
    return $result
}
