function Write-EnhancedError {
    <#
    .SYNOPSIS
        Writes enhanced error information with tracking
    
    .PARAMETER Message
        Error message
    
    .PARAMETER ErrorType
        Type of error (Input, Storage, ADX, DCR, etc.)
    
    .PARAMETER Exception
        Exception object (optional)
    
    .PARAMETER InstanceId
        Instance identifier for tracking
    
    .PARAMETER TableName
        Table name for context (optional)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [string]$ErrorType,
        
        [Parameter(Mandatory=$false)]
        [System.Exception]$Exception,
        
        [Parameter(Mandatory=$true)]
        [string]$InstanceId,
        
        [Parameter(Mandatory=$false)]
        [string]$TableName = "Unknown"
    )
    
    # Create error record
    $errorRecord = @{
        Timestamp = Get-Date
        Message = $Message
        ErrorType = $ErrorType
        TableName = $TableName
        InstanceId = $InstanceId
        ExceptionMessage = if ($Exception) { $Exception.Message } else { "" }
        ExceptionType = if ($Exception) { $Exception.GetType().Name } else { "" }
    }
    
    # Track error if tracking is available
    if ($Global:ErrorTrackers -and $Global:ErrorTrackers.ContainsKey($InstanceId)) {
        $Global:ErrorTrackers[$InstanceId].Errors += $errorRecord
    }
    
    # Write to error stream
    $errorMessage = "[$InstanceId][$TableName][$ErrorType] $Message"
    if ($Exception) {
        $errorMessage += " - Exception: $($Exception.Message)"
    }
    
    Write-Error $errorMessage
}
