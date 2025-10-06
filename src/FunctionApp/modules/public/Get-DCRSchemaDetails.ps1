function Get-DCRSchemaDetails {
    <#
    .SYNOPSIS
        Loads complete DCR schema details from JSON file (Microsoft Format)
    
    .DESCRIPTION
        Returns the complete Microsoft schema definition including table name and properties.
        Supports the new Microsoft nested schema format with Name and Type for each property.
        Useful for validation and detailed schema information.
    
    .PARAMETER TableName
        Name of the table to load schema for
    
    .PARAMETER SchemasPath
        Path to the schemas directory (defaults to relative path from FunctionApp root)
    
    .OUTPUTS
        PSCustomObject with Microsoft schema structure including Name and Properties
    
    .EXAMPLE
        $schema = Get-DCRSchemaDetails -TableName 'Syslog'
        # Returns: @{Name="Syslog"; Properties=@(@{Name="TenantId"; Type="guid"}, ...)}
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
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
        try {
            # Construct schema file path
            $schemaFile = Join-Path $SchemasPath "$TableName.json"
            
            # Check if schema file exists
            if (-not (Test-Path $schemaFile)) {
                return $null
            }
            
            # Read and parse schema file
            $schemaContent = Get-Content -Path $schemaFile -Raw -Encoding UTF8
            $schemaDefinition = $schemaContent | ConvertFrom-Json
            
            # Validate Microsoft schema format
            if (-not $schemaDefinition.Name) {
                Write-Warning "Get-DCRSchemaDetails - Invalid Microsoft schema format: missing 'Name' property"
                return $null
            }
            
            if (-not $schemaDefinition.Properties) {
                Write-Warning "Get-DCRSchemaDetails - Invalid Microsoft schema format: missing 'Properties' array"
                return $null
            }
            
            return $schemaDefinition
        }
        catch {
            $errorMessage = "Get-DCRSchemaDetails - Failed to load detailed Microsoft schema for table $TableName`: $($_.Exception.Message)"
            Write-Error $errorMessage
            return $null
        }
    }
}
