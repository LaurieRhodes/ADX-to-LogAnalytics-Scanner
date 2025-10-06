function Convert-Query {
    <#
    .SYNOPSIS
        Converts KQL queries by adding temporal filters using ingestion_time() for real-time processing
    
    .DESCRIPTION
        Adds time-based filtering to KQL queries using ingestion_time() for accurate real-time processing.
        ingestion_time() represents when data actually arrived in ADX, ensuring continuous processing without gaps
        caused by event timestamp lag in TimeGenerated fields.
        
        Rationale for _TimeReceived:
        - ingestion_time(): When record arrived in ADX (real-time, reliable)
        - TimeGenerated: When original event occurred (can have significant lag)
        
        For continuous real-time scanning, ingestion_time() ensures data is processed based on availability
        in ADX rather than original event timing, preventing processing gaps.
    
    .PARAMETER Query
        The KQL query to convert
    
    .PARAMETER FromDateTime
        Start time for the query filter (ISO 8601 format) - based on ADX ingestion time
    
    .PARAMETER ToDateTime
        End time for the query filter (ISO 8601 format) - based on ADX ingestion time
    
    .OUTPUTS
        Modified KQL query with _TimeReceived filters applied for real-time processing
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FromDateTime,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ToDateTime
    )

    begin {
        Write-Debug "[Convert-Query] Starting query conversion with ingestion_time() for real-time processing"

        try {
            # Validate and parse datetime parameters
            $parsedFromDate = Get-Date $FromDateTime -ErrorAction Stop
            $parsedToDate = Get-Date $ToDateTime -ErrorAction Stop

            # Ensure dates are in the correct order
            if ($parsedFromDate -gt $parsedToDate) {
                throw "FromDateTime ($FromDateTime) must be earlier than ToDateTime ($ToDateTime)"
            }

            # Format dates in ISO 8601 format for ADX
            $fromDateFormatted = $parsedFromDate.ToUniversalTime().ToString("o")
            $toDateFormatted = $parsedToDate.ToUniversalTime().ToString("o")
            
            Write-Debug "[Convert-Query] Time window: $fromDateFormatted to $toDateFormatted (ADX ingestion time)"
        }
        catch {
            throw "Invalid datetime format: $($_.Exception.Message)"
        }
    }

    process {
        try {
            # Clean and format the query
            $formattedQuery = $Query.Trim()

            # Replace common escape sequences
            $replacements = @{
                '\\r\\n' = "`n"
                '\\n' = "`n"
                '\\u0027' = "'"
                '\\t' = "`t"
            }

            foreach ($key in $replacements.Keys) {
                $formattedQuery = $formattedQuery -replace $key, $replacements[$key]
            }

            # LEGACY: Expected _TimeReceived for real-time processing
            # Ensured we process data based on when it arrived in ADX, not original event time
#            $timeFilter = @"
#| where _TimeReceived >= datetime("$fromDateFormatted")
#| where _TimeReceived < datetime("$toDateFormatted")`n
#"@

# ingestion_time() seems to be a better approach which is agnostic of configurable schema values

            $timeFilter = @"
| where ingestion_time() >= datetime("$fromDateFormatted")
| where ingestion_time() < datetime("$toDateFormatted")`n
"@


            Write-Debug "[Convert-Query] _TimeReceived filter created for real-time processing: $timeFilter"

            # Replace any legacy TimeGenerated references with _TimeReceived for consistency
            # This ensures all time filtering uses ADX ingestion time, not event time
            if ($formattedQuery -match '\bTimeGenerated\b') {
                Write-Debug "[Convert-Query] Found TimeGenerated reference - this will be preserved for projection but not used for filtering"
                # Note: We don't replace TimeGenerated in projections as it may be needed for output
                # Only time filtering uses _TimeReceived
            }

            # Find the best position to insert the time filter
            $pipeIndex = $formattedQuery.IndexOf('|')
            $firstNewLine = $formattedQuery.IndexOf("`n")

            if ($pipeIndex -eq -1) {
                # No pipe found, check if query contains a table name
                if ($firstNewLine -eq -1) {
                    # Single line query, just append
                    $resultQuery = "$formattedQuery$timeFilter"
                } else {
                    # Multi-line query without pipe, insert after first line
                    $resultQuery = $formattedQuery.Insert($firstNewLine + 1, $timeFilter)
                }
            } else {
                # Insert time filter before first pipe
                $resultQuery = $formattedQuery.Insert($pipeIndex, $timeFilter)
            }

            Write-Debug $resultQuery
            
            return $resultQuery.Trim()
        }
        catch {
            $errorMessage = "[Convert-Query] Failed to convert query: $($_.Exception.Message)"
            if ($_.Exception.InnerException) {
                $errorMessage += " Inner Exception: $($_.Exception.InnerException.Message)"
            }
            Write-Error $errorMessage
            throw $errorMessage
        }
    }
}
