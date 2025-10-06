function Test-DCRSchemaAvailability {
    <#
    .SYNOPSIS
        Tests if Microsoft schema files are available for all required tables
    
    .DESCRIPTION
        Validates that Microsoft-format schema files exist for a list of table names.
        Checks both file existence and format validity.
        Useful for startup validation and troubleshooting.
    
    .PARAMETER TableNames
        Array of table names to check
    
    .PARAMETER SchemasPath
        Path to the schemas directory (defaults to relative path from FunctionApp root)
    
    .OUTPUTS
        Hashtable with availability results
    
    .EXAMPLE
        $availability = Test-DCRSchemaAvailability -TableNames @('Syslog', 'SecurityEvent')
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$TableNames,
        
        [Parameter(Mandatory=$false)]
        [string]$SchemasPath
    )
    
    begin {
        # Default schemas path relative to FunctionApp root
        if (-not $SchemasPath) {
            # Get the FunctionApp root directory (parent of modules)
            $functionAppRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            $SchemasPath = Join-Path $functionAppRoot "schemas"
        }
    }
    
    process {
        $results = @{
            SchemasPath = $SchemasPath
            DirectoryExists = (Test-Path $SchemasPath)
            TablesRequested = $TableNames.Count
            TablesAvailable = 0
            TablesMissing = 0
            TablesInvalid = 0
            AvailableTables = @()
            MissingTables = @()
            InvalidTables = @()
            SchemaFiles = @()
            SchemaFormat = "Microsoft (Name/Properties)"
        }
        
        if (-not $results.DirectoryExists) {
            Write-Error "Test-DCRSchemaAvailability - Schemas directory does not exist: $SchemasPath"
            return $results
        }
        
        foreach ($tableName in $TableNames) {
            $schemaFile = Join-Path $SchemasPath "$tableName.json"
            
            if (-not (Test-Path $schemaFile)) {
                $results.TablesMissing++
                $results.MissingTables += $tableName
                $results.SchemaFiles += @{
                    TableName = $tableName
                    FilePath = $schemaFile
                    Available = $false
                    Valid = $false
                    Reason = "File not found"
                }
                continue
            }
            
            # Test schema format validity
            try {
                $schemaContent = Get-Content -Path $schemaFile -Raw -Encoding UTF8
                $schemaDefinition = $schemaContent | ConvertFrom-Json
                
                # Validate Microsoft schema format
                $isValid = $true
                $validationErrors = @()
                
                if (-not $schemaDefinition.Name) {
                    $isValid = $false
                    $validationErrors += "Missing 'Name' property"
                }
                
                if (-not $schemaDefinition.Properties) {
                    $isValid = $false
                    $validationErrors += "Missing 'Properties' array"
                } elseif ($schemaDefinition.Properties.Count -eq 0) {
                    $isValid = $false
                    $validationErrors += "Empty 'Properties' array"
                }
                
                # Check if properties have correct structure
                if ($schemaDefinition.Properties) {
                    $propertiesMissingName = $schemaDefinition.Properties | Where-Object { -not $_.Name }
                    $propertiesMissingType = $schemaDefinition.Properties | Where-Object { -not $_.Type }
                    
                    if ($propertiesMissingName.Count -gt 0) {
                        $isValid = $false
                        $validationErrors += "$($propertiesMissingName.Count) properties missing 'Name'"
                    }
                    
                    if ($propertiesMissingType.Count -gt 0) {
                        $isValid = $false
                        $validationErrors += "$($propertiesMissingType.Count) properties missing 'Type'"
                    }
                }
                
                if ($isValid) {
                    $results.TablesAvailable++
                    $results.AvailableTables += $tableName
                    $results.SchemaFiles += @{
                        TableName = $tableName
                        FilePath = $schemaFile
                        Available = $true
                        Valid = $true
                        PropertiesCount = $schemaDefinition.Properties.Count
                        SchemaTableName = $schemaDefinition.Name
                        Reason = "Valid Microsoft schema format"
                    }
                } else {
                    $results.TablesInvalid++
                    $results.InvalidTables += $tableName
                    $results.SchemaFiles += @{
                        TableName = $tableName
                        FilePath = $schemaFile
                        Available = $true
                        Valid = $false
                        Reason = "Invalid format: $($validationErrors -join ', ')"
                    }
                }
            }
            catch {
                $results.TablesInvalid++
                $results.InvalidTables += $tableName
                $results.SchemaFiles += @{
                    TableName = $tableName
                    FilePath = $schemaFile
                    Available = $true
                    Valid = $false
                    Reason = "Parse error: $($_.Exception.Message)"
                }
            }
        }
        
        if ($results.MissingTables.Count -gt 0) {
            Write-Warning "Test-DCRSchemaAvailability - Missing schemas for: $($results.MissingTables -join ', ')"
        }
        
        if ($results.InvalidTables.Count -gt 0) {
            Write-Warning "Test-DCRSchemaAvailability - Invalid schemas for: $($results.InvalidTables -join ', ')"
        }
        
        return $results
    }
}
