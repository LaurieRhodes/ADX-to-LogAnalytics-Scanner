function Send-ToDCR {
    <#
    .SYNOPSIS
        Universal function to send events to any Data Collection Rule with Dynamic Schema Loading and Debug Logging
    
    .DESCRIPTION
        Universal function that sends events to DCR with dynamic field filtering:
        - Loads schema definitions from JSON files at runtime
        - Only sends fields that match the DCR stream schema
        - Filters out system properties (_xxx fields) 
        - Filters out fields not defined in DCR stream
        - FIXED: Ensures proper JSON array format for DCR ingestion
        - DEBUG: Logs full JSON payload when debug logging enabled
    
    .PARAMETER EventMessage
        JSON string containing the event data to send
    
    .PARAMETER TableName
        Name of the target table (e.g., 'Syslog', 'AWSCloudTrail')
        Used to construct stream name as 'Custom-{TableName}' and load schema
    
    .PARAMETER DcrImmutableId
        Immutable ID of the Data Collection Rule
    
    .PARAMETER DceEndpoint
        Data Collection Endpoint URL
    
    .PARAMETER ClientId
        Client ID for authentication (User Assigned Identity)
    
    .PARAMETER InstanceId
        Unique instance identifier for multithreaded logging
    
    .OUTPUTS
        Hashtable with Success boolean and details
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$EventMessage,

        [Parameter(Mandatory=$true)]
        [string]$TableName,

        [Parameter(Mandatory=$true)]
        [string]$DcrImmutableId,

        [Parameter(Mandatory=$true)]
        [string]$DceEndpoint,

        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId = "unknown"
    )

    process {
        try {
            # Validate inputs
            if ([string]::IsNullOrWhiteSpace($EventMessage)) {
                throw "EventMessage cannot be null or empty"
            }

            if ([string]::IsNullOrWhiteSpace($TableName)) {
                throw "TableName cannot be null or empty"
            }

            if ([string]::IsNullOrWhiteSpace($DcrImmutableId)) {
                throw "DcrImmutableId cannot be null or empty"
            }

            if ([string]::IsNullOrWhiteSpace($DceEndpoint)) {
                throw "DceEndpoint cannot be null or empty"
            }

            if ([string]::IsNullOrWhiteSpace($ClientId)) {
                throw "ClientId cannot be null or empty"
            }

            # Parse event message
            try {
                $eventData = $EventMessage | ConvertFrom-Json
                Write-Debug "[$InstanceId][$TableName] Event parsed successfully"
            }
            catch {
                throw "Failed to parse EventMessage as JSON: $($_.Exception.Message)"
            }

            # DEBUG: Log original event data structure
            $originalFieldCount = ($eventData.PSObject.Properties | Measure-Object).Count
            Write-Debug "[$InstanceId][$TableName] Original event has $originalFieldCount fields"

            # DYNAMIC SCHEMA LOADING: Load schema from JSON file
            $allowedFields = $null
            $schemaSource = "Generic"
            
            try {
                # Load schema from file using the DCRSchemaLoader module
                $allowedFields = Get-DCRSchemaFromFile -TableName $TableName
                
                if ($allowedFields -and $allowedFields.Count -gt 0) {
                    $schemaSource = "JSON file"
                    Write-Debug "[$InstanceId][$TableName] Schema loaded: $($allowedFields.Count) allowed fields"
                } else {
                    Write-Debug "[$InstanceId][$TableName] No schema file found - using generic filtering"
                }
            }
            catch {
                Write-Warning "[$InstanceId][$TableName] Schema load failed: $($_.Exception.Message)"
                $allowedFields = $null
            }
            
            # Filter data based on DCR schema compliance
            $filteredData = @{}
            $systemPropertiesRemoved = @()
            $undefinedFieldsRemoved = @()
            $fieldsKept = @()

            # Process all properties from the event data
            $eventData.PSObject.Properties | ForEach-Object {
                $propertyName = $_.Name
                $propertyValue = $_.Value
                
                # Skip system properties (those starting with underscore)
                if ($propertyName.StartsWith('_')) {
                    $systemPropertiesRemoved += $propertyName
                    return
                }
                
                # If we have a schema definition for this table, enforce it
                if ($allowedFields -and $allowedFields.Count -gt 0) {
                    if ($allowedFields -contains $propertyName) {
                        $filteredData[$propertyName] = $propertyValue
                        $fieldsKept += $propertyName
                    } else {
                        $undefinedFieldsRemoved += $propertyName
                    }
                } else {
                    # No schema defined - use generic filtering (keep all non-system properties)
                    $filteredData[$propertyName] = $propertyValue
                    $fieldsKept += $propertyName
                }
            }
            
            # DEBUG: Log filtering results
            Write-Debug "[$InstanceId][$TableName] Filtering: kept $($fieldsKept.Count), removed $($systemPropertiesRemoved.Count) system, removed $($undefinedFieldsRemoved.Count) undefined"
            
            if ($filteredData.Count -eq 0) {
                Write-Warning "[$InstanceId][$TableName] No valid data after filtering"
                return @{
                    Success = $true
                    Message = "No valid data to send after DCR schema filtering"
                    RecordsProcessed = 0
                    TableName = $TableName
                    SystemPropertiesRemoved = $systemPropertiesRemoved.Count
                    UndefinedFieldsRemoved = $undefinedFieldsRemoved.Count
                    SchemaSource = $schemaSource
                }
            }

            # Create standardized stream name: Custom-{TableName}  
            $streamName = "Custom-$TableName"
            
            # Construct DCR ingestion URL with correct API version
            $dcrUrl = "$DceEndpoint/dataCollectionRules/$DcrImmutableId/streams/$streamName" + "?api-version=2021-11-01-preview"
            
            Write-Debug "[$InstanceId][$TableName] DCR URL: $dcrUrl"

            # Get access token using Azure AD token function
            try {
                $accessToken = Get-AzureADToken -Resource "https://monitor.azure.com/" -ClientId $ClientId
                Write-Debug "[$InstanceId][$TableName] Access token acquired"
            }
            catch {
                $errorMsg = "Authentication failed: $($_.Exception.Message)"
                Write-Error "[$InstanceId][$TableName] $errorMsg"
                throw $errorMsg
            }

            # CRITICAL FIX: Prepare event data as proper JSON array - DCR expects array format
            try {
                # Create array with single object - EXACTLY like legacy implementation
                $outputCollection = @()
                $outputCollection += $filteredData
                
                # FORCE array format using -AsArray parameter (PowerShell 7+) or manual approach
                if ($PSVersionTable.PSVersion.Major -ge 7) {
                    $jsonPayload = $outputCollection | ConvertTo-Json -Depth 10 -Compress -AsArray
                } else {
                    # PowerShell 5.x compatible: Force array by using custom serialization
                    if ($outputCollection.Count -eq 1) {
                        # Force array format for single item
                        $singleObjectJson = $outputCollection[0] | ConvertTo-Json -Depth 10 -Compress
                        $jsonPayload = "[$singleObjectJson]"
                    } else {
                        $jsonPayload = $outputCollection | ConvertTo-Json -Depth 10 -Compress
                    }
                }
                
                # Verify array format - critical check
                if (-not $jsonPayload.StartsWith('[')) {
                    Write-Warning "[$InstanceId][$TableName] Force-fixing non-array payload"
                    $jsonPayload = "[$jsonPayload]"
                }
                
                # DEBUG: Log the complete JSON payload being sent to DCR
                Write-Debug "[$InstanceId][$TableName] === DCR PAYLOAD DEBUG ==="
                Write-Debug "[$InstanceId][$TableName] Payload size: $($jsonPayload.Length) characters"
                Write-Debug "[$InstanceId][$TableName] Stream: $streamName"
                Write-Debug "[$InstanceId][$TableName] Schema source: $schemaSource"
                Write-Debug "[$InstanceId][$TableName] Fields kept: $($fieldsKept -join ', ')"
                
                # CRITICAL DEBUG: Log the actual JSON payload
                if ($env:FUNCTIONS_EXTENSION_VERSION -and $VerbosePreference -eq 'Continue') {
                    # In Azure Functions with Verbose logging, show full payload
                    Write-Information "[$InstanceId][$TableName] === FULL DCR PAYLOAD ==="
                    Write-Information "[$InstanceId][$TableName] JSON: $jsonPayload"
                    Write-Information "[$InstanceId][$TableName] ========================="
                }
                
            }
            catch {
                throw "Failed to serialize event data to JSON: $($_.Exception.Message)"
            }

            # Send data to DCR using exact legacy pattern
            try {
                $headers = @{
                    "Authorization" = "Bearer $accessToken"
                    "Content-Type" = "application/json"
                }

                # Use exact legacy parameters
                $restParams = @{
                    Uri = $dcrUrl
                    Method = 'POST'
                    Headers = $headers
                    Body = $jsonPayload
                    TimeoutSec = 60
                    ErrorAction = 'Stop'
                }

                Write-Debug "[$InstanceId][$TableName] Sending to DCR..."
                $response = Invoke-RestMethod @restParams
                
                Write-Information "[$InstanceId][$TableName] Successfully sent to DCR"
                
                return @{
                    Success = $true
                    Message = "Event successfully sent to $TableName"
                    TableName = $TableName
                    StreamName = $streamName
                    RecordsProcessed = 1
                    SystemPropertiesRemoved = $systemPropertiesRemoved.Count
                    UndefinedFieldsRemoved = $undefinedFieldsRemoved.Count
                    FieldsKept = $fieldsKept.Count
                    DcrId = $DcrImmutableId
                    DceEndpoint = $DceEndpoint
                    PayloadSize = $jsonPayload.Length
                    ResponseStatus = "OK"
                    Method = "Dynamic-Schema-Loading"
                    SchemaSource = $schemaSource
                    SchemaFieldsCount = $(if ($allowedFields) { $allowedFields.Count } else { 0 })
                    ArrayFormatFixed = $true
                }
            }
            catch {
                # Enhanced error handling for Azure Functions environment
                $statusCode = "Unknown"
                $responseContent = "No response available"
                $innerException = ""
                
                # Handle different exception types properly
                if ($_.Exception -and $_.Exception.Response) {
                    $statusCode = $_.Exception.Response.StatusCode
                    
                    # Use proper method to read response content
                    try {
                        if ($_.Exception.Response.Content) {
                            $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
                        }
                    }
                    catch {
                        $responseContent = "Could not read response content: $($_.Exception.Message)"
                    }
                }
                elseif ($_.Exception -and $_.Exception.Message -match "400") {
                    $statusCode = "BadRequest"
                    $responseContent = "HTTP 400 Bad Request - Check payload format and DCR configuration"
                }
                
                if ($_.Exception.InnerException) {
                    $innerException = $_.Exception.InnerException.Message
                }

                $errorMessage = "DCR ingestion failed for table $TableName"
                $fullError = "$errorMessage. Status: $statusCode, Error: $($_.Exception.Message)"
                if ($innerException) {
                    $fullError += ", Inner: $innerException"
                }
                if ($responseContent -ne "No response available") {
                    $fullError += ", Response: $responseContent"
                }
                
                Write-Error "[$InstanceId][$TableName] $fullError"
                
                # DEBUG: Log the payload that failed
                Write-Information "[$InstanceId][$TableName] === FAILED PAYLOAD DEBUG ==="
                Write-Information "[$InstanceId][$TableName] Failed JSON: $jsonPayload"
                Write-Information "[$InstanceId][$TableName] =========================="
                
                return @{
                    Success = $false
                    Message = $errorMessage
                    TableName = $TableName
                    StreamName = $streamName
                    RecordsProcessed = 0
                    SystemPropertiesRemoved = $systemPropertiesRemoved.Count
                    UndefinedFieldsRemoved = $undefinedFieldsRemoved.Count
                    DcrId = $DcrImmutableId
                    DceEndpoint = $DceEndpoint
                    Error = @{
                        StatusCode = $statusCode
                        Message = $_.Exception.Message
                        InnerException = $innerException
                        Response = $responseContent
                        ErrorType = $_.Exception.GetType().Name
                        FailedPayload = $jsonPayload
                    }
                    Method = "Dynamic-Schema-Loading"
                    SchemaSource = $schemaSource
                    ArrayFormatFixed = $true
                }
            }
        }
        catch {
            $errorMessage = "Send-ToDCR - Critical error processing event for table $TableName`: $($_.Exception.Message)"
            Write-Error "[$InstanceId][$TableName] $errorMessage"
            
            return @{
                Success = $false
                Message = "Critical error: $($_.Exception.Message)"
                TableName = $TableName
                RecordsProcessed = 0
                Error = @{
                    Type = $_.Exception.GetType().Name
                    Message = $_.Exception.Message
                    StackTrace = $_.ScriptStackTrace
                }
                Method = "Dynamic-Schema-Loading"
            }
        }
    }
}
