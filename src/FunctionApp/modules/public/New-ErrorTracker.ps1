function New-ErrorTracker {
    <#
    .SYNOPSIS
        Creates a new error tracker for an instance
    
    .PARAMETER InstanceId
        Unique identifier for the instance
    
    .OUTPUTS
        Error tracker object
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InstanceId
    )
    
    # Initialize error tracking for this instance
    if (-not $Global:ErrorTrackers) {
        $Global:ErrorTrackers = @{}
    }
    
    $Global:ErrorTrackers[$InstanceId] = @{
        Errors = @()
        StartTime = Get-Date
        InstanceId = $InstanceId
    }
    
    Write-Debug "[New-ErrorTracker] Initialized error tracking for instance: $InstanceId"
    return $Global:ErrorTrackers[$InstanceId]
}
