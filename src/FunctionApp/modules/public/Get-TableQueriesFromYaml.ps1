function Get-TableQueriesFromYaml {
    <#
    .SYNOPSIS
        Retrieves KQL queries for a specific table from YAML configuration
    
    .DESCRIPTION
        Reads queries from queries.yaml file and formats them.
        Note: Time window filtering is handled separately by Convert-Query function.
    
    .PARAMETER TableName
        Name of the table to get queries for (e.g., 'Syslog', 'AWSCloudTrail')
    
    .PARAMETER StartTime
        Start time for query time window (ISO 8601 format) - passed through for metadata
    
    .PARAMETER EndTime
        End time for query time window (ISO 8601 format) - passed through for metadata
        
    .PARAMETER ConfigPath
        Path to the queries.yaml file (defaults to config/queries.yaml)
        
    .PARAMETER InstanceId
        Unique instance identifier for multithreaded logging
    
    .OUTPUTS
        Array of hashtables with Name, Description, Query, Table, Source, and OriginalQuery properties
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        [string]$StartTime,
        
        [Parameter(Mandatory=$true)]
        [string]$EndTime,
        
        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot\..\config\queries.yaml",
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    try {
        Write-Debug "[$InstanceId][$TableName] Reading YAML queries from: $ConfigPath"
        
        # Verify file exists
        if (-not (Test-Path $ConfigPath)) {
            Write-Warning "[$InstanceId][$TableName] YAML config file not found: $ConfigPath"
            return @()
        }
        
        # Use updated Get-KQLQueries function in YAML mode (no QueryPackID)
        try {
            $yamlQueries = Get-KQLQueries -SupportedTables @($TableName) -ConfigPath $ConfigPath -InstanceId $InstanceId
        }
        catch {
            Write-Warning "[$InstanceId][$TableName] Failed to parse YAML config: $($_.Exception.Message)"
            return @()
        }
        
        if ($null -eq $yamlQueries -or $yamlQueries.Count -eq 0) {
            Write-Debug "[$InstanceId][$TableName] No queries found in YAML for table: $TableName"
            return @()
        }
        
        Write-Debug "[$InstanceId][$TableName] Found $($yamlQueries.Count) queries in YAML for table"
        
        # Format queries (time window filtering will be added later by Convert-Query)
        $formattedQueries = @()
        foreach ($query in $yamlQueries) {
            try {
                # Format the query text (normalize formatting only, no time filters)
                $formattedQueryText = if (Get-Command -Name "Format-KQLQuery" -ErrorAction SilentlyContinue) {
                    Format-KQLQuery -Query $query.query -Source "YAML" -InstanceId $InstanceId
                } else {
                    $query.query
                }
                
                $formattedQueries += @{
                    Name = $query.name
                    Description = $query.description
                    Query = $formattedQueryText
                    Table = $TableName
                    Source = "YAML"
                    OriginalQuery = $query.query
                }
                
                Write-Debug "[$InstanceId][$TableName] Formatted YAML query: $($query.name)"
            }
            catch {
                Write-Warning "[$InstanceId][$TableName] Failed to format YAML query '$($query.name)': $($_.Exception.Message)"
                # Continue processing other queries
            }
        }
        
        Write-Information "[$InstanceId][$TableName] Retrieved $($formattedQueries.Count) queries from YAML"
        return $formattedQueries
    }
    catch {
        $errorMsg = "Failed to retrieve queries from YAML for table '$TableName': $($_.Exception.Message)"
        Write-Error "[$InstanceId][$TableName] $errorMsg"
        throw $errorMsg
    }
}
