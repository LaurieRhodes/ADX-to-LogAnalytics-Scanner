function Send-EventToLogAnalytics {
    <#
    .SYNOPSIS
        Sends event records to Log Analytics via Data Collection Rules using universal DCR module
    
    .DESCRIPTION
        Updated to use the standardized Send-ToDCR function instead of table-specific functions.
        Handles underscore property filtering and stream naming automatically.
    
    .PARAMETER EventRecord
        JSON formatted event record to send
    
    .PARAMETER EventType
        Type of event (corresponds to table name)
    
    .PARAMETER DcrMappingTable
        Hashtable mapping event types to DCR configurations
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

    begin {
        Write-Debug "Send-EventToLogAnalytics - Starting to process event of type $EventType using universal DCR module"
    }

    process {
        try {
            # Validate input parameters
            if ($null -eq $EventRecord) {
                throw "EventRecord cannot be null"
            }

            if ([string]::IsNullOrWhiteSpace($EventType)) {
                throw "EventType cannot be null or empty"
            }

            if ($null -eq $DcrMappingTable) {
                throw "DcrMappingTable cannot be null"
            }

            # Check if the event type exists in the mapping
            if (-not $DcrMappingTable.ContainsKey($EventType)) {
                $validTypes = $DcrMappingTable.Keys -join ', '
                throw "Unsupported event type $EventType. Valid types are $validTypes"
            }

            # Get the handler configuration
            $handler = $DcrMappingTable[$EventType]

            # Validate handler configuration
            if ($null -eq $handler.DcrId) {
                throw "DcrId not specified for event type $EventType"
            }

            # Get environment variables
            $dceEndpoint = $env:DATA_COLLECTION_ENDPOINT_URL
            $clientId = $env:CLIENTID

            if ([string]::IsNullOrWhiteSpace($dceEndpoint)) {
                throw "DATA_COLLECTION_ENDPOINT_URL environment variable not set"
            }

            if ([string]::IsNullOrWhiteSpace($clientId)) {
                throw "CLIENTID environment variable not set"
            }

            # Import and use universal DCR module
            Import-Module -Name "$PSScriptRoot\UniversalDCR.psm1" -Force

            Write-Debug "Send-EventToLogAnalytics - Calling universal DCR sender for $EventType"

            # Use standardized DCR function instead of table-specific ones
            $result = Send-ToDCR -EventMessage $EventRecord -TableName $EventType -DcrImmutableId $handler.DcrId -DceEndpoint $dceEndpoint -ClientId $clientId

            if ($result.Success) {
                Write-Debug "Send-EventToLogAnalytics - Successfully sent event to $EventType using universal DCR module"
            } else {
                throw "Universal DCR sender failed: $($result.Message)"
            }
        }
        catch {
            $errorMessage = "Send-EventToLogAnalytics - Failed to process event of type $EventType using universal DCR module. Error: $($_.Exception.Message)"
            if ($_.Exception.InnerException) {
                $errorMessage += " Inner Exception: $($_.Exception.InnerException.Message)"
            }
            Write-Error $errorMessage
            throw $errorMessage
        }
    }

    end {
        Write-Debug "Send-EventToLogAnalytics - Completed processing event of type $EventType"
    }
}
