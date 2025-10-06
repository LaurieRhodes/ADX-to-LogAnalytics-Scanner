function Get-KQLQueries {
    <#
    .SYNOPSIS
        Retrieves KQL queries from Azure Log Analytics Query Pack OR YAML configuration
    
    .DESCRIPTION
        Dual-mode function that can retrieve queries from:
        1. Azure Log Analytics Query Pack using Managed Identity (when QueryPackID provided)
        2. Local YAML configuration file (when ConfigPath provided)
        
        Query Pack mode includes comprehensive formatting to prevent legacy bugs.
    
    .PARAMETER QueryPackID
        (Optional) The resource ID of the Log Analytics Query Pack
        If not provided, falls back to YAML configuration
    
    .PARAMETER SupportedTables
        Array of table names to match against query labels/tags (Query Pack mode)
        or to filter from YAML config (YAML mode)
    
    .PARAMETER ClientId
        (Optional) The Client ID of the Managed Identity for authentication
        Required only when using Query Pack mode
    
    .PARAMETER ConfigPath
        (Optional) Path to YAML configuration file
        Defaults to config/queries.yaml
        Used when QueryPackID is not provided
    
    .PARAMETER InstanceId
        Unique instance identifier for multithreaded logging
    
    .OUTPUTS
        Array of objects with table, query, name, description, and source properties
        
    .EXAMPLE
        # Query Pack mode
        Get-KQLQueries -QueryPackID "/subscriptions/.../querypacks/..." -SupportedTables @("Syslog") -ClientId "..."
        
    .EXAMPLE
        # YAML mode
        Get-KQLQueries -SupportedTables @("Syslog") -ConfigPath "config/queries.yaml"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$QueryPackID,

        [Parameter(Mandatory=$true)]
        [string[]]$SupportedTables,

        [Parameter(Mandatory=$false)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot\..\config\queries.yaml",
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )

    try {
        # Determine mode: Query Pack or YAML
        $useQueryPack = -not [string]::IsNullOrWhiteSpace($QueryPackID)
        
        if ($useQueryPack) {
            Write-Debug "[$InstanceId] Get-KQLQueries - MODE: Query Pack"
            return Get-KQLQueriesFromQueryPack -QueryPackID $QueryPackID -SupportedTables $SupportedTables -ClientId $ClientId -InstanceId $InstanceId
        }
        else {
            Write-Debug "[$InstanceId] Get-KQLQueries - MODE: YAML Configuration"
            return Get-KQLQueriesFromYaml -ConfigPath $ConfigPath -SupportedTables $SupportedTables -InstanceId $InstanceId
        }
    }
    catch {
        $errorMessage = "Get-KQLQueries - Error retrieving queries: $($_.Exception.Message)"
        Write-Error "[$InstanceId] $errorMessage"
        throw $errorMessage
    }
}

