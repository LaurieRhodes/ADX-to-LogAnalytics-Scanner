function Get-StorageDetailsFromConnectionString {
    <#
    .SYNOPSIS
        Parses Azure Storage connection string to extract account details
    
    .PARAMETER ConnectionString
        Azure Storage connection string to parse
    
    .OUTPUTS
        Hashtable containing AccountName, AccountKey, and EndpointSuffix
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConnectionString
    )
    
    if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
        return $null
    }
    
    $connectionParams = @{}
    $ConnectionString.Split(';') | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $connectionParams[$matches[1]] = $matches[2]
        }
    }
    
    return @{
        AccountName = $connectionParams['AccountName']
        AccountKey = $connectionParams['AccountKey']
        EndpointSuffix = $connectionParams['EndpointSuffix']
    }
}
