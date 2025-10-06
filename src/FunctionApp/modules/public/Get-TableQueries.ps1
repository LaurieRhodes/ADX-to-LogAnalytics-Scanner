function Get-TableQueries {
    <#
    .SYNOPSIS
        Retrieves KQL queries for specific table types from YAML configuration and/or Query Pack
    
    .PARAMETER TableName
        Name of the table to get queries for (e.g., 'Syslog', 'AWSCloudTrail')
    
    .PARAMETER StartTime
        Start time for query time window (ISO 8601 format)
    
    .PARAMETER EndTime  
        End time for query time window (ISO 8601 format)
        
    .PARAMETER ConfigPath
        Path to the queries.yaml file (defaults to config/queries.yaml)
        
    .PARAMETER QuerySource
        Strategy for query source selection:
        - "Auto": Use both YAML and Query Pack if available (default)
        - "YamlOnly": Use only YAML configuration
        - "QueryPackOnly": Use only Query Pack
        - "YamlFirst": Use YAML if available, otherwise Query Pack (legacy behavior)
    
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
        [string]$ConfigPath,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Auto", "YamlOnly", "QueryPackOnly", "YamlFirst")]
        [string]$QuerySource = "Auto",
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    try {
        # Resolve YAML config path for Azure Functions environment
        if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
            # Determine Azure Functions root directory
            $functionAppRoot = if ($env:HOME) {
                # Linux Azure Functions
                Join-Path $env:HOME "site\wwwroot"
            } elseif (Test-Path "D:\home\site\wwwroot") {
                # Windows Azure Functions
                "D:\home\site\wwwroot"
            } else {
                # Local development fallback
                $PSScriptRoot
            }
            
            $ConfigPath = Join-Path $functionAppRoot "config\queries.yaml"
            Write-Debug "[$InstanceId][$TableName] Resolved YAML config path: $ConfigPath"
        }
        
        # Check available query sources
        $queryPackId = $env:QUERYPACKID
        $hasQueryPack = -not [string]::IsNullOrWhiteSpace($queryPackId) -and $queryPackId -ne "ignore"
        $yamlConfigExists = Test-Path $ConfigPath
        
        # Log the resolved path for debugging
        if (-not $yamlConfigExists) {
            Write-Warning "[$InstanceId][$TableName] YAML config not found at: $ConfigPath"
        }
        
        # Resolve query source strategy from environment if Auto
        $effectiveQuerySource = if ($QuerySource -eq "Auto") {
            $envStrategy = $env:QUERY_COMBINATION_MODE
            if (-not [string]::IsNullOrWhiteSpace($envStrategy)) {
                $envStrategy
            } else {
                "Both"  # Default to additive approach
            }
        } else {
            $QuerySource
        }
        
        Write-Debug "[$InstanceId][$TableName] Query source strategy: $effectiveQuerySource"
        Write-Debug "[$InstanceId][$TableName] Available sources - YAML: $yamlConfigExists, QueryPack: $hasQueryPack"
        
        $allQueries = @()
        $sourcesSummary = @()
        
        # Get queries based on strategy
        switch ($effectiveQuerySource) {
            "Both" {
                # ADDITIVE APPROACH: Combine queries from both sources
                
                # Get YAML queries if available
                if ($yamlConfigExists) {
                    try {
                        $yamlQueries = Get-TableQueriesFromYaml -TableName $TableName -StartTime $StartTime -EndTime $EndTime -ConfigPath $ConfigPath -InstanceId $InstanceId
                        $allQueries += $yamlQueries
                        $sourcesSummary += "YAML($($yamlQueries.Count))"
                        Write-Information "[$InstanceId][$TableName] Retrieved $($yamlQueries.Count) queries from YAML"
                    }
                    catch {
                        Write-Warning "[$InstanceId][$TableName] Failed to retrieve YAML queries: $($_.Exception.Message)"
                        # Continue with Query Pack even if YAML fails
                    }
                }
                
                # Get Query Pack queries if available
                if ($hasQueryPack) {
                    try {
                        $queryPackQueries = Get-TableQueriesFromQueryPack -TableName $TableName -StartTime $StartTime -EndTime $EndTime -QueryPackId $queryPackId -InstanceId $InstanceId
                        $allQueries += $queryPackQueries
                        $sourcesSummary += "QueryPack($($queryPackQueries.Count))"
                        Write-Information "[$InstanceId][$TableName] Retrieved $($queryPackQueries.Count) queries from Query Pack"
                    }
                    catch {
                        Write-Warning "[$InstanceId][$TableName] Failed to retrieve Query Pack queries: $($_.Exception.Message)"
                        # Continue with YAML queries even if Query Pack fails
                    }
                }
                
                # Remove duplicates (YAML takes priority over Query Pack)
                if ($allQueries.Count -gt 0) {
                    $allQueries = Remove-DuplicateQueries -Queries $allQueries -InstanceId $InstanceId -TableName $TableName
                }
            }
            
            "YamlOnly" {
                if ($yamlConfigExists) {
                    $allQueries = Get-TableQueriesFromYaml -TableName $TableName -StartTime $StartTime -EndTime $EndTime -ConfigPath $ConfigPath -InstanceId $InstanceId
                    $sourcesSummary += "YAML($($allQueries.Count))"
                    Write-Debug "[$InstanceId][$TableName] Retrieved $($allQueries.Count) queries from YAML only"
                } else {
                    Write-Warning "[$InstanceId][$TableName] YAML source requested but config file not found: $ConfigPath"
                }
            }
            
            "QueryPackOnly" {
                if ($hasQueryPack) {
                    $allQueries = Get-TableQueriesFromQueryPack -TableName $TableName -StartTime $StartTime -EndTime $EndTime -QueryPackId $queryPackId -InstanceId $InstanceId
                    $sourcesSummary += "QueryPack($($allQueries.Count))"
                    Write-Debug "[$InstanceId][$TableName] Retrieved $($allQueries.Count) queries from Query Pack only"
                } else {
                    Write-Warning "[$InstanceId][$TableName] Query Pack source requested but QUERYPACKID not configured"
                }
            }
            
            "YamlFirst" {
                # Legacy behavior - YAML first, Query Pack fallback
                if ($yamlConfigExists) {
                    $allQueries = Get-TableQueriesFromYaml -TableName $TableName -StartTime $StartTime -EndTime $EndTime -ConfigPath $ConfigPath -InstanceId $InstanceId
                    $sourcesSummary += "YAML($($allQueries.Count))"
                    Write-Debug "[$InstanceId][$TableName] Retrieved $($allQueries.Count) queries from YAML (YamlFirst strategy)"
                } elseif ($hasQueryPack) {
                    $allQueries = Get-TableQueriesFromQueryPack -TableName $TableName -StartTime $StartTime -EndTime $EndTime -QueryPackId $queryPackId -InstanceId $InstanceId
                    $sourcesSummary += "QueryPack($($allQueries.Count))"
                    Write-Debug "[$InstanceId][$TableName] Retrieved $($allQueries.Count) queries from Query Pack (YamlFirst fallback)"
                } else {
                    Write-Warning "[$InstanceId][$TableName] No query sources available for YamlFirst strategy"
                }
            }
        }
        
        # Final summary
        $sourcesText = if ($sourcesSummary.Count -gt 0) { $sourcesSummary -join " + " } else { "None" }
        Write-Information "[$InstanceId][$TableName] ADDITIVE RESULT: $($allQueries.Count) total queries from sources: $sourcesText"
        
        # Add metadata to track source combination
        foreach ($query in $allQueries) {
            if (-not $query.ContainsKey('SourceStrategy')) {
                $query.SourceStrategy = $effectiveQuerySource
            }
            if (-not $query.ContainsKey('SourceCombination')) {
                $query.SourceCombination = $sourcesText
            }
        }
        
        return $allQueries
    }
    catch {
        Write-Error "[$InstanceId][$TableName] Failed to retrieve queries using strategy '$QuerySource': $($_.Exception.Message)"
        throw
    }
}
