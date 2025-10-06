function Get-SignatureKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$DateStamp,

        [Parameter(Mandatory = $true)]
        [string]$RegionName,

        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )

    $kSigning = $null

    try {
        # Prepare the key
        $kSecret = [Text.Encoding]::UTF8.GetBytes("AWS4$Key")
        $kDate = Get-HmacSHA256 -Data $DateStamp -Key $kSecret
        $kRegion = Get-HmacSHA256 -Data $RegionName -Key $kDate
        $kService = Get-HmacSHA256 -Data $ServiceName -Key $kRegion
        $kSigning = Get-HmacSHA256 -Data "aws4_request" -Key $kService
    } catch {
        Write-Error "An error occurred while generating the signature key: $_"
    } finally {
        if ($null -ne $kSecret) {
            [Array]::Clear($kSecret, 0, $kSecret.Length)
        }
    }

    return $kSigning
}
