function Get-ErrorSummary {
    <#
    .SYNOPSIS
        Gets error summary for an instance
    
    .PARAMETER InstanceId
        Instance identifier
    
    .OUTPUTS
        Error summary object
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InstanceId
    )
    
    if (-not $Global:ErrorTrackers -or -not $Global:ErrorTrackers.ContainsKey($InstanceId)) {
        return @{
            TotalErrors = 0
            ErrorBreakdown = @{
                Input = 0
                Storage = 0
                ADX = 0
                DCR = 0
                Query = 0
                Schema = 0
                Configuration = 0
                Time = 0
                Other = 0
            }
            ErrorRate = 0
        }
    }
    
    $tracker = $Global:ErrorTrackers[$InstanceId]
    $errors = $tracker.Errors
    
    # Calculate error breakdown by type
    $breakdown = @{
        Input = ($errors | Where-Object { $_.ErrorType -eq "Input" }).Count
        Storage = ($errors | Where-Object { $_.ErrorType -eq "Storage" }).Count
        ADX = ($errors | Where-Object { $_.ErrorType -eq "ADX" }).Count
        DCR = ($errors | Where-Object { $_.ErrorType -eq "DCR" }).Count
        Query = ($errors | Where-Object { $_.ErrorType -eq "Query" }).Count
        Schema = ($errors | Where-Object { $_.ErrorType -eq "Schema" }).Count
        Configuration = ($errors | Where-Object { $_.ErrorType -eq "Configuration" }).Count
        Time = ($errors | Where-Object { $_.ErrorType -eq "Time" }).Count
        Other = ($errors | Where-Object { $_.ErrorType -notin @("Input", "Storage", "ADX", "DCR", "Query", "Schema", "Configuration", "Time") }).Count
    }
    
    # Calculate error rate (errors per minute)
    $elapsedMinutes = ((Get-Date) - $tracker.StartTime).TotalMinutes
    $errorRate = if ($elapsedMinutes -gt 0) { [Math]::Round($errors.Count / $elapsedMinutes, 2) } else { 0 }
    
    return @{
        TotalErrors = $errors.Count
        ErrorBreakdown = $breakdown
        ErrorRate = $errorRate
        StartTime = $tracker.StartTime
        InstanceId = $InstanceId
    }
}
