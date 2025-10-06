function New-FallbackResult {
    <#
    .SYNOPSIS
        Creates a fallback result for error scenarios
    
    .PARAMETER TableName
        Name of the table being processed
    
    .PARAMETER Status
        Processing status
    
    .PARAMETER Message
        Status message
    
    .PARAMETER InstanceId
        Unique instance identifier
    
    .PARAMETER QueueMode
        Whether queue mode is active
    
    .PARAMETER CycleNumber
        Current cycle number
    
    .OUTPUTS
        Standardized result hashtable for error scenarios
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        
        [Parameter(Mandatory=$true)]
        [string]$Status,
        
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [string]$InstanceId,
        
        [Parameter(Mandatory=$false)]
        [bool]$QueueMode = $false,
        
        [Parameter(Mandatory=$false)]
        [int]$CycleNumber = 1
    )
    
    return @{
        Success = $false
        TableName = $TableName
        Status = $Status
        Message = $Message
        InstanceId = $InstanceId
        QueueMode = $QueueMode
        CycleNumber = $CycleNumber
        ModuleArchitecture = "Clean-AZRest"
        ProcessingMode = if ($QueueMode) { "QueueManaged" } else { "Standard" }
        RecordsProcessed = 0
        EndTime = ([DateTime]::UtcNow).ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
}
