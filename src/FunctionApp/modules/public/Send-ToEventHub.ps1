<#
  .SYNOPSIS
  Submit JSON to Event Hubs - optimized logging for production
  
  .DESCRIPTION
  Sends data to Azure Event Hub as JSON array format.
  Enhanced error handling for Basic SKU size limits and permission issues.
  Uses DEBUG level for detailed diagnostics, INFORMATION for key metrics.
#>

function Send-ToEventHub {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Payload,
        
        [Parameter(Mandatory=$false)]
        [string]$TableName = "Unknown",
        
        [Parameter(Mandatory=$false)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$false)]
        [string]$InstanceId
    )

    $logPrefix = if ($InstanceId) { "[$($InstanceId.Substring(0,8))][$TableName]" } else { "[$TableName]" }

    # Validate required environment variables
    $requiredVars = @{
        'EVENTHUBNAMESPACE' = $env:EVENTHUBNAMESPACE
        'EVENTHUBNAME' = $env:EVENTHUBNAME
        'CLIENTID' = $env:CLIENTID
    }
    
    $missingVars = @()
    foreach ($var in $requiredVars.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace($var.Value)) {
            $missingVars += $var.Key
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Warning "$logPrefix Missing required environment variables: $($missingVars -join ', ')"
        return @{
            Success = $false
            Error = "Configuration Error"
            Message = "Missing environment variables: $($missingVars -join ', ')"
        }
    }

    # Basic SKU Event Hub limits
    $maxPayloadSize = 230KB

    # Parse the JSON payload
    try {
        $PayloadObject = ConvertFrom-Json -InputObject $Payload
        Write-Debug "$logPrefix Parsed payload: $($PayloadObject.Count) records"
    }
    catch {
        Write-Warning "$logPrefix Invalid JSON payload: $($_.Exception.Message)"
        return @{
            Success = $false
            Error = "Invalid JSON"
            Message = $_.Exception.Message
        }
    }

    # Initialize chunking
    $chunk = @()
    $messages = @()
    $currentSize = 0

    foreach ($record in $PayloadObject) {
        $recordJson = ConvertTo-Json -InputObject $record -Depth 50
        $recordSize = [System.Text.Encoding]::UTF8.GetByteCount($recordJson)

        # Check if adding this record would exceed limit
        if (($currentSize + $recordSize) -ge $maxPayloadSize) {
            $messages += @{
                Records = $chunk
                SizeKB = [Math]::Round($currentSize/1024, 2)
            }
            
            $chunk = @()
            $currentSize = 0
        }
        
        $chunk += $record
        $currentSize += $recordSize
    }

    # Add remaining chunk
    if ($chunk.Count -gt 0) {
        $messages += @{
            Records = $chunk
            SizeKB = [Math]::Round($currentSize/1024, 2)
        }
    }

    $EventHubUri = "https://$($env:EVENTHUBNAMESPACE).servicebus.windows.net/$($env:EVENTHUBNAME)/messages"
    Write-Debug "$logPrefix Event Hub URI: $EventHubUri"
    Write-Debug "$logPrefix Sending $($messages.Count) chunk(s) to Event Hub"

    $successfulChunks = 0
    $totalChunks = $messages.Count

    foreach ($chunkInfo in $messages) {
        $currentChunkNumber = $successfulChunks + 1
        
        try {
            # Get Event Hub Token
            $EHtoken = Get-AzureADToken -resource "https://eventhubs.azure.net" -clientId $env:CLIENTID
            
            if ([string]::IsNullOrWhiteSpace($EHtoken)) {
                throw "Event Hub token acquisition returned empty token"
            }

            $jsonPayload = ConvertTo-Json -InputObject $chunkInfo.Records -Depth 50
            $payloadSizeKB = [Math]::Round([System.Text.Encoding]::UTF8.GetByteCount($jsonPayload)/1024, 2)

            $headers = @{
                'content-type'  = 'application/json'
                'authorization' = "Bearer $($EHtoken)"
            }

            Write-Debug "$logPrefix Chunk $currentChunkNumber - Size $payloadSizeKB KB, Records $($chunkInfo.Records.Count)"

            # Send to Event Hub
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $Response = Invoke-RestMethod -Uri $EventHubUri -Method Post -Headers $headers -Body $jsonPayload -SkipHeaderValidation -SkipCertificateCheck
            } else {
                $Response = Invoke-RestMethod -Uri $EventHubUri -Method Post -Headers $headers -Body $jsonPayload
            }

            $successfulChunks++
            Write-Debug "$logPrefix Successfully sent chunk $currentChunkNumber of $totalChunks"

        } catch {
            $exceptionMessage = $_.Exception.Message
            
            if ($exceptionMessage -match "401|unauthorized") {
                Write-Warning "$logPrefix EVENT HUB PERMISSION ERROR - Managed Identity needs 'Azure Event Hubs Data Sender' role (permissions can take up to 24 hours to propagate)"
                
                return @{
                    Success = $false
                    Error = "Permission Pending"
                    Message = "Event Hub permissions may still be propagating"
                    RetryRecommended = $true
                }
            }
            elseif ($exceptionMessage -match "413|Request Entity Too Large") {
                Write-Warning "$logPrefix PAYLOAD TOO LARGE - Chunk $currentChunkNumber has $($chunkInfo.SizeKB) KB (Basic SKU limit: 256KB)"
            }
            elseif ($exceptionMessage -match "400|Bad Request") {
                Write-Warning "$logPrefix BAD REQUEST - Event Hub rejected the request: $exceptionMessage"
            }
            else {
                Write-Warning "$logPrefix EVENT HUB ERROR - $exceptionMessage"
            }
        }
    }

    # INFORMATION level for key operational metrics only
    if ($successfulChunks -eq $totalChunks) {
        Write-Information "$logPrefix Sent $successfulChunks chunk(s) to Event Hub"
    } else {
        Write-Warning "$logPrefix Partial success: $successfulChunks / $totalChunks chunks sent"
    }

    return @{
        ChunksSent = $successfulChunks
        TotalChunks = $totalChunks
        Success = ($successfulChunks -eq $totalChunks)
    }
}
