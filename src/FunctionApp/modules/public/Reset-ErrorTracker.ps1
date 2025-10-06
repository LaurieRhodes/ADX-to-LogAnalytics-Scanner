function Reset-ErrorTracker {
    <#
    .SYNOPSIS
        Resets/cleans up error tracker for an instance
    
    .PARAMETER InstanceId
        Instance identifier
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InstanceId
    )
    
    if ($Global:ErrorTrackers -and $Global:ErrorTrackers.ContainsKey($InstanceId)) {
        $Global:ErrorTrackers.Remove($InstanceId)
        Write-Debug "[Reset-ErrorTracker] Cleaned up error tracking for instance: $InstanceId"
    }
}
