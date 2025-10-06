function Get-DCRSchemaProperties {
    <#
    .SYNOPSIS
        Gets just the Properties array from Microsoft schema format
    
    .DESCRIPTION
        Returns only the Properties array from the Microsoft schema definition.
        Each property contains Name and Type fields.
    
    .PARAMETER TableName
        Name of the table to load schema for
    
    .PARAMETER SchemasPath
        Path to the schemas directory (defaults to relative path from FunctionApp root)
    
    .OUTPUTS
        Array of property objects with Name and Type
    
    .EXAMPLE
        $properties = Get-DCRSchemaProperties -TableName 'Syslog'
        # Returns: @(@{Name="TenantId"; Type="guid"}, @{Name="TimeGenerated"; Type="datetime"}, ...)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$false)]
        [string]$SchemasPath
    )
    
    try {
        $schemaDefinition = Get-DCRSchemaDetails -TableName $TableName -SchemasPath $SchemasPath
        
        if ($schemaDefinition -and $schemaDefinition.Properties) {
            return $schemaDefinition.Properties
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Get-DCRSchemaProperties - Failed to get properties for table $TableName`: $($_.Exception.Message)"
        return $null
    }
}
