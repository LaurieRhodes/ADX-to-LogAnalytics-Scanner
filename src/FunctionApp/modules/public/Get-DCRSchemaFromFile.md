# Get-DCRSchemaFromFile

## Purpose

Loads Data Collection Rule (DCR) schema definitions from JSON files in Microsoft format. This function enables dynamic schema loading for DCR field filtering, ensuring only valid columns are sent to Log Analytics tables while supporting schema evolution and validation.

## Key Concepts

### Microsoft Schema Format Support

Supports the standardized Microsoft nested schema format with Name and Properties structure, providing compatibility with Microsoft's schema definition standards and tooling.

### Dynamic Schema Loading

Loads schema definitions at runtime from JSON files, enabling schema updates without code changes and supporting multiple table types with their specific column definitions.

### DCR Field Filtering Foundation

Provides the column name arrays used by DCR ingestion functions to filter event data, ensuring only schema-compliant fields are transmitted to Log Analytics.

## Parameters

| Parameter     | Type   | Required | Default                    | Description                                                    |
| ------------- | ------ | -------- | -------------------------- | -------------------------------------------------------------- |
| `TableName`   | String | Yes      | -                          | Name of the table to load schema for (e.g., 'Syslog')         |
| `SchemasPath` | String | No       | FunctionApp/schemas        | Path to the schemas directory                                  |

## Return Value

Returns an array of column names or `$null`:

```powershell
# Successful schema load
@("TenantId", "SourceSystem", "TimeGenerated", "Computer", "SeverityLevel", "Facility", "SyslogMessage")

# Schema file not found or invalid
$null
```

## Microsoft Schema Format

The function expects JSON files in Microsoft's standardized format:

```json
{
  "Name": "Syslog",
  "Properties": [
    {"Name": "TenantId", "Type": "guid"},
    {"Name": "SourceSystem", "Type": "string"},
    {"Name": "TimeGenerated", "Type": "datetime"},
    {"Name": "Computer", "Type": "string"},
    {"Name": "SeverityLevel", "Type": "string"},
    {"Name": "Facility", "Type": "string"},
    {"Name": "SyslogMessage", "Type": "string"}
  ]
}
```

## Dependencies

### File System Access

- **Required permissions**: Read access to schema files directory
- **File encoding**: UTF-8 support for international characters
- **Path resolution**: PowerShell path manipulation functions

### JSON Processing

- **ConvertFrom-Json**: PowerShell built-in JSON parsing
- **UTF-8 encoding**: For international schema definitions

## Usage Examples

### Basic Schema Loading

```powershell
# Load schema for Syslog table
$syslogColumns = Get-DCRSchemaFromFile -TableName "Syslog"

if ($syslogColumns) {
    Write-Host "Syslog table has $($syslogColumns.Count) columns:"
    $syslogColumns | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Warning "Syslog schema not found or invalid"
}
```

### Integration with DCR Field Filtering

```powershell
# Use schema loading for DCR field filtering
function Filter-EventDataBySchema {
    param(
        [hashtable]$EventData,
        [string]$TableName
    )
    
    # Load schema for the table
    $allowedColumns = Get-DCRSchemaFromFile -TableName $TableName
    
    if (-not $allowedColumns) {
        Write-Warning "No schema found for $TableName, allowing all fields"
        return $EventData
    }
    
    # Filter event data to only include schema-defined columns
    $filteredData = @{}
    $removedFields = @()
    
    foreach ($field in $EventData.Keys) {
        if ($allowedColumns -contains $field) {
            $filteredData[$field] = $EventData[$field]
        } else {
            $removedFields += $field
        }
    }
    
    if ($removedFields.Count -gt 0) {
        Write-Debug "Filtered out $($removedFields.Count) fields not in $TableName schema: $($removedFields -join ', ')"
    }
    
    return $filteredData
}
```
