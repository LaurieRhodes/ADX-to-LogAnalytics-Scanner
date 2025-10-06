function Format-KQLQuery {
    <#
    .SYNOPSIS
        Formats KQL queries to prevent common string handling issues
    
    .DESCRIPTION
        Addresses common issues with KQL queries from different sources including:
        - Missing newline terminators (Query Pack legacy bug)
        - Inconsistent line endings (Windows vs Unix)
        - Extra whitespace and formatting issues
        - Unicode escape sequences
        - Invalid characters that can break processing
    
    .PARAMETER Query
        The raw KQL query to format
    
    .PARAMETER Source
        Source of the query (YAML, QueryPack, etc.) for logging context
    
    .PARAMETER InstanceId
        Instance identifier for logging correlation
    
    .OUTPUTS
        Formatted KQL query string
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$Query,
        
        [Parameter(Mandatory=$false)]
        [string]$Source = "Unknown",
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )
    
    try {
        # Handle null or empty queries
        if ([string]::IsNullOrEmpty($Query)) {
            Write-Warning "[$InstanceId] Format-KQLQuery - Empty query provided from source: $Source"
            return ""
        }
        
        Write-Debug "[$InstanceId] Format-KQLQuery - Starting formatting for $Source query (length: $($Query.Length))"
        
        # Step 1: Handle common Unicode escape sequences
        $formattedQuery = $Query
        
        # Common Unicode escape sequences that can break KQL processing
        $unicodeReplacements = @{
            '\\u0027' = "'"      # Single quote
            '\\u0022' = '"'      # Double quote
            '\\u003A' = ':'      # Colon
            '\\u003D' = '='      # Equals
            '\\u002C' = ','      # Comma
            '\\u003B' = ';'      # Semicolon
            '\\u007C' = '|'      # Pipe
            '\\u0028' = '('      # Left parenthesis
            '\\u0029' = ')'      # Right parenthesis
            '\\u005B' = '['      # Left bracket
            '\\u005D' = ']'      # Right bracket
        }
        
        foreach ($unicode in $unicodeReplacements.Keys) {
            if ($formattedQuery.Contains($unicode)) {
                $formattedQuery = $formattedQuery -replace [regex]::Escape($unicode), $unicodeReplacements[$unicode]
                Write-Debug "[$InstanceId] Format-KQLQuery - Replaced Unicode escape: $unicode"
            }
        }
        
        # Step 2: Normalize line endings and escape sequences
        $lineEndingReplacements = @{
            '\\r\\n' = "`n"      # Escaped CRLF to LF
            '\\n' = "`n"         # Escaped LF to actual LF
            '\\r' = "`n"         # Escaped CR to LF
            "`r`n" = "`n"        # CRLF to LF
            "`r" = "`n"          # CR to LF
        }
        
        foreach ($lineEnding in $lineEndingReplacements.Keys) {
            $formattedQuery = $formattedQuery -replace [regex]::Escape($lineEnding), $lineEndingReplacements[$lineEnding]
        }
        
        # Step 3: Handle tab characters and extra whitespace
        $formattedQuery = $formattedQuery -replace '\\t', "`t"    # Escaped tabs to actual tabs
        $formattedQuery = $formattedQuery -replace "`t", "    "   # Convert tabs to 4 spaces for consistency
        
        # Step 4: Trim leading and trailing whitespace
        $formattedQuery = $formattedQuery.Trim()
        
        # Step 5: **CRITICAL FIX** - Ensure query ends with newline if it doesn't already
        # This addresses the Query Pack legacy bug mentioned
        if (-not [string]::IsNullOrEmpty($formattedQuery) -and -not $formattedQuery.EndsWith("`n")) {
            $formattedQuery += "`n"
            Write-Debug "[$InstanceId] Format-KQLQuery - Added missing newline terminator for $Source query"
        }
        
        # Step 6: Remove excessive blank lines (more than 2 consecutive)
        $formattedQuery = [regex]::Replace($formattedQuery, "`n{3,}", "`n`n")
        
        # Step 7: DISABLED - Operator spacing normalization
        # This was causing issues with == becoming =  =
        # KQL is flexible enough with whitespace, so we skip this step
        
        # Step 8: Validate final query structure
        $issues = @()
        
        # Check for potential issues that could break execution
        if ($formattedQuery.Contains('""') -and -not $formattedQuery.Contains('""""""')) {
            $issues += "Contains empty quotes that might break parsing"
        }
        
        if ($formattedQuery.Contains('||') -and -not $formattedQuery.Contains('|||')) {
            $issues += "Contains double pipes that might be unintended"
        }
        
        if ([regex]::Matches($formattedQuery, '\|').Count -eq 0 -and $formattedQuery.Length -gt 50) {
            $issues += "Long query without pipes - might be malformed"
        }
        
        # Log validation issues as warnings
        if ($issues.Count -gt 0) {
            Write-Warning "[$InstanceId] Format-KQLQuery - Potential issues detected in $Source query:"
            $issues | ForEach-Object { Write-Warning "[$InstanceId]   - $_" }
        }
        
        # Step 9: Final validation and metrics
        $originalLength = $Query.Length
        $formattedLength = $formattedQuery.Length
        $sizeDifference = $formattedLength - $originalLength
        
        Write-Debug "[$InstanceId] Format-KQLQuery - Formatting complete for $Source query"
        Write-Debug "[$InstanceId]   Original length: $originalLength characters"
        Write-Debug "[$InstanceId]   Formatted length: $formattedLength characters"
        Write-Debug "[$InstanceId]   Size difference: $sizeDifference characters"
        
        if ([Math]::Abs($sizeDifference) -gt 10) {
            Write-Information "[$InstanceId] Format-KQLQuery - Significant formatting applied to $Source query (size change: $sizeDifference)"
        }
        
        return $formattedQuery
    }
    catch {
        $errorMessage = "Failed to format KQL query from $Source`: $($_.Exception.Message)"
        Write-Error "[$InstanceId] Format-KQLQuery - $errorMessage"
        
        # Return original query as fallback, but log the issue
        Write-Warning "[$InstanceId] Format-KQLQuery - Returning original query as fallback"
        return $Query
    }
}
