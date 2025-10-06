function Get-SHA256 {
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Data
    )

    $hash = $null
    try {
        $hash = [System.Security.Cryptography.SHA256]::Create()
        $array = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Data))
        return $array
    } catch {
        Write-Error "An error occurred while computing the SHA256 hash: $_"
    } finally {
        if ($null -ne $hash) {
            $hash.Dispose()
        }
    }
}
