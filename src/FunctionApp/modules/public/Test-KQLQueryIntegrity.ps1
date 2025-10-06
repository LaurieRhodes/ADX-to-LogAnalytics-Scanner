function Test-KQLQueryIntegrity {
    <#
    .SYNOPSIS
        Tests KQL query integrity to identify potential processing issues
    
    .PARAMETER Query
        The KQL query to test
    
    .PARAMETER Source
        Source of the query for context
    
    .PARAMETER InstanceId
        Instance identifier for logging
    
    .OUTPUTS
        Hashtable with test results and recommendations
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Query,
        
        [Parameter(Mandatory=$false)]
        [string]$Source = "Unknown",
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    $results = @{
        IsValid = $true
        Issues = @()
        Recommendations = @()
        Metrics = @{
            Length = $Query.Length
            LineCount = ($Query -split "`n").Count
            PipeCount = ([regex]::Matches($Query, '\|')).Count
            HasNewlineTerminator = $Query.EndsWith("`n")
        }
    }
    
    try {
        # Test 1: Basic structure validation
        if ([string]::IsNullOrWhiteSpace($Query)) {
            $results.Issues += "Query is empty or whitespace-only"
            $results.IsValid = $false
        }
        
        # Test 2: Newline terminator check (legacy Query Pack bug)
        if (-not $Query.EndsWith("`n") -and $Query.Length -gt 0) {
            $results.Issues += "Query missing newline terminator (Query Pack legacy bug)"
            $results.Recommendations += "Add newline terminator to prevent processing failures"
        }
        
        # Test 3: Unicode escape sequence detection
        $unicodePattern = '\\u[0-9A-Fa-f]{4}'
        if ([regex]::IsMatch($Query, $unicodePattern)) {
            $results.Issues += "Query contains Unicode escape sequences"
            $results.Recommendations += "Format Unicode escape sequences before processing"
        }
        
        # Test 4: Mixed line ending detection
        $hasWindows = $Query.Contains("`r`n")
        $hasUnix = $Query.Contains("`n") -and -not $Query.Contains("`r`n")
        $hasMac = $Query.Contains("`r") -and -not $Query.Contains("`r`n")
        
        if (($hasWindows -and $hasUnix) -or ($hasWindows -and $hasMac) -or ($hasUnix -and $hasMac)) {
            $results.Issues += "Query contains mixed line endings"
            $results.Recommendations += "Format to consistent line endings"
        }
        
        # Test 5: Excessive whitespace detection
        if ([regex]::IsMatch($Query, '\s{10,}')) {
            $results.Issues += "Query contains excessive whitespace sequences"
            $results.Recommendations += "Format whitespace for better readability"
        }
        
        # Test 6: Basic KQL structure validation
        if ($Query.Length -gt 20 -and -not $Query.Contains('|')) {
            $results.Issues += "Long query without pipe operators - possibly malformed"
        }
        
        # Test 7: Potential encoding issues
        if ($Query.Contains('�')) {
            $results.Issues += "Query contains replacement characters (encoding issues)"
            $results.IsValid = $false
        }
        
        Write-Debug "[$InstanceId] Test-KQLQueryIntegrity - Tested $Source query: $($results.Issues.Count) issues found"
        
        return $results
    }
    catch {
        Write-Error "[$InstanceId] Test-KQLQueryIntegrity - Failed to test query integrity: $($_.Exception.Message)"
        $results.IsValid = $false
        $results.Issues += "Integrity test failed: $($_.Exception.Message)"
        return $results
    }
}
