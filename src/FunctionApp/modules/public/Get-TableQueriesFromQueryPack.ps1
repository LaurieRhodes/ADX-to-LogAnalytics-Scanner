function Get-TableQueriesFromQueryPack {
    <#
    .SYNOPSIS
        Retrieves KQL queries for a specific table from Azure Monitor Query Pack
    
    .DESCRIPTION
        Queries the Azure Monitor Query Pack REST API to retrieve queries tagged for a specific table.
        This is an OPTIONAL feature - failures will be logged but won't throw exceptions.
    
    .PARAMETER TableName
        Name of the table to get queries for (e.g., 'Syslog', 'AWSCloudTrail')
    
    .PARAMETER StartTime
        Start time for query time window (ISO 8601 format)
    
    .PARAMETER EndTime
        End time for query time window (ISO 8601 format)
        
    .PARAMETER QueryPackId
        The Azure Resource ID of the Query Pack (e.g., /subscriptions/.../queryPacks/...)
        
    .PARAMETER InstanceId
        Unique instance identifier for multithreaded logging
    
    .OUTPUTS
        Array of hashtables with Name, Description, Query, Table, Source, and OriginalQuery properties
        Returns empty array if Query Pack is unavailable or inaccessible
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        [string]$StartTime,
        
        [Parameter(Mandatory=$true)]
        [string]$EndTime,
        
        [Parameter(Mandatory=$true)]
        [string]$QueryPackId,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    begin {
        $DebugPreference = "Continue"
        
        # Mitigate Terraform Provider bug that strips leading / from Query Pack ID
        if ($QueryPackId -notmatch '^/') {
            $QueryPackId = '/' + $QueryPackId
            Write-Debug "[$InstanceId][$TableName] Prepended / to QueryPackId"
        }
        
        $resourceURL = "https://management.azure.com"
        $apiVersion = "2019-09-01"
        $formattedQueries = @()
        
        Write-Debug "[$InstanceId][$TableName] Starting Query Pack retrieval for: $QueryPackId"
    }
    
    process {
        try {
            # Get authentication token using existing function
            $clientId = $env:CLIENTID
            if ([string]::IsNullOrWhiteSpace($clientId)) {
                Write-Warning "[$InstanceId][$TableName] Query Pack disabled: CLIENTID environment variable not set"
                return $formattedQueries
            }
            
            Write-Debug "[$InstanceId][$TableName] Requesting token for client: $clientId"
            
            try {
                $token = Get-AzureADToken -resource $resourceURL -clientId $clientId
            }
            catch {
                Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Failed to obtain authentication token - $($_.Exception.Message)"
                return $formattedQueries
            }
            
            if (-not $token) {
                Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Failed to obtain authentication token"
                return $formattedQueries
            }
            
            # Prepare REST API request
            $authHeader = @{
                'Authorization' = "Bearer $token"
                'Content-Type' = 'application/json'
            }
            
            $uri = "{0}{1}/queries/search?api-version={2}&includeBody=True" -f $resourceURL, $QueryPackId, $apiVersion
            Write-Debug "[$InstanceId][$TableName] Query Pack URI: $uri"
            
            # Execute REST API call with proper error handling
            try {
                $response = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -ErrorAction Stop
            }
            catch {
                # Handle specific HTTP status codes gracefully
                $statusCode = $_.Exception.Response.StatusCode.value__
                $statusDescription = $_.Exception.Response.StatusDescription
                
                switch ($statusCode) {
                    403 {
                        Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Access denied (403 Forbidden). Check managed identity permissions to Query Pack: $QueryPackId"
                    }
                    404 {
                        Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Query Pack not found (404). Verify QueryPackId: $QueryPackId"
                    }
                    401 {
                        Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Authentication failed (401 Unauthorized)"
                    }
                    default {
                        Write-Warning "[$InstanceId][$TableName] Query Pack disabled: HTTP $statusCode $statusDescription"
                    }
                }
                
                Write-Debug "[$InstanceId][$TableName] Query Pack error details: $($_.Exception.Message)"
                return $formattedQueries
            }
            
            if (-not $response.value) {
                Write-Warning "[$InstanceId][$TableName] No queries found in Query Pack"
                return $formattedQueries
            }
            
            Write-Debug "[$InstanceId][$TableName] Query Pack returned $($response.value.Count) total queries"
            
            # Filter queries that match the table name in tags/labels
            $matchingQueries = $response.value | Where-Object { 
                $_.properties.tags.labels -contains $TableName 
            }
            
            Write-Debug "[$InstanceId][$TableName] Found $($matchingQueries.Count) queries matching table"
            
            # Format each matching query with time windows
            foreach ($query in $matchingQueries) {
                try {
                    # Format query with time windows using existing Format-KQLQuery function
                    $formattedQuery = Format-KQLQuery -Query $query.properties.body -StartTime $StartTime -EndTime $EndTime
                    
                    $queryObject = @{
                        Name = if ($query.properties.displayName) { $query.properties.displayName } else { $query.name }
                        Description = if ($query.properties.description) { $query.properties.description } else { "Query from Query Pack" }
                        Query = $formattedQuery
                        Table = $TableName
                        Source = "QueryPack"
                        OriginalQuery = $query.properties.body
                        QueryPackId = $QueryPackId
                        QueryId = $query.id
                    }
                    
                    $formattedQueries += $queryObject
                    Write-Debug "[$InstanceId][$TableName] Formatted query: $($queryObject.Name)"
                }
                catch {
                    Write-Warning "[$InstanceId][$TableName] Failed to format query $($query.name): $($_.Exception.Message)"
                    # Continue processing other queries
                }
            }
        }
        catch {
            # Catch-all for any unexpected errors - don't throw, just warn
            Write-Warning "[$InstanceId][$TableName] Query Pack disabled: Unexpected error - $($_.Exception.Message)"
            Write-Debug "[$InstanceId][$TableName] Stack trace: $($_.ScriptStackTrace)"
            return $formattedQueries
        }
    }
    
    end {
        if ($formattedQueries.Count -gt 0) {
            Write-Information "[$InstanceId][$TableName] ✓ Retrieved $($formattedQueries.Count) queries from Query Pack"
        } else {
            Write-Debug "[$InstanceId][$TableName] Query Pack returned 0 queries (optional feature)"
        }
        return $formattedQueries
    }
}
