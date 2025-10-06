function Get-StringFromByte {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$ByteArray
    )

    try {
        # Check if $ByteArray is indeed a byte array
        if ($null -eq $ByteArray -or $ByteArray.GetType().Name -ne "Byte[]") {
            throw [System.ArgumentException]::new("Input must be a byte array.")
        }

        $stringBuilder = -join ($ByteArray | ForEach-Object { $_.ToString("x2") })
        return $stringBuilder
    }
    catch {
        Write-Error "An error occurred: $_"
        throw # Rethrow the exception to be handled further up in the call stack
    }
}