function Get-KQLQueriesFromQueryPack {
    <#
    .SYNOPSIS
        Internal function to retrieve queries from Azure Log Analytics Query Pack
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$QueryPackID,

        [Parameter(Mandatory=$true)]
        [string[]]$SupportedTables,

        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )

    try {
        Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Starting query retrieval for QueryPackID: $QueryPackID"
        
        # Mitigate Terraform Provider bug that strips leading / from Query Pack ID
        if ($QueryPackID -notmatch '^/') {
            $QueryPackID = '/' + $QueryPackID
            Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Prepended leading slash to QueryPackID: $QueryPackID"
        }

        $resourceURL = "https://management.azure.com"
        $apiVersion = "2019-09-01"
        $outputCollection = @()

        # Get authentication token using the existing Get-AzureADToken function
        Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Requesting token for Management API"
        
        # Check if Get-AzureADToken is available
        if (-not (Get-Command -Name "Get-AzureADToken" -ErrorAction SilentlyContinue)) {
            throw "Get-AzureADToken function not available. ADXDataRetrieval module may not be loaded."
        }
        
        $token = Get-AzureADToken -resource $resourceURL -clientId $ClientId

        if (-not $token) {
            throw "Failed to obtain authentication token for Azure Management API"
        }

        # Prepare request headers
        $authHeader = @{
            'Authorization' = "Bearer $token"
            'Content-Type' = 'application/json'
        }

        $uri = "{0}{1}/queries/search?api-version={2}&includeBody=True" -f $resourceURL, $QueryPackID, $apiVersion
        Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Query Pack URI: $uri"

        # Execute request to get queries from Query Pack
        Write-Information "[$InstanceId] Get-KQLQueriesFromQueryPack - Retrieving queries from Query Pack: $QueryPackID"
        $response = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -TimeoutSec 60

        if (-not $response.value -or $response.value.Count -eq 0) {
            Write-Warning "[$InstanceId] Get-KQLQueriesFromQueryPack - No queries found in Query Pack: $QueryPackID"
            return $outputCollection
        }

        Write-Information "[$InstanceId] Get-KQLQueriesFromQueryPack - Found $($response.value.Count) total queries in Query Pack"

        # Track formatting statistics
        $formattingStats = @{
            TotalQueries = 0
            FormattedQueries = 0
            IssuesDetected = 0
            FailedFormatting = 0
        }

        # Process each query and match with supported tables
        foreach ($query in $response.value) {
            # Check if query has labels/tags that match our supported tables
            $queryLabels = @()
            
            # Query Pack queries store table associations in tags.labels
            if ($query.properties.tags -and $query.properties.tags.labels) {
                $queryLabels = $query.properties.tags.labels
            }
            
            # Find matching tables
            $matchingTables = $SupportedTables | Where-Object { $queryLabels -contains $_ }

            if ($matchingTables.Count -gt 0) {
                foreach ($tableTag in $matchingTables) {
                    Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Processing query '$($query.properties.displayName)' for table: $tableTag"
                    
                    $formattingStats.TotalQueries++
                    
                    # CRITICAL: Apply comprehensive query formatting to prevent legacy bugs
                    try {
                        # First, test the raw query for potential issues
                        $integrityTest = if (Get-Command -Name "Test-KQLQueryIntegrity" -ErrorAction SilentlyContinue) {
                            Test-KQLQueryIntegrity -Query $query.properties.body -Source "QueryPack" -InstanceId $InstanceId
                        } else {
                            @{ Issues = @(); IsValid = $true }
                        }
                        
                        if ($integrityTest.Issues.Count -gt 0) {
                            $formattingStats.IssuesDetected++
                            Write-Warning "[$InstanceId] Get-KQLQueriesFromQueryPack - Query '$($query.properties.displayName)' has integrity issues:"
                            $integrityTest.Issues | ForEach-Object { 
                                Write-Warning "[$InstanceId]   - $_" 
                            }
                        }
                        
                        # Apply formatting to fix issues
                        $formattedQuery = if (Get-Command -Name "Format-KQLQuery" -ErrorAction SilentlyContinue) {
                            Format-KQLQuery -Query $query.properties.body -Source "QueryPack" -InstanceId $InstanceId
                        } else {
                            $query.properties.body
                        }
                        
                        if ($formattedQuery -ne $query.properties.body) {
                            $formattingStats.FormattedQueries++
                            Write-Information "[$InstanceId] Get-KQLQueriesFromQueryPack - Applied formatting to query '$($query.properties.displayName)'"
                        }
                        
                        # Create query object with formatted query
                        $queryObject = @{
                            table = $tableTag
                            query = $formattedQuery
                            name = $query.properties.displayName
                            description = $query.properties.description
                            queryPackId = $query.name
                            source = "QueryPack"
                            originalQueryLength = $query.properties.body.Length
                            formattedQueryLength = $formattedQuery.Length
                            integrityIssues = $integrityTest.Issues
                            hasFormatting = ($formattedQuery -ne $query.properties.body)
                        }

                        $outputCollection += $queryObject
                        Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Successfully processed query '$($query.properties.displayName)' for table: $tableTag"
                    }
                    catch {
                        $formattingStats.FailedFormatting++
                        Write-Error "[$InstanceId] Get-KQLQueriesFromQueryPack - Failed to format query '$($query.properties.displayName)': $($_.Exception.Message)"
                        
                        # Fallback: Use original query but warn about potential issues
                        Write-Warning "[$InstanceId] Get-KQLQueriesFromQueryPack - Using original (non-formatted) query - may cause processing issues"
                        
                        $queryObject = @{
                            table = $tableTag
                            query = $query.properties.body
                            name = $query.properties.displayName
                            description = $query.properties.description
                            queryPackId = $query.name
                            source = "QueryPack"
                            formattingError = $_.Exception.Message
                            hasFormatting = $false
                        }

                        $outputCollection += $queryObject
                    }
                }
            } else {
                Write-Debug "[$InstanceId] Get-KQLQueriesFromQueryPack - Query '$($query.properties.displayName)' has no matching table labels. Labels: $($queryLabels -join ', ')"
            }
        }

        # Log formatting statistics
        Write-Information "[$InstanceId] Get-KQLQueriesFromQueryPack - Query formatting statistics:"
        Write-Information "[$InstanceId]   Total processed: $($formattingStats.TotalQueries)"
        Write-Information "[$InstanceId]   Formatted: $($formattingStats.FormattedQueries)"
        Write-Information "[$InstanceId]   Issues detected: $($formattingStats.IssuesDetected)" 
        Write-Information "[$InstanceId]   Failed formatting: $($formattingStats.FailedFormatting)"

        Write-Information "[$InstanceId] Get-KQLQueriesFromQueryPack - Retrieved $($outputCollection.Count) matching queries for tables: $($SupportedTables -join ', ')"
        return $outputCollection
    }
    catch {
        $errorMessage = "Get-KQLQueriesFromQueryPack - Error retrieving queries from Query Pack '$QueryPackID': $($_.Exception.Message)"
        Write-Error "[$InstanceId] $errorMessage"
        
        # Include more details if available
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Error "[$InstanceId] Get-KQLQueriesFromQueryPack - HTTP Status Code: $statusCode"
        }
        
        throw $errorMessage
    }
}

