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
        # The module may throw benign errors about assembly paths in Azure Functions
        $previousErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'SilentlyContinue'
            Import-Module powershell-yaml -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            $ErrorActionPreference = $previousErrorActionPreference
            
            # Verify the module loaded successfully by checking for ConvertFrom-Yaml
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
