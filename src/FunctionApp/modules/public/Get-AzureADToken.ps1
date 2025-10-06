function Get-AzureADToken {
    <#
    .SYNOPSIS
        Retrieves Azure AD token using Managed Identity
    
    .PARAMETER resource
        The resource URL to get token for
    
    .PARAMETER clientId
        The Client ID of the Managed Identity
    
    .OUTPUTS
        Access token string
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$resource,
        
        [Parameter(Mandatory=$true)]
        [string]$clientId
    )
    
    try {
        # Check if we're in Azure Functions environment
        if (-not $env:IDENTITY_ENDPOINT) {
            throw "IDENTITY_ENDPOINT environment variable is not set"
        }
        if (-not $env:IDENTITY_HEADER) {
            throw "IDENTITY_HEADER environment variable is not set"
        }
        
        # Build the request URL
        $url = "$($env:IDENTITY_ENDPOINT)?resource=$([System.Web.HttpUtility]::UrlEncode($resource))&client_id=$clientId&api-version=2019-08-01"
        
        # Prepare headers
        $headers = @{
            'Metadata' = 'True'
            'X-IDENTITY-HEADER' = $env:IDENTITY_HEADER
        }
        
        # Make the request with retry logic
        $maxRetries = 3
        $retryCount = 0
        $retryDelaySeconds = 2
        
        do {
            try {
                $response = Invoke-RestMethod -Uri $url -Method 'GET' -Headers $headers -TimeoutSec 30
                
                if (-not $response.access_token) {
                    throw "No access token found in response"
                }
                
                return $response.access_token
            }
            catch {
                $retryCount++
                if ($retryCount -eq $maxRetries) {
                    throw
                }
                Write-Warning "Token retry $retryCount/$maxRetries in $retryDelaySeconds seconds"
                Start-Sleep -Seconds $retryDelaySeconds
                $retryDelaySeconds *= 2  # Exponential backoff
            }
        } while ($retryCount -lt $maxRetries)
    }
    catch {
        Write-Error "Get-AzureADToken - Failed to acquire token: $($_.Exception.Message)"
        throw
    }
}
