# Get-TableQueries

## Purpose

Retrieves KQL queries for specific table types from YAML configuration files or Azure Log Analytics Query Packs. This function provides a unified interface for query retrieval with automatic fallback between configuration sources and intelligent source selection.

## Key Concepts

### Dual Source Support

Supports both YAML configuration files (preferred) and Azure Log Analytics Query Packs (fallback), enabling flexible query management strategies and migration from legacy Query Pack systems.

### Intelligent Source Selection

Automatically determines the best available query source based on configuration availability and explicit preferences, with YAML taking priority over Query Pack unless overridden.

### Temporal Query Processing

Integrates with temporal query conversion capabilities to automatically adjust query time ranges, supporting incremental data processing scenarios.

## Parameters

| Parameter      | Type    | Required | Default                           | Description                                                    |
| -------------- | ------- | -------- | --------------------------------- | -------------------------------------------------------------- |
| `TableName`    | String  | Yes      | -                                 | Name of the table to get queries for (e.g., 'Syslog')         |
| `StartTime`    | String  | Yes      | -                                 | Start time for query window (ISO 8601 format)                 |
| `EndTime`      | String  | Yes      | -                                 | End time for query window (ISO 8601 format)                   |
| `ConfigPath`   | String  | No       | config/queries.yaml               | Path to the YAML queries configuration file                    |
| `UseQueryPack` | Switch  | No       | $false                            | Force use of Query Pack even if YAML config exists            |
| `InstanceId`   | String  | No       | "unknown"                         | Unique instance identifier for multithreaded logging          |

## Return Value

Returns an array of hashtables with query information:

```powershell
@(
    @{
        Name = "Query Name"
        Description = "Query description"
        Query = "Processed KQL query with time filtering"
        Table = "TableName"
        Source = "YAML" # or "QueryPack"
        OriginalQuery = "Original query before processing"
    }
)
```

## Usage Examples

### Standard Query Retrieval

```powershell
# Get queries for Syslog table from default YAML config
$startTime = "2024-01-15T08:00:00Z"
$endTime = "2024-01-15T09:00:00Z"

$queries = Get-TableQueries -TableName "Syslog" -StartTime $startTime -EndTime $endTime

if ($queries.Count -gt 0) {
    Write-Host "Found $($queries.Count) queries for Syslog table"
    
    foreach ($query in $queries) {
        Write-Host "Query: $($query.Name)"
        Write-Host "Source: $($query.Source)"
        Write-Host "Description: $($query.Description)"
        Write-Host "KQL: $($query.Query)"
        Write-Host "---"
    }
} else {
    Write-Warning "No queries found for Syslog table"
}
```

### Multi-Table Query Retrieval

```powershell
# Retrieve queries for multiple tables
$tableNames = @("Syslog", "SecurityEvent", "AWSCloudTrail", "CustomApp")
$allQueries = @{}

foreach ($tableName in $tableNames) {
    try {
        $tableQueries = Get-TableQueries -TableName $tableName -StartTime $startTime -EndTime $endTime -InstanceId "batch-001"
        
        if ($tableQueries.Count -gt 0) {
            $allQueries[$tableName] = $tableQueries
            Write-Host "✅ $tableName`: $($tableQueries.Count) queries retrieved"
        } else {
            Write-Warning "❌ $tableName`: No queries found"
        }
        
    } catch {
        Write-Error "❌ $tableName`: Query retrieval failed - $($_.Exception.Message)"
    }
}

# Display summary
Write-Host "`n=== QUERY RETRIEVAL SUMMARY ==="
$totalQueries = ($allQueries.Values | Measure-Object -Property Count -Sum).Sum
Write-Host "Total Tables: $($tableNames.Count)"
Write-Host "Tables with Queries: $($allQueries.Count)"
Write-Host "Total Queries: $totalQueries"
```

## Environment Configuration

### Required Environment Variables

```bash
# For Query Pack fallback (optional)
QUERYPACKID=your-query-pack-id-here

# To disable Query Pack fallback
QUERYPACKID=ignore
```

## Dependencies

### File Dependencies

- **Get-TableQueriesFromYaml**: For YAML configuration processing
- **Get-TableQueriesFromQueryPack**: For Query Pack integration
- **Convert-Query**: For temporal query processing (optional)

### Configuration Files

- **queries.yaml**: YAML configuration file with query definitions
- **Query Pack**: Azure Log Analytics Query Pack (optional fallback)
