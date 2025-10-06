function Split-JsonPayload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "EH Name")]
        [string]
        [ValidateNotNullOrEmpty()]
        $ehName,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "EH Namespace")]
        [string]
        [ValidateNotNullOrEmpty()]
        $ehNameSpace,

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = "EH Policy Name")]
        [string]
        [ValidateNotNullOrEmpty()]
        $keyname,

        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Event Hub Policy Key")]
        [string]
        [ValidateNotNullOrEmpty()]
        $key,

        [Parameter(Mandatory = $true)]
        [string] $jsonFilePath
    )

    # Set the maximum payload size to 1 MB for Event Hubs
    $maxPayloadSize = 1MB

    try {
        # Read the JSON content
        write-information "(Split-JsonPayload) Get-Content -Path $($jsonFilePath) -Raw"
        $jsonContent = Get-Content -Path $jsonFilePath -Raw

        write-information "(Split-JsonPayload) Get-Content successful $($jsonContent )"
        $jsonObject = ConvertFrom-Json -InputObject $jsonContent

        # Initialize variables
        $chunk = @()
        $currentSize = 0

        # Set default Event Hub elements
        $URI = "{0}.servicebus.windows.net/{1}" -f $ehNameSpace, $ehName
        $encodedURI = [System.Web.HttpUtility]::UrlEncode($URI)

        # Calculate expiry value one hour ahead
        $expiry = [string](([DateTimeOffset]::Now.ToUnixTimeSeconds()) + 3600)

        # Create the signature
        $stringToSign = [System.Web.HttpUtility]::UrlEncode($URI) + "`n" + $expiry

        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.Key = [Text.Encoding]::ASCII.GetBytes($key)

        $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($stringToSign))
        $signature = [System.Web.HttpUtility]::UrlEncode([Convert]::ToBase64String($signature))

        # Dispose of the HMACSHA256 object
        $hmacsha.Dispose()

        # Iterate through each record
        foreach ($record in $jsonObject.Records) {
            $recordSize = (ConvertTo-Json -InputObject $record -Depth 10).Length

            # Check if adding the record exceeds the max payload size
            if (($currentSize + $recordSize) -ge $maxPayloadSize) {
                # Send the current chunk to Event Hub
                $chunkPayload = @{ Records = $chunk } | ConvertTo-Json -Compress -Depth 50

                $headers = @{
                    "Authorization" = "SharedAccessSignature sr=$encodedURI&sig=$signature&se=$expiry&skn=$keyname"
                    "Content-Type" = "application/atom+xml;type=entry;charset=utf-8"
                    "Content-Length" = $chunkPayload.Length
                }

                # Execute the Azure REST API
                $method = "POST"
                $dest = "https://$URI/messages?timeout=60&api-version=2014-01"

                write-information "(Split-JsonPayload) Invoke-RestMethod uploading Log Chunk"
                write-information "(Split-JsonPayload) Invoke-RestMethod Content-length Original = $($chunkPayload.Length)"
                $null = Invoke-RestMethod -Uri $dest -Method $method -Headers $headers -Body $chunkPayload -Verbose -SkipHeaderValidation

                # Reset chunk and current size
                $chunk = @()
                $currentSize = 0
            }

            # Add the record to the chunk
            $chunk += $record
            $currentSize += $recordSize
        }

        # Send any remaining records as the last chunk
        if ($chunk.Count -gt 0) {
            $chunkPayload = @{ Records = $chunk } | ConvertTo-Json -Compress -Depth 50
            $headers = @{
                "Authorization" = "SharedAccessSignature sr=$encodedURI&sig=$signature&se=$expiry&skn=$keyname"
                "Content-Type" = "application/atom+xml;type=entry;charset=utf-8"
                "Content-Length" = $chunkPayload.Length
            }

            # Execute the Azure REST API
            $method = "POST"
            $dest = "https://$($URI)/messages?timeout=60&api-version=2014-01"

            write-information "(Split-JsonPayload) Invoke-RestMethod uploading Log Chunk"
            write-information "(Split-JsonPayload) Invoke-RestMethod Content-length Original = $($chunkPayload.Length)"

        # Check if the script is running in PowerShell Core
        $useSkipHeaderValidation = $($PSVersionTable.PSEdition) -eq 'Core'

        if ($useSkipHeaderValidation) {
            write-information "(Split-JsonPayload)  Invoke-RestMethod -Uri $($dest) -Method $($method) -Headers $($headers) -Body $($chunkPayload) -Verbose -SkipHeaderValidation"
            $Response = Invoke-RestMethod -Uri $dest -Method $method -Headers $headers -Body $chunkPayload -Verbose -SkipHeaderValidation  -SkipCertificateCheck
        }else{
            write-information "(Split-JsonPayload)  Invoke-RestMethod -Uri $($dest) -Method $($method) -Headers $($headers) -Body $($chunkPayload) -Verbose"
            $Response = Invoke-RestMethod -Uri $dest -Method $method -Headers $headers -Body $chunkPayload -Verbose  -SkipCertificateCheck
        }
        write-information "(Split-JsonPayload) Invoke-RestMethod Resonse = $(Convertto-json -InputObject $Response)"

        }
    } catch {
        Write-Error "An error occurred: $_"
        throw
    }
}