function Get-KQLQueriesFromYaml {
    <#
    .SYNOPSIS
        Internal function to retrieve queries from YAML configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath,
        
        [Parameter(Mandatory=$false)]
        [string[]]$SupportedTables,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    try {
        Write-Debug "[$InstanceId] Get-KQLQueriesFromYaml - Reading YAML configuration from: $ConfigPath"
        
        # Verify file exists
        if (-not (Test-Path $ConfigPath)) {
            throw "YAML configuration file not found: $ConfigPath"
        }
        
# Ensure powershell-yaml module is loaded
        if (-not (Get-Module -Name powershell-yaml -ListAvailable)) {
            throw "powershell-yaml module not available. Please add 'powershell-yaml' = '0.4.7' to requirements.psd1"
        }
        
        # Import module with error suppression for Azure Functions environment
        $previousErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'SilentlyContinue'
            Import-Module powershell-yaml -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            $ErrorActionPreference = $previousErrorActionPreference
            
            # Verify the module loaded
            if (-not (Get-Command -Name ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
                throw "powershell-yaml module failed to load ConvertFrom-Yaml cmdlet"
            }
        }
        catch {
            $ErrorActionPreference = $previousErrorActionPreference
            throw "Failed to import powershell-yaml module: $($_.Exception.Message)"
        }
        
        # Read YAML content
        $yamlContent = Get-Content -Path $ConfigPath -Raw
        
        if ([string]::IsNullOrWhiteSpace($yamlContent)) {
            throw "YAML configuration file is empty: $ConfigPath"
        }
        
        # Parse YAML
        try {
            $parsedYaml = ConvertFrom-Yaml -Yaml $yamlContent
        }
        catch {
            throw "Failed to parse YAML content: $($_.Exception.Message)"
        }
        
        if ($null -eq $parsedYaml) {
            throw "YAML parsing returned null result"
        }
        
        # Validate structure
        if ($parsedYaml -isnot [System.Collections.IDictionary]) {
            throw "YAML root must be a dictionary/hashtable with table names as keys"
        }
        
        # Convert to structured format
        $outputCollection = @()
        $totalQueries = 0
        
        # Filter by supported tables if specified
        $tablesToProcess = if ($SupportedTables -and $SupportedTables.Count -gt 0) {
            $parsedYaml.Keys | Where-Object { $SupportedTables -contains $_ }
        } else {
            $parsedYaml.Keys
        }
        
        foreach ($tableName in $tablesToProcess) {
            $tableQueries = $parsedYaml[$tableName]
            
            if ($null -eq $tableQueries) {
                Write-Warning "[$InstanceId] Get-KQLQueriesFromYaml - Table '$tableName' has null queries, skipping"
                continue
            }
            
            # Ensure queries is an array
            if ($tableQueries -isnot [System.Collections.IList]) {
                Write-Warning "[$InstanceId] Get-KQLQueriesFromYaml - Table '$tableName' queries are not an array, wrapping in array"
                $tableQueries = @($tableQueries)
            }
            
            foreach ($query in $tableQueries) {
                # Validate query structure
                if ($null -eq $query.query -or [string]::IsNullOrWhiteSpace($query.query)) {
                    Write-Warning "[$InstanceId] Get-KQLQueriesFromYaml - Skipping query with missing 'query' field: $($query.name)"
                    continue
                }
                
                # Create normalized query object
                $queryObject = @{
                    table = $tableName
                    name = if ($query.name) { $query.name } else { "Unnamed Query" }
                    description = if ($query.description) { $query.description } else { "" }
                    query = $query.query.Trim()
                    source = "YAML"
                }
                
                $outputCollection += $queryObject
                $totalQueries++
            }
            
            Write-Debug "[$InstanceId] Get-KQLQueriesFromYaml - Loaded $($tableQueries.Count) queries for table: $tableName"
        }
        
        Write-Information "[$InstanceId] Get-KQLQueriesFromYaml - Successfully parsed YAML config: $($tablesToProcess.Count) tables, $totalQueries total queries"
        
        return $outputCollection
    }
    catch {
        $errorMsg = "Get-KQLQueriesFromYaml - Failed to read YAML configuration from '$ConfigPath': $($_.Exception.Message)"
        Write-Error "[$InstanceId] $errorMsg"
        throw $errorMsg
    }
}
