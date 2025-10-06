function Get-HmacSHA256 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Data,

        [Parameter(Mandatory = $true)]
        [byte[]]$Key
    )

    try {
        $hash = [System.Security.Cryptography.HMACSHA256]::new()
        $hash.Key = $Key
        return $hash.ComputeHash([Text.Encoding]::UTF8.GetBytes($Data))
    } catch {
        Write-Error "An error occurred while computing the HMAC SHA256 hash: $_"
    } finally {
        if ($null -ne $hash) {
            $hash.Dispose()
        }
    }
}
