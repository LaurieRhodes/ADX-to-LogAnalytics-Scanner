function Get-DCRSchemaFromFile {
    <#
    .SYNOPSIS
        Loads DCR schema definition from JSON file (Microsoft Format)
    
    .DESCRIPTION
        Dynamically loads table schema from Microsoft-format JSON files in the schemas directory.
        Supports the new Microsoft nested schema format:
        {
          "Name": "TableName",
          "Properties": [
            {"Name": "Column1", "Type": "string"},
            {"Name": "Column2", "Type": "datetime"}
          ]
        }
        Returns an array of column names for DCR field filtering.
    
    .PARAMETER TableName
        Name of the table to load schema for (e.g., 'Syslog', 'SecurityEvent')
    
    .PARAMETER SchemasPath
        Path to the schemas directory (defaults to relative path from FunctionApp root)
    
    .OUTPUTS
        Array of column names, or $null if schema file not found
    
    .EXAMPLE
        $columns = Get-DCRSchemaFromFile -TableName 'Syslog'
        # Returns: @("TenantId", "SourceSystem", "TimeGenerated", ...)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$false)]
        [string]$SchemasPath
    )
    
    try {
        # If SchemasPath not provided, construct it
        if (-not $SchemasPath) {
            # For Azure Functions, use the known path structure
            $functionAppRoot = "C:\home\site\wwwroot"
            $SchemasPath = Join-Path $functionAppRoot "schemas"
            
            Write-Debug "Get-DCRSchemaFromFile - Using Azure Functions path: $SchemasPath"
        }
        
        # Validate the constructed path
        Write-Debug "Get-DCRSchemaFromFile - TableName: $TableName"
        Write-Debug "Get-DCRSchemaFromFile - SchemasPath: '$SchemasPath'"
        Write-Debug "Get-DCRSchemaFromFile - SchemasPath length: $($SchemasPath.Length)"
        Write-Debug "Get-DCRSchemaFromFile - SchemasPath exists: $(Test-Path $SchemasPath)"
        
        # Check if schemas path is empty or null
        if ([string]::IsNullOrWhiteSpace($SchemasPath)) {
            Write-Warning "Get-DCRSchemaFromFile - SchemasPath is null or empty"
            return $null
        }
        
        # Check if schemas directory exists
        if (-not (Test-Path $SchemasPath)) {
            Write-Debug "Get-DCRSchemaFromFile - Schemas directory does not exist: $SchemasPath"
            return $null
        }
        
        # Construct schema file path
        $schemaFile = Join-Path $SchemasPath "$TableName.json"
        Write-Debug "Get-DCRSchemaFromFile - Schema file path: $schemaFile"
        
        # Check if schema file exists
        if (-not (Test-Path $schemaFile)) {
            Write-Debug "Get-DCRSchemaFromFile - Schema file not found: $schemaFile"
            return $null
        }
        
        Write-Debug "Get-DCRSchemaFromFile - Reading schema file: $schemaFile"
        
        # Read and parse schema file
        $schemaContent = Get-Content -Path $schemaFile -Raw -Encoding UTF8
        $schemaDefinition = $schemaContent | ConvertFrom-Json
        
        # Validate Microsoft schema format
        if (-not $schemaDefinition.Name) {
            Write-Warning "Get-DCRSchemaFromFile - Invalid Microsoft schema format: missing 'Name' property"
            return $null
        }
        
        if (-not $schemaDefinition.Properties) {
            Write-Warning "Get-DCRSchemaFromFile - Invalid Microsoft schema format: missing 'Properties' array"
            return $null
        }
        
        # Verify the table name matches
        if ($schemaDefinition.Name -ne $TableName) {
            Write-Warning "Get-DCRSchemaFromFile - Schema table name mismatch: expected '$TableName', found '$($schemaDefinition.Name)'"
        }
        
        # Extract column names from Properties array
        $columnNames = @()
        foreach ($property in $schemaDefinition.Properties) {
            if ($property.Name) {
                $columnNames += $property.Name
            } else {
                Write-Warning "Get-DCRSchemaFromFile - Schema property missing Name: $($property | ConvertTo-Json -Compress)"
            }
        }
        
        Write-Debug "Get-DCRSchemaFromFile - Successfully loaded $($columnNames.Count) columns for table $TableName"
        return $columnNames
    }
    catch {
        Write-Warning "Get-DCRSchemaFromFile - Failed to load schema for table $TableName`: $($_.Exception.Message)"
        Write-Debug "Get-DCRSchemaFromFile - Exception details: $($_.Exception | Format-List * | Out-String)"
        return $null
    }
}