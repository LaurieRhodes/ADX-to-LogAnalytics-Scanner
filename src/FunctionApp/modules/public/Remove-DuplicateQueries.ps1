function Remove-DuplicateQueries {
    <#
    .SYNOPSIS
        Removes duplicate queries giving priority to YAML sources over Query Pack sources
    
    .PARAMETER Queries
        Array of query objects to deduplicate
    
    .PARAMETER InstanceId
        Instance identifier for logging
    
    .PARAMETER TableName
        Table name for logging context
    
    .OUTPUTS
        Array of deduplicated queries
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Queries,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown",
        
        [Parameter(Mandatory=$false)]
        [string]$TableName = "unknown"
    )
    
    if ($Queries.Count -le 1) {
        return $Queries
    }
    
    $uniqueQueries = @{}
    $duplicatesFound = 0
    $yamlPrioritized = 0
    
    # Group queries by name and prioritize YAML over Query Pack
    foreach ($query in $Queries) {
        $queryName = $query.Name
        $querySource = $query.Source
        
        if ($uniqueQueries.ContainsKey($queryName)) {
            $duplicatesFound++
            $existingSource = $uniqueQueries[$queryName].Source
            
            # YAML takes priority over QueryPack
            if ($existingSource -eq "QueryPack" -and $querySource -eq "YAML") {
                $uniqueQueries[$queryName] = $query
                $yamlPrioritized++
                Write-Debug "[$InstanceId][$TableName] Duplicate query '$queryName': YAML overrode QueryPack version"
            } elseif ($existingSource -eq "YAML" -and $querySource -eq "QueryPack") {
                # Keep existing YAML version, ignore QueryPack duplicate
                Write-Debug "[$InstanceId][$TableName] Duplicate query '$queryName': Kept YAML version, ignored QueryPack version"
            } else {
                # Same source type - keep first occurrence
                Write-Debug "[$InstanceId][$TableName] Duplicate query '$queryName': Kept first occurrence from $existingSource"
            }
        } else {
            $uniqueQueries[$queryName] = $query
        }
    }
    
    $finalQueries = @($uniqueQueries.Values)
    
    if ($duplicatesFound -gt 0) {
        Write-Information "[$InstanceId][$TableName] Deduplication: Found $duplicatesFound duplicates, $yamlPrioritized YAML overrides applied"
        Write-Information "[$InstanceId][$TableName] Final count: $($finalQueries.Count) unique queries (from $($Queries.Count) total)"
    }
    
    return $finalQueries
}
